import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ifeventos/widgets/custom-dialog-box.dart';

class SendArticlesScreen extends StatefulWidget {
  final String eventId;
  SendArticlesScreen({@required this.eventId});

  @override
  _SendArticlesScreenState createState() => _SendArticlesScreenState();
}

class _SendArticlesScreenState extends State<SendArticlesScreen> {
  DocumentSnapshot eventFull;
  String _typeFile = "CSV";

  getEvent() async {
    eventFull = await Firestore.instance
        .collection("events")
        .document(widget.eventId)
        .snapshots()
        .first;
  }

  getFile() async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv'],
          allowMultiple: false);

      if (result != null) {
        PlatformFile file = result.files.first;
        print(file.name);
        print(file.bytes);
        print(file.size);
        print(file.extension);
        print(file.path);

        final input = new File(file.path).openRead();

        final fields = await input
            .transform(latin1.decoder)
            .transform(new CsvToListConverter(fieldDelimiter: ';'))
            .toList();

        for (var t in fields) {
          Map<String, dynamic> map = {
            "idProjeto": t[0],
            "titulo": t[1],
            "area": t[2],
            "nome": t[3],
            //"titulo": t[4],
            "resumo": t[5],
            //"area": t[6],
            //"nome": t[7],
            "pdf": t[8]
          };

          Firestore.instance
              .collection("events")
              .document(widget.eventId)
              .collection("articles")
              .add(map)
              .then((value) => {})
              .catchError((err) => {print(err)});
        }

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: "Tudo certo!",
                descriptions:
                    "Os trabalhos foram enviados e já estão disponíveis para ser alocados.",
                text: "Voltar",
                icon: Icons.check,
                iconColor: Colors.white,
                color: Colors.greenAccent,
                skipScreen: true,
              );
            });
      } else {
        print("captura cancelada");
      }
    } catch (err) {
      print(err);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
                title: "Ops... :(",
                descriptions:
                    "Desculpe, tivemos algum erro com o envio do seu arquivo.",
                text: "Tentar Novamente",
                icon: Icons.close,
                iconColor: Colors.white,
                color: Colors.redAccent);
          });
    }
  }

  @override
  void initState() {
    getEvent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          "Submissão de Trabalhos",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.fromLTRB(8.0, 7.0, 8.0, 0.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Colors.yellow[100]),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Caro, organizador!\nO arquivo para submissão deve ser baixado na plataforma NL "
                    "com as seguintes configurações:\n"
                    "• Tipo de arquivo: .csv\n"
                    "• Separador de linha: CLRF\n"
                    "• Separador de colunas: ; (ponto e vírgula)\n"
                    "• Delimitador de texto: \" (aspas duplas)\n",
                    style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: SingleChildScrollView(
                child: Container(
              width: double.maxFinite,
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Column(children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      "Tipo de arquivo: ",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: DropdownButton<dynamic>(
                          icon: Icon(Icons.keyboard_arrow_down),
                          isExpanded: true,
                          value: _typeFile,
                          onChanged: (newValue) {
                            setState(() {
                              _typeFile = newValue;
                            });
                          },
                          items: [
                            DropdownMenuItem<dynamic>(
                                value: "CSV", child: Text("arquivo .csv")),
                          ]),
                    )
                  ],
                ),
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: RaisedButton(
                    onPressed: () {
                      getFile();
                    },
                    color: Colors.green,
                    child: Text(
                      "Selecionar Arquivo",
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),

                // SizedBox(height: 20),
                // SizedBox(
                //   height: 50,
                //   width: double.maxFinite,
                //   child: RaisedButton(
                //     onPressed: () {

                //     },
                //     color: Colors.green,
                //     child: Text(
                //       "Enviar Arquivo",
                //       style: TextStyle(
                //         fontFamily: 'Nunito',
                //         fontSize: 18,
                //         fontWeight: FontWeight.w600,
                //         color: Colors.white
                //       ),
                //     ),
                //   ),
                // )
              ]),
            )),
          )
        ],
      ),
    );
  }
}
