import 'package:flutter/material.dart';
import 'package:jogo_math/back/back.dart';
import 'package:jogo_math/pages/game.dart';

class ConfigGame extends StatefulWidget {
  @override
  _ConfigGameState createState() => _ConfigGameState();
}

class _ConfigGameState extends State<ConfigGame> {

  int nivel = 1;

  List<int> niveis = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurar jogo"),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 15.0
                  ),
                  decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: DropdownButton<int>(
                      underline: SizedBox(),
                      icon: Icon(Icons.arrow_drop_down),
                      dropdownColor: Colors.lightGreen,
                      iconSize: 36.0,
                      isExpanded: true,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0
                      ),
                      value: nivel,
                      elevation: 1,
                      items:niveis.map<
                          DropdownMenuItem<int>>((v) {
                        return DropdownMenuItem<int>(
                            value: v,
                            child: Text('$v')
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          nivel = newValue;
                        });
                      }
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.all(Radius.circular(16))
                  ),
                  child: TextButton(
                      child: Text(
                        "Confirmar",
                        style: TextStyle(color: Colors.white,fontSize: 25.0),
                      ),
                      onPressed: () async {
                        Map<String,dynamic> cedulas = await Back.getData("https://rest-api-trimemoria.herokuapp.com/config/money");
                        if(cedulas.keys.contains("data")){
                          List<dynamic> data = cedulas["data"];
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Game(nivel: this.nivel, cedulas: data))
                          );
                        }
                      }
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

