import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jogo_math/pages/home.dart';
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

  final int nivel;
  List<dynamic> cedulas;

  Game({this.nivel,this.cedulas});

  @override
  _GameState createState() => _GameState(this.nivel,this.cedulas);
}

class _GameState extends State<Game> {

  int nivel;
  List<dynamic> cedulas;
  IO.Socket socket;
  List<int> answered = [];
  List numbers = [1,2,3,4,5];
  int numberOne;
  int numberTwo;
  int qntQuestion;
  String imageOne;
  String imageTwo;
  int count = 0;

  StreamSocket streamSocket = StreamSocket();

  _GameState(this.nivel,this.cedulas);

  @override
  void initState() {
    if(nivel > 1){
      qntQuestion = 20;
      numbers.addAll([6, 7, 8, 9, 10]);
    }else{
      qntQuestion = 10;
    }
    _takePictures();
    _takeNumbers();
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
        backgroundColor: Colors.lightGreen,
        title: Text(
            "Frutas",
            style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 35.0
            )
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: ListView(
            children: [
              SizedBox(
                height: 80.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image(
                          image: AssetImage(imageOne),
                          height: 100,
                          width: 100,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "$numberOne",
                        style: TextStyle(
                            color: Colors.lightGreen,
                            decoration: TextDecoration.none,
                            fontSize: 60.0
                        ),
                      ),
                    ],
                  ),
                  Text(
                    nivel <= 2 ?  "+" : 'x',
                    style: TextStyle(
                        color: Colors.lightGreen,
                        decoration: TextDecoration.none,
                        fontSize: 40.0
                    ),
                  ),
                  Column(
                   children: [
                     Image(
                         image: AssetImage(imageTwo),
                         height: 100,
                         width: 100,
                     ),
                     SizedBox(
                       height: 20.0,
                     ),
                     Text(
                       "$numberTwo",
                       style: TextStyle(
                           color: Colors.lightGreen,
                           decoration: TextDecoration.none,
                           fontSize: 60.0
                       ),
                     ),
                   ],
                  )
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
            ],
          )
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
    socket.on('count', (data) {
      print(data);
      int index = cedulas.indexWhere((element) => element['tag'] == data['detectedData']);
      if(index != -1){
        Map<String, dynamic> cedula = cedulas[index];
        int value = int.parse(cedula['value']);
        if(value == 100){
          _checkAnswer();
          _takePictures();
          _takeNumbers();
          setState(() {
            count = 0;
          });
        }else count+=value;
        print(count);
      }
    });
    socket.onDisconnect((_) => print('disconnect'));
  }

  void _checkAnswer(){
    bool isRight = false;
    int correctValue;
    if(nivel <= 2 )
      correctValue = numberOne + numberTwo;
    else
      correctValue = numberOne * numberTwo;
    if(correctValue == count){
      isRight = true;
    }
    final snackBar = SnackBar(
      content: Text(
        isRight ? "Acertou": "Errou",
        style: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
            fontSize: 40.0
        ),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: isRight ? Colors.lightGreen : Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(
        snackBar);
  }

  int _generateNumber(int length) {
    Random numeroAleatorio = new Random();
    return numeroAleatorio.nextInt(length);
  }

  void _takePictures(){
    int indexFigureOne = _generateNumber(5);
    int indexFigureTwo = _generateNumber(5);
    if(indexFigureOne == indexFigureTwo){
      indexFigureOne == 0 ? indexFigureTwo++:indexFigureTwo--;
    }
    imageOne = getPathPicture(indexFigureOne);
    imageTwo = getPathPicture(indexFigureTwo);
  }

  String getPathPicture(int index){
    String path;
    switch(index){
      case 0:
        path = 'assets/apple.png';
        break;
      case 1:
        path = 'assets/lime.png';
        break;
      case 2:
        path = 'assets/watermelon.png';
        break;
      case 3:
        path = 'assets/strawberry.png';
        break;
      case 4:
        path = 'assets/banana.png';
        break;
    }
    return path;
  }

  bool _takeNumbers(){
    int indexOne, indexTwo, auxOne, auxTwo, codeOne,codeTwo;
    int calculate = 10;
    while(true){
      calculate--;
      indexOne = _generateNumber(numbers.length);
      indexTwo = _generateNumber(numbers.length);
      auxOne = numbers[indexOne];
      auxTwo = numbers[indexTwo];
      codeOne = auxOne * 10 +  auxTwo;
      codeTwo = auxTwo * 10 +  auxOne;
      if(calculate == 0)  break;
      else if(answered.length == qntQuestion){
        showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                title: Text(
                    "Aviso",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0
                    )
                ),
                backgroundColor: Color(0xff3EC300),
                content: Text(
                    "Parabéns!!! Deseja jogar proximo nível?",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0
                    )
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Home())
                      );
                    },
                    child: const Text(
                        'Não',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0
                        )
                    ),
                  ),
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Game(nivel: this.nivel+1, cedulas: cedulas))
                        );
                        return Future.value(false);
                      },
                      child: const Text(
                          'Sim',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0
                          )
                      )
                  )
                ],
              );
            }
        );
      }
      else if(answered.contains(codeOne) || answered.contains(codeTwo)) continue;
      else{
        numberOne = auxOne;
        numberTwo = auxTwo;
        answered.add(numberOne * 10 + numberTwo);
        break;
      }
    }
  }
}
