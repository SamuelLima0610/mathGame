import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:jogo_math/models/DataModel.dart';

class CoinRFID extends StatefulWidget {

  @override
  _CoinRFIDState createState() => _CoinRFIDState();
}

class _CoinRFIDState extends State<CoinRFID> {

  final _valueController = TextEditingController();
  final _tagController = TextEditingController();
  final _nameController = TextEditingController();

  final _stateForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(5.0),
        child: ScopedModelDescendant<DataModel>(
            builder: (context, child, model){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Form(
                    key: _stateForm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              hintText: 'Identificação',
                              hintStyle: TextStyle(
                                color: Colors.lightGreen,
                              )
                          ),
                          // ignore: missing_return
                          validator: (value){
                            if(value.isEmpty) return "O campo deve ser preenchido";
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          controller: _valueController,
                          decoration: InputDecoration(
                              hintText: 'Valor da cédula',
                              hintStyle: TextStyle(
                                  color: Colors.lightGreen,
                              )
                          ),
                          // ignore: missing_return
                          validator: (value){
                            if(value.isEmpty) return "O campo deve ser preenchido";
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          controller: _tagController,
                          decoration: InputDecoration(
                              hintText: 'Tag do cartão RFID',
                              hintStyle: TextStyle(
                                  color: Colors.lightGreen
                              )
                          ),
                          // ignore: missing_return
                          validator: (value){
                            if(value.isEmpty) return "O campo deve ser preenchido";
                          },
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        SizedBox(
                          height: 45.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.lightGreen,
                                    borderRadius: BorderRadius.all(Radius.circular(16))
                                ),
                                child: TextButton(
                                  onPressed: () async {
                                    if(_stateForm.currentState.validate()){
                                      Map<String,dynamic> data ={
                                        "name": _nameController.text,
                                        "value": _valueController.text,
                                        "tag": _tagController.text,
                                      };
                                      String answer = await model.insert(data: data);
                                      final snackBar = SnackBar(
                                        content: Text(
                                            answer
                                        ),
                                        duration: Duration(seconds: 5),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                  },
                                  child: Text(
                                      !model.toEdit() ? 'Salvar' : "Editar",
                                      style: TextStyle(color: Colors.white,fontSize: 22.0)
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.lightGreen,
                                  borderRadius: BorderRadius.all(Radius.circular(16))
                                ),
                                child: TextButton(
                                  onPressed: () async {
                                    if(!model.toEdit()){
                                      setState(() {
                                        _nameController.text = '';
                                        _valueController.text = '';
                                        _tagController.text = "";
                                      });
                                      model.refresh();
                                    }else{
                                      if(_stateForm.currentState.validate()) {
                                        String answer = await model.destroy();
                                        final snackBar = SnackBar(
                                          content: Text(
                                              answer
                                          ),
                                          duration: Duration(seconds: 5),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            snackBar);
                                      }
                                    }
                                  },
                                  child: Text(
                                      model.toEdit() ? "Excluir" : 'Limpar',
                                      style: TextStyle(color: Colors.white,fontSize: 22.0)
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  FutureBuilder(
                      future: model.getList(),
                      builder: (context,snapshot){
                        if(!snapshot.hasData)
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        else
                          return SafeArea(
                              child: makeTable(
                                  snapshot.data.length,
                                  snapshot.data,
                                  model
                              )
                          );
                      }
                  )
                ],
              );
            }
        )
    );
  }

  Widget makeTable(int size, List themes, DataModel model){
    var dts = DTS(themes, model,
        (index) async{
          await model.change(id: themes[index]['id']);
          setState(() {
            _nameController.text = model.information['data']['name'];
            _valueController.text = model.information['data']['value'];
            _tagController.text = model.information['data']['tag'];
          });
        });
    return PaginatedDataTable(
        header: Text('Cartões do jogo'),
        columns: const <DataColumn>[
          DataColumn(
              label: Text("Id",style: TextStyle(fontStyle: FontStyle.italic),)
          ),
          DataColumn(
              label: Text(
                "Nome",
                style: TextStyle(fontStyle: FontStyle.italic),
              )
          ),
          DataColumn(
              label: Text(
                "Valor",
                style: TextStyle(fontStyle: FontStyle.italic),
              )
          ),
          DataColumn(
              label: Text(
                "Tag RFID",
                style: TextStyle(fontStyle: FontStyle.italic),
              )
          ),
        ],
        source: dts,
        rowsPerPage: 5,
    );
  }
}

class DTS extends DataTableSource{

  List themes;
  DataModel model;
  Function update;

  DTS(this.themes,this.model,this.update);

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(
        onSelectChanged: (v) async{
          update(index);
        },
        index: index,
        cells: [
          DataCell(Text('${themes[index]['id']}')),
          DataCell(Text('${themes[index]['name']}')),
          DataCell(Text('${themes[index]['value']}')),
          DataCell(Text('${themes[index]['tag']}'))
        ]
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => themes.length;

  @override
  int get selectedRowCount => 0;

}



