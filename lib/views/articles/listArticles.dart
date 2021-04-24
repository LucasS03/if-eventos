import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ifeventos/views/articles/allocate-article/allocateArticle.dart';
import 'package:ifeventos/views/articles/rate/rateArticle.dart';
import 'package:ifeventos/views/articles/sendArticles.dart';
import 'package:ifeventos/widgets/custom-dialog-box.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:core';

class ListArticlesScreen extends StatefulWidget {

  final String eventId;
  ListArticlesScreen({ @required this.eventId });

  @override
  _ListArticlesScreenState createState() => _ListArticlesScreenState();
}

class _ListArticlesScreenState extends State<ListArticlesScreen> {

  final user = GetStorage().read('userData');
  final userId = GetStorage().read('userId');
  DocumentSnapshot eventFull;
  List<DocumentSnapshot> articlesFull = new List<DocumentSnapshot>();
  Map<String, bool> articlesEvaluated = {};
  bool _load = true;
  bool _loadArticles = false;
  List<Map<String, dynamic>> options = [
    { 
      "option": "Compartilhar avaliações", 
      "icon": Icons.share
    }
  ];

  List data = [];
  List<List> listOfLists = [
    [
      "Trabalho",
      "Avaliador",
      "Não compareceu",
      "Na Introdução consta claramente a relevância do tema e os seus objetivos",
      "Fundamentação teórico-científica",
      "Adequação da metodologia ao tipo de trabalho",
      "Domínio do conteúdo na apresentação",
      "Qualidade da organização e apresentação do trabalho (recursos didáticos utilizados, slides e outros)"
    ]
  ];

  getEvaluations() async {
    print("Get evaluations");
    // Puxa todos os Artigos
    await Firestore.instance.collection("events").document(widget.eventId).collection("articles").getDocuments().then((value) async {
      // pra cada artigo, puxa as avaliações
      for(int i = 0; i < value.documents.length; i++) {
        QuerySnapshot evaluations = await Firestore.instance.
          collection("events").document(widget.eventId).
          collection("articles").document(value.documents[i].documentID).
          collection("evaluations").getDocuments();

        // pra cada avaliação, monta a lista e adiciona à lista de listas
        for(int j = 0; j < evaluations.documents.length; j++) {
          List row = [];
          DocumentSnapshot evaluator = await Firestore.instance.collection("users").document(evaluations.documents[j].data["idEvaluator"]).get();

          row.add(value.documents[i].data["titulo"]);
          row.add(evaluator.data["name"]);
          row.add(evaluations.documents[j].data.containsKey("didNotAttend") && evaluations.documents[j].data["didNotAttend"] ? "Não compareceu" : "");
          row.add(evaluations.documents[j].data["clarity"]);
          row.add(evaluations.documents[j].data["reasoning"]);
          row.add(evaluations.documents[j].data["methodologyAdequacy"]);
          row.add(evaluations.documents[j].data["domain"]);
          row.add(evaluations.documents[j].data["quality"]);
          listOfLists.add(row);
        }

        // Pular linha
        listOfLists.add([]);
      }

      String csv = const ListToCsvConverter().convert(listOfLists);

      String dir = (await getExternalStorageDirectory()).absolute.path;
      String file = "$dir" + "/avaliacoes_${eventFull.data["title"]}.csv";
        
      File f = new File(file);
      f.writeAsString(csv);
      Share.shareFiles([file], text: "Avaliações do Evento \"${eventFull.data["title"]}\"");

    }).catchError((onError) {
      print("Erro ao puxar os trabalhos");
      // TODO: adicionar modal de erro
    });
  }

  @override
  void initState() {
    getEvent();

    super.initState();
  }

  getEvent() async {
    eventFull = await Firestore.instance.collection("events").document(widget.eventId).snapshots().first;
    if(this.user["type"] == "AVALIADOR")
      await getArticlesByEvaluator();

    setState(() {
      _load = false;
    });
  }

  getArticlesByEvaluator() async {
    setState(() => _loadArticles = true);

    final evaluator = await Firestore.instance.
      collection("events").document(widget.eventId).
      collection("evaluators").document(userId).get();
    
    List list = evaluator.data["articleIds"];

    list.forEach((el) async {
      DocumentSnapshot article = await Firestore.instance.
        collection("events").document(widget.eventId).
        collection("articles").document(el).snapshots().first;

      DocumentSnapshot evaluation = await Firestore.instance.
        collection("events").document(widget.eventId).
        collection("articles").document(el).collection("evaluations").document(userId).snapshots().first;
    
      setState(() {
        articlesFull.add(article);
        articlesEvaluated[el] = evaluation.data != null ? true : false;
      });
    });

    setState(() => _loadArticles = false);
  }

  Future<bool> isEvaluatorOfThisEvent(String eventId) async {
    DocumentSnapshot evaluator = await Firestore.instance.collection("events").document(eventId).collection("evaluators").document(userId).snapshots().first;
    return evaluator != null && evaluator.data != null;
  }

  timestampToDateTimeFormated(seconds) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          _load ? '...' : eventFull.data["title"],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Visibility(
            visible: this.user["type"] == "GESTOR",
            child: PopupMenuButton<Map<String, dynamic>>(
              elevation: 3.2,
              tooltip: 'Mais opções',
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context) {
                return options.map((Map<String, dynamic> option) {
                  return PopupMenuItem<Map<String, dynamic>>(
                    value: option,
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal
                    ),
                    child: InkWell(
                      onTap: () {
                        getEvaluations();
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(option["icon"], color: Colors.black),
                          SizedBox(width:5),
                          Text(
                            option["option"], 
                            style: TextStyle(
                              fontSize: 16
                            )
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          )
        ],
      ),

      body: _load ?
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Center(
            child: CircularProgressIndicator()
          ),
        ) :
        ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        children: <Widget>[
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Visibility(
                  visible: this.user["type"] == "GESTOR",
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                        width: double.maxFinite,
                        child: RaisedButton(
                          onPressed: () { 
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SendArticlesScreen(eventId: widget.eventId)),
                            );
                          },
                          color: Colors.green,
                          child: Text(
                            "Adicionar Trabalhos",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                eventFull.data["site"] != "" ?
                Text(
                  "Site do evento:",
                  style: Theme.of(context).textTheme.headline6.merge(
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
                  ),
                ) : SizedBox(),
                eventFull.data["site"] != "" ?
                InkWell(
                  child: Text(
                    eventFull.data["site"],
                    style: Theme.of(context).textTheme.headline6.merge(
                      TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline
                      )
                    )
                  ),
                  onTap: () => launch(eventFull.data["site"]),
                ) : SizedBox(),
                
                // addInfo(first: "Data: ", last: "${event["date"]}"),
                addInfo(first: "Data: ", last: "${timestampToDateTimeFormated(eventFull.data["dateBegin"].seconds)}"),
                addInfo(first: "Horário: ", last: "${eventFull.data["hourBegin"]} às ${eventFull.data["hourEnd"]}"),
                addInfo(first: "Local: ", last: "${eventFull.data["local"]}")
              ],
            ),
          ),

          _loadArticles ? 
            Center(
              child: CircularProgressIndicator()
            ) :
            this.user["type"] == "GESTOR" ? 
            StreamBuilder(
              stream: Firestore.instance.collection("events").document(widget.eventId).collection("articles").snapshots(),
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
                        child: FutureBuilder(
                          future: isEvaluatorOfThisEvent(widget.eventId),
                          // ignore: missing_return
                          builder: (context, snapshot) {
                            switch(snapshot.connectionState) {
                              default:
                                return Text(
                                  this.user["type"] == "GESTOR" ?
                                  "Você ainda não adicionou nenhum trabalho" : 
                                  snapshot.data ? "Nenhum trabalho atribuído à você" :
                                  "Você não é um avaliador deste evento",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                            }
                          }
                        )
                      );

                    return Container(
                      child: generateListArticlesTest( e: snapshot.data.documents )
                    );
                }
              }
            ) : 
            articlesFull.length == 0  ? 
              Text("Nenhum trabalho atribuído à você",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ) :
              Container(
                child: generateListArticlesTest( e: articlesFull )
              ),

          this.user["type"] == "AVALIADOR" ? 
          SizedBox(
            height: 50,
            width: double.maxFinite,
            child: RaisedButton(
              onPressed: articlesEvaluated.values.any((e) => !e) ? null : () async {
                
                try {
                  DocumentSnapshot evaluatorData = await Firestore.instance.
                    collection("events").document(widget.eventId).
                    collection("evaluators").document(userId).snapshots().first;
                  
                  List articleIds = evaluatorData.data["articleIds"];
                  articleIds.forEach((article) async {
                    await Firestore.instance.
                      collection("events").document(widget.eventId).
                      collection("articles").document(article).
                      collection("evaluations").document(userId).updateData({ "finished": true });
                  });

                  showDialog(context: context,
                    builder: (BuildContext context){
                      return CustomDialogBox(
                        title: "Avaliações enviadas!",
                        descriptions: "Pronto! Todas suas avaliações foram entregues ao coordenador do evento e não será mais possível editá-las.\nObrigado por participar!",
                        text: "Ok",
                        icon: Icons.thumb_up_alt,
                        iconColor: Colors.white,
                        color: Colors.greenAccent,
                      );
                    }
                  );
                } catch (e) {
                  showDialog(context: context,
                    builder: (BuildContext context){
                      return CustomDialogBox(
                        title: "Ops...",
                        descriptions: "Desculpe! Tivemos um erro ao enviar suas avaliações. Caso o erro persista, contate o coordenador do evento.",
                        text: "Ok",
                        icon: Icons.pan_tool,
                        iconColor: Colors.white,
                        color: Colors.redAccent
                      );
                    }
                  );
                }
                
              },
              color: Colors.green,
              child: Text(
                "Entregar Avaliações",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),
            ),
          ): SizedBox(),
        ],
      )
    );
  }

  Widget generateListArticlesTest({ @required List e }) {
    List<Widget> articles = new List<Widget>();
    
    e.forEach((el) {
      articles.add(
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => 
                this.user["type"] == "AVALIADOR" ? 
                  RateArticleScreen(eventId: eventFull.documentID, projectId: el.documentID) :
                  AllocateArticleScreen(eventId: eventFull.documentID, articleId: el.documentID)
              ),
            );
          },
          child: Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white,
              border: Border.all(
                color: !articlesEvaluated.containsKey(el.documentID) ? Colors.transparent : articlesEvaluated.containsKey(el.documentID) && articlesEvaluated[el.documentID] ? Colors.green : Colors.yellow,
                width: 2
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.maxFinite,
                  child: Stack(
                    children: <Widget>[
                      Text(
                        el.data["titulo"],
                        style: Theme.of(context).textTheme.headline6,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Positioned(
                        right: 0,
                        child: Tooltip(
                          message: "Trabalho Avaliado",
                          child: Icon(
                            Icons.check_circle,
                            color: articlesEvaluated.containsKey(el.documentID) && articlesEvaluated[el.documentID] ? Colors.green : Colors.transparent,
                            size: 30,
                          ),
                        )
                      )
                    ],
                  ),
                ),
                Divider(),
                getAuthorsTest(name: el.data["nome"]),
                addInfo(
                  first: "Local: ",
                  // last: el["local"],
                  last: "???",
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold
                ),
                addInfo(
                  first: "Número: ",
                  // last: el["code"],
                  last: "???",
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold
                ),
                addInfo(
                  first: "Horário: ",
                  // last: getHourEvent(hours: el["hour"]),
                  last: "???",
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold
                ),
              
              ],
            ),
          ),
        )
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: articles
    );
  }

  Widget getAuthorsTest({ @required String name }) {

    int apresentadores = 0;
    String a = "";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // RichText(
        //   text: TextSpan(
        //     text: "Apresentador:",
        //     style: TextStyle(
        //       color: Colors.grey[600],
        //       fontWeight: FontWeight.bold
        //     ),
        //     children: [
        //       TextSpan(
        //         text: name,
        //         style: Theme.of(context).textTheme.caption.merge(
        //           TextStyle(fontSize: 14, color: Colors.grey[600],)
        //         )
        //       )
        //     ]
        //   )
        // ),
        RichText(
          text: TextSpan(
            text: "Autor: ",
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold
            ),
            children: [
              TextSpan(
                text: name,
                style: Theme.of(context).textTheme.caption.merge(
                  TextStyle(fontSize: 14, color: Colors.grey[600],)
                )
              )
            ]
          )
        )
      ],
    );
  }

  Widget getAuthors({ @required List authors }) {

    int apresentadores = 0;
    String a = "";
    authors.forEach((e) {
      if(e["presenter"]) {
        a += " ${e["name"]}";
        apresentadores++;
      }
    });

    String s = "";
    authors.forEach((el) => s += " ${el["name"]};");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            text: apresentadores > 1 ? "Apresentadores:" : "Apresentador:",
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold
            ),
            children: [
              TextSpan(
                text: a,
                style: Theme.of(context).textTheme.caption.merge(
                  TextStyle(fontSize: 14, color: Colors.grey[600],)
                )
              )
            ]
          )
        ),
        RichText(
          text: TextSpan(
            text: authors.length > 1 ? "Autores:" : "Autor:",
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold
            ),
            children: [
              TextSpan(
                text: s,
                style: Theme.of(context).textTheme.caption.merge(
                  TextStyle(fontSize: 14, color: Colors.grey[600],)
                )
              )
            ]
          )
        )
      ],
    );
  }

  Widget addInfo({ 
    @required String first,
    @required String last,
    double fontSize: 16,
    Color color,
    FontWeight fontWeight: FontWeight.w600 }) {

    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        text: first,
        style: Theme.of(context).textTheme.headline6.merge(
          TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color
          )
        ),
        children: <TextSpan>[
          TextSpan(
            text: last,
            style: Theme.of(context).textTheme.headline6.merge(
              TextStyle(
                fontSize: fontSize,
                color: color
              )
            ),
          )
        ],
      ),
    );
  }

  String getHourEvent({ @required List hours }) {
    String h = "";
    
    hours.forEach((i) {
      h += "${i["begin"]} às ${i["end"]}; ";
    });

    return h.substring(0, h.length-2);
  }
}