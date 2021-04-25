import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ifeventos/widgets/custom-card.dart';
import 'package:share/share.dart';

class ListEvaluationsScreen extends StatefulWidget {

  final String eventId;
  final String articleId;

  ListEvaluationsScreen({ @required this.eventId, @required this.articleId });

  @override
  _ListEvaluationsScreenState createState() => _ListEvaluationsScreenState();
}

class _ListEvaluationsScreenState extends State<ListEvaluationsScreen> {

  List<List> listOfLists = [
    [
      "Avaliador",
      "Não compareceu",
      "Na Introdução consta claramente a relevância do tema e os seus objetivos",
      "Fundamentação teórico-científica",
      "Adequação da metodologia ao tipo de trabalho",
      "Domínio do conteúdo na apresentação",
      "Qualidade da organização e apresentação do trabalho (recursos didáticos utilizados, slides e outros)"
    ]
  ];
  List data = [];
  DocumentSnapshot articleData;

  saveEvaluations() async {

    data.forEach((e) async {
      List row = [];
      DocumentSnapshot evaluator = await Firestore.instance.collection("users").document(e.data["idEvaluator"]).get();
      row.add(evaluator.data["name"]);
      row.add(e.data.containsKey("didNotAttend") && e.data["didNotAttend"] ? "Não compareceu" : "");
      row.add(e.data["clarity"]);
      row.add(e.data["reasoning"]);
      row.add(e.data["methodologyAdequacy"]);
      row.add(e.data["domain"]);
      row.add(e.data["quality"]);
      listOfLists.add(row);
    });

    String csv = const ListToCsvConverter().convert(listOfLists);

    String dir = (await getExternalStorageDirectory()).absolute.path;
    String file = "$dir" + "/avaliacao_${articleData.data["idProjeto"]}.csv";
      
    File f = new File(file);
    f.writeAsString(csv);
    Navigator.pop(context);
    Share.shareFiles([file], text: "Avaliações do Trabalho \"${articleData.data["titulo"]}\"");
  }

  getArticle() async {
    await Firestore.instance
      .collection("events").document(widget.eventId)
      .collection("articles").document(widget.articleId).get().then((value) => setState(() => articleData = value));
  }

  @override
  void initState() {
    getArticle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          "Avaliações Enviadas",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            tooltip: "Baixar Avaliações",
            onPressed: () {
              saveEvaluations();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context){
                  return Center(child: CircularProgressIndicator());
                }
              );
            }
          )
        ],
      ),

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: StreamBuilder(
          stream: Firestore.instance
            .collection("events").document(widget.eventId)
            .collection("articles").document(widget.articleId)
            .collection("evaluations").where("finished", isEqualTo: true).snapshots(),
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator()
                );
              default:
                if(snapshot.data.documents.length == 0) 
                  return Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Text(
                      "Nenhuma avaliação foi entregue",
                      style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(
                          fontSize: 16,
                        )
                      ),
                      textAlign: TextAlign.center,
                    )
                  );
                
                data = snapshot.data.documents;

                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (c, i) {
                    return CustomCard(
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(
                            future: Firestore.instance.collection("users").document(snapshot.data.documents[i].documentID).get(),
                            // ignore: missing_return
                            builder: (context, snapshot) {
                              switch(snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return SizedBox();
                                default:
                                  return Text(
                                    snapshot.data.data["name"].toString(),
                                    style: Theme.of(context).textTheme.headline6,
                                  );
                              }
                            }
                          ),
                          Divider(),

                            Visibility(
                              visible: !snapshot.data.documents[i].data.containsKey("didNotAttend") || !snapshot.data.documents[i].data["didNotAttend"],
                              child: Column(
                                children: [
                                  item(description: "Na Introdução consta claramente a relevância do tema e os seus objetivos:", value: snapshot.data.documents[i].data["clarity"]),
                                  SizedBox(height:15),
                                  item(description: "Fundamentação teórico-científica:", value: snapshot.data.documents[i].data["reasoning"]),
                                  SizedBox(height:15),
                                  item(description: "Adequação da metodologia ao tipo de trabalho:", value: snapshot.data.documents[i].data["methodologyAdequacy"]),
                                  SizedBox(height:15),
                                  item(description: "Domínio do conteúdo na apresentação:", value: snapshot.data.documents[i].data["domain"]),
                                  SizedBox(height:15),
                                  item(description: "Qualidade da organização e apresentação do trabalho (recursos didáticos utilizados, slides e outros):", value: snapshot.data.documents[i].data["quality"]),
                                ],
                              )
                            ),

                            Visibility(
                              visible: snapshot.data.documents[i].data.containsKey("didNotAttend") && snapshot.data.documents[i].data["didNotAttend"],
                              child: CustomCard(
                                color: Colors.yellow[100],
                                body: Text(
                                  "Apresentador não compareceu",
                                  style: Theme.of(context).textTheme.headline6.merge(
                                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              )
                            ),
                          
                        ],
                      ),
                    );
                  }
                );
            }
          }
        )
      )
    );
  }

  Widget item({ @required String description, @required double value }) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Text(
            description,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.green,
            child: Text(
              value.toString(),
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            )
          ),
        ),
      ]
    );
  }
}