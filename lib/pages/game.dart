import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jogo_math/back/back.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

// STEP1:  Stream setup
class StreamSocket{
  final _socketResponse = StreamController<int>();

  void Function(int) get addResponse => _socketResponse.sink.add;

  Stream<int> get getResponse => _socketResponse.stream;

  void dispose(){
    _socketResponse.close();
  }
}

StreamSocket streamSocket = StreamSocket();

class Game extends StatefulWidget {

  final String theme;
  Map<String,dynamic> config;
  Game({this.theme,this.config});

  @override
  _GameState createState() => _GameState(this.theme,this.config);
}

class _GameState extends State<Game> {

  String theme;
  Map<String,dynamic> config;
  IO.Socket socket;
  List cards;
  StreamSocket streamSocket = StreamSocket();

  _GameState(this.theme,this.config);

  @override
  void initState() {
    connectAndListen();
    super.initState();
  }

  @override
  void dispose() {
    streamSocket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF8306),
        title: Text("Trimemória"),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container()
      ),
    );
  }

  //STEP2: Add this function in main function in main.dart file and add incoming data to the stream
  void connectAndListen(){
    socket = IO.io('https://rest-api-trimemoria.herokuapp.com',
        OptionBuilder()
            .setTransports(['websocket']).build());

    socket.onConnect((_) {
      print('connect');
    });

    //When an event recieved from server, data is added to the stream
    socket.on('tag', (data) {
      List<dynamic> display = config["configurationTag"];
      int index = 0;
      display.forEach((element) {
        Map<String,dynamic> map = element;
        if(map.values.first.toString() == data["detectedData"]){
          streamSocket.addResponse(index);
        }
        index++;
      });
    });
    socket.onDisconnect((_) => print('disconnect'));

  }

  String getLastCoordinate(List<dynamic> configTags){
    return configTags.last.keys.first.toString();
  }

}
