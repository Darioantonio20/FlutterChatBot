import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:ffi';

	const String apiKey = "AIzaSyCIpuvmSma2EO4Rk0xaivrJhbjhXD-_DXE";
	
void main(){
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
  

  @override
  void initState(){
    super.initState();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    _chat = _model.startChat();
  }

  void _scrollDown(){
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCirc,
      )
    );
  }
  
Future<void> _sendChatMessage(String message) async {
  setState(() {
    _messages.add(ChatMessage(text: message, isUser: true));
  });

  try{
    final response = await _chat.sendMessage(Content.text(message));
    final text = response.text;
    setState(() {
      _messages.add(ChatMessage(text: text!, isUser: false));
      _scrollDown();
    });
  } catch(e){
    _messages.add(ChatMessage(text: 'Error: $e', isUser: false));
  }finally{
    _textController.clear();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AI Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
            return ChatBubble(message: _messages[index]);
          },)),
          Padding(padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(child: TextField(
                onSubmitted: _sendChatMessage,
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )),
              IconButton(
                icon: Icon(Icons.send),
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
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 1.25,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? Color.fromARGB(255, 135, 252, 232) : Color.fromARGB(255, 133, 185, 241),
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
          ),  
        ),
      ),
    );
  }
}