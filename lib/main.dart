import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Import para grabar y transcribir
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> requestMicrophonePermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    await Permission.microphone.request();
  }
}

const String apiKey = "AIzaSyCIpuvmSma2EO4Rk0xaivrJhbjhXD-_DXE";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late stt.SpeechToText _speech; // Instancia de speech_to_text
  bool _isListening = false; // Para controlar el estado de la escucha
  String _speechText = ''; // Para almacenar el texto transcrito

@override
void initState() {
  super.initState();
  _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  _chat = _model.startChat();
  _speech = stt.SpeechToText(); // Inicializa el SpeechToText
  requestMicrophonePermission(); // Solicita el permiso del micrófono al iniciar
}

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
    });

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      setState(() {
        _messages.add(ChatMessage(text: text!, isUser: false));
        _scrollDown();
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Error: $e', isUser: false));
      });
    } finally {
      _textController.clear();
    }
  }

  void _startListening() async {
  bool available = await _speech.initialize();
  if (available) {
    setState(() => _isListening = true);
    _speech.listen(onResult: (result) {
      setState(() {
        _speechText = result.recognizedWords;
      });
    });
  }
}

void _stopListening() {
  setState(() => _isListening = false);
  _speech.stop();
}

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black26,
      appBar: AppBar(
        title: Text('Chatbot - $formattedDate'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(30),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic, // Cambia el icono según el estado
                    color: const Color.fromARGB(255, 174, 149, 60),
                    size: 32,
                  ),
                  onPressed: _isListening ? _stopListening : _startListening, // Activa o detiene la grabación
                ),
                Expanded(
                  child: TextField(
                    onSubmitted: _sendChatMessage,
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 76, 144, 133),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 107, 201, 185),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 107, 201, 185),
                        ),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Color.fromARGB(255, 107, 201, 185),
                  iconSize: 35,
                  onPressed: () => _sendChatMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            CircleAvatar(
              backgroundImage: AssetImage('assets/bot.png'), // Ruta de la imagen del bot
              radius: 20,
            ),
          SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.25,
            ),
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: message.isUser ? Color.fromARGB(255, 47, 89, 82) : Color.fromARGB(255, 46, 65, 84),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: message.isUser ? Radius.circular(12) : Radius.zero,
                bottomRight: message.isUser ? Radius.zero : Radius.circular(12),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
          if (message.isUser) SizedBox(width: 8),
          if (message.isUser)
            CircleAvatar(
              backgroundImage: AssetImage('assets/person.png'), // Ruta de la imagen del usuario
              radius: 20,
            ),
        ],
      ),
    );
  }
}
