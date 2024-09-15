import 'package:bubble/bubble.dart';
import 'package:dialogflow_flutter/dialogflowFlutter.dart';
import 'package:dialogflow_flutter/googleAuth.dart';
import 'package:dialogflow_flutter/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

void detectIntent(String query) async {
  try {
    AuthGoogle authGoogle = await AuthGoogle(fileJson: 'assets/dialog_flow_auth.json').build();
    DialogFlow dialogflow = DialogFlow(authGoogle: authGoogle, language: Language.spanish);
    AIResponse response = await dialogflow.detectIntent(query);

    if (response.getListMessage() != null) {
      List? messages = response.getListMessage();
      for (var message in messages!) {
        if (message != null && message['text'] != null && message['text']['text'] != null) {
          print(message['text']['text'][0]);
        } else {
          print("Mensaje no válido recibido.");
        }
      }
    } else {
      print("No se recibió una respuesta válida del bot.");
    }
  } catch (e) {
    print("Error al detectar la intención: $e");
  }
}

Future<void> readServiceJson() async {
  final file = File('assets/dialog_flow_auth.json');
  final contents = await file.readAsString();
  final jsonData = jsonDecode(contents);

  print(jsonData);
}
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Flutter Demo Home Page', key: UniqueKey(),),
    );
  }
}

class MyHomePage extends StatefulWidget {
MyHomePage({required Key key, required this.title}) : super(key: key);
final String title;

@override
_MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
void response(query) async {
  try {
    AuthGoogle authGoogle = await AuthGoogle(fileJson: 'assets/dialog_flow_auth.json').build();
    DialogFlow dialogflow = DialogFlow(authGoogle: authGoogle, language: Language.english);
    
    // Detectar la intención a partir de la consulta
    AIResponse aiResponse = await dialogflow.detectIntent(query);
    
    // Imprimir toda la respuesta para ver su estructura
    print("Respuesta completa de AIResponse: ${aiResponse.getMessage()}");
    
    if (aiResponse.getListMessage() != null) {
      var message = aiResponse.getListMessage();
      
      // Imprimir el mensaje para ver su estructura
      print("Mensaje recibido: $message");
      if (message != null && message.isNotEmpty) {
        // Verificar que el primer mensaje tenga la clave 'text' y sea del tipo correcto
        if (message[0] is Map && message[0].containsKey("text") && message[0]["text"] is Map) {
          var textMap = message[0]["text"];
          
          if (textMap["text"] != null && textMap["text"] is List && textMap["text"].isNotEmpty) {
            var text = textMap["text"];
            setState(() {
              messsages.insert(0, {"data": 0, "message": text[0].toString()});
            });
            print("Texto del bot: ${text[0].toString()}");
          } else {
            print("El campo 'text' está vacío o no es una lista.");
          }
        } else {
          print("El mensaje no contiene un mapa 'text' válido.");
        }
      } else {
        print("No se detectó ninguna intención o la respuesta no contiene mensajes.");
      }
    } else {
      print("La respuesta de AIResponse es nula o no contiene mensajes.");
    }
  } catch (e) {
    print("Error al detectar la intención: $e");
  }
}






  final messageInsert = TextEditingController();
  List<Map> messsages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat bot",
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 15, bottom: 10),
              child: Text("Today, ${DateFormat("Hm").format(DateTime.now())}", style: TextStyle(
                fontSize: 20
              ),),
            ),
            Flexible(
                child: ListView.builder(
                    reverse: true,
                    itemCount: messsages.length,
                    itemBuilder: (context, index) => chat(
                        messsages[index]["message"].toString(),
                        messsages[index]["data"]))),
            SizedBox(
              height: 20,
            ),

            Divider(
              height: 5.0,
              color: Colors.greenAccent,
            ),
            Container(


              child: ListTile(

                  leading: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.greenAccent, size: 35,), onPressed: () {  },
                  ),

                  title: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(
                          15)),
                      color: Color.fromRGBO(220, 220, 220, 1),
                    ),
                    padding: EdgeInsets.only(left: 15),
                    child: TextFormField(
                      controller: messageInsert,
                      decoration: InputDecoration(
                        hintText: "Enter a Message...",
                        hintStyle: TextStyle(
                            color: Colors.black26
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),

                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black
                      ),
                      onChanged: (value) {

                      },
                    ),
                  ),

                  trailing: IconButton(

                      icon: Icon(

                        Icons.send,
                        size: 30.0,
                        color: Colors.greenAccent,
                      ),
                      onPressed: () {

                        if (messageInsert.text.isEmpty) {
                          print("empty message");
                        } else {
                          setState(() {
                            messsages.insert(0,
                                {"data": 1, "message": messageInsert.text});
                          });
                          response(messageInsert.text);
                          messageInsert.clear();
                        }
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      }),

              ),

            ),

            SizedBox(
              height: 15.0,
            )
          ],
        ),
      ),
    );
  }

  //for better one i have use the bubble package check out the pubspec.yaml

  Widget chat(String message, int data) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),

      child: Row(
          mainAxisAlignment: data == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [

            data == 0 ? Container(
              height: 60,
              width: 60,
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/bot.png"),
              ),
            ) : Container(),

        Padding(
        padding: EdgeInsets.all(10.0),
        child: Bubble(
            radius: Radius.circular(15.0),
            color: data == 0 ? Color.fromRGBO(23, 157, 139, 1) : Colors.orangeAccent,
            elevation: 0.0,

            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[

                  SizedBox(
                    width: 10.0,
                  ),
                  Flexible(
                      child: Container(
                        constraints: BoxConstraints( maxWidth: 200),
                        child: Text(
                          message,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ))
                ],
              ),
            )),
      ),

            data == 1? Container(
              height: 60,
              width: 60,
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/person.png"),
              ),
            ) : Container(),

          ],
        ),
    );
  }
}