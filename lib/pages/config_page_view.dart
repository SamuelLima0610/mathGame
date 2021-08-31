import 'package:flutter/material.dart';
import 'package:jogo_math/models/DataModel.dart';
import 'package:jogo_math/tabs/coin_rfid.dart';
import 'package:jogo_math/tabs/tcp_device.dart';
import 'package:scoped_model/scoped_model.dart';

// ignore: must_be_immutable
class ConfigPageView extends StatelessWidget {

  PageController pageController;

  @override
  Widget build(BuildContext context) {
    Color green = Colors.lightGreen;
    return PageView(
      controller: pageController,
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text("Cédulas",style: TextStyle(color: Colors.white),),
            centerTitle: true,
            backgroundColor: green,
          ),
          body: ScopedModel(
              model: DataModel('https://rest-api-trimemoria.herokuapp.com/config/themes'),
              child: CoinRFID()
          ),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Configuração do dispositivo",
                style: TextStyle(color: Colors.white)
            ),
            backgroundColor: green,
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: TcpDevice() //TcpDevice(),
        ),
      ],
    );
  }
}
