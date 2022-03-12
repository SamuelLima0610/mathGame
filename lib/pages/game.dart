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
  List numbers = [1, 2, 3, 4, 5];
  int numberOne;
  int numberTwo;
  int qntQuestion;
  String imageOne;
  String imageTwo;
  int count = 0;
  String operation;

  StreamSocket streamSocket = StreamSocket();

  _GameState(this.nivel,this.cedulas);

  @override
  void initState() {
    if(nivel == 2 || nivel == 4 || nivel == 6 || nivel == 8){
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
    numbers = [1, 2, 3, 4, 5];
    streamSocket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkOperation();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text(
            "FrutasFID",
            style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 35.0
            )
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: nivel > 2 ? ListView(
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
                    operation,
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
          ): ListView(
            children: [
              SizedBox(
                height: 40.0,
              ),
              numberOne <= 5 ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(numberOne, (index) {
                    return Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Image(
                          image: AssetImage(imageOne),
                          height: 70,
                          width: 70,
                        ),
                    );
                  }).toList()
              ): Center(
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Image(
                              image: AssetImage(imageOne),
                              height: 70,
                              width: 70,
                            ),
                          );
                        }).toList()
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(numberOne - 5, (index) {
                          return Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Image(
                              image: AssetImage(imageOne),
                              height: 70,
                              width: 70,
                            ),
                          );
                        }).toList()
                    )
                  ],
                ),
              ),
              numberTwo <= 5 ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(numberTwo, (index) {
                    return Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Image(
                        image: AssetImage(imageTwo),
                        height: 70,
                        width: 70,
                      ),
                    );
                  }).toList()
              ): Center(
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Image(
                              image: AssetImage(imageTwo),
                              height: 70,
                              width: 70,
                            ),
                          );
                        }).toList()
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(numberTwo - 5, (index) {
                          return Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Image(
                              image: AssetImage(imageTwo),
                              height: 70,
                              width: 70,
                            ),
                          );
                        }).toList()
                    )
                  ],
                ),
              )
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

  void checkOperation(){
    if(nivel == 3 || nivel == 4) operation = '+';
    else if(nivel == 5 || nivel == 6) operation = '-';
    else if(nivel == 7 || nivel == 8) operation = 'x';
  }

  void _checkAnswer(){
    bool isRight = false;
    int correctValue;
    print("c:$count");
    print("n:$nivel");
    if(nivel == 1 || nivel == 2)
      correctValue = numberOne + numberTwo;
    /*if(nivel == 3 || nivel == 4)
      correctValue = numberOne + numberTwo;
    else if(nivel == 5 || nivel == 6)
      correctValue = numberOne - numberTwo;
    else if(nivel == 7 || nivel == 8)*/
    print("cv:$correctValue");
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

  void _takeNumbers(){
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
      else if(answered.length == qntQuestion * 2){
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
        if(nivel == 5 || nivel == 6){
          if(numberOne < numberTwo){
            int aux = numberOne;
            numberOne = numberTwo;
            numberTwo = aux;
          }
        }
        answered.add(codeOne);
        answered.add(codeTwo);
        break;
      }
    }
  }
}
