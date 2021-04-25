import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ifeventos/views/articles/allocate-article/allocateArticle.dart';
import 'package:ifeventos/views/articles/rate/rateArticle.dart';
import 'package:ifeventos/views/articles/sendArticles.dart';
import 'package:ifeventos/widgets/button-default.dart';
import 'package:ifeventos/widgets/custom-card.dart';
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
  bool _eventFinished = false;

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

      Navigator.pop(context);
      Share.shareFiles([file], text: "Avaliações do Evento \"${eventFull.data["title"]}\"");

    }).catchError((onError) {
      Navigator.pop(context);
      showDialog(context: context,
        builder: (BuildContext context){
          return CustomDialogBox(
            title: "Ops...",
            descriptions: "Desculpe! Tivemos um erro ao gerar o seu arquivo de avaliações. Caso o erro persista, contate o mantenedor do sistema.",
            text: "Ok",
            icon: Icons.pan_tool,
            iconColor: Colors.white,
            color: Colors.redAccent
          );
        }
      );
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

    DateTime dateEvent = DateTime.fromMillisecondsSinceEpoch(eventFull.data["dateEnd"].seconds * 1000);
    DateTime dateNow = new DateTime.now();
    if(dateEvent.isBefore(dateNow))
      setState(() => _eventFinished = true);
    
    setState(() => _load = false);
  }

  getArticlesByEvaluator() async {
    setState(() => _loadArticles = true);

    final evaluator = await Firestore.instance.
      collection("events").document(widget.eventId).
      collection("evaluators").document(userId).get();
    
    List list = [];
    
    if(evaluator != null && evaluator.data != null && evaluator.data.containsKey("articleIds")) 
      list = evaluator.data["articleIds"];

    list.forEach((el) async {
      DocumentSnapshot article = await Firestore.instance.
        collection("events").document(widget.eventId).
        collection("articles").document(el).snapshots().first;

      DocumentSnapshot evaluation = await Firestore.instance.
        collection("events").document(widget.eventId).
        collection("articles").document(el).collection("evaluations").document(userId).snapshots().first;
    
      setState(() {
        articlesFull.add(article);
        articlesEvaluated[el] = evaluation != null && evaluation.data != null && evaluation.data["finished"] != null ? true : false;
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
          // _load ? '...' : eventFull.data["title"],
          "Evento",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Editar evento
          Visibility(
            visible: this.user["type"] == "GESTOR",
            child: IconButton(
              icon: Icon(Icons.edit),
              tooltip: "Editar evento",
              onPressed: () {
                // Ir pra tela de editar evento
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => SendArticlesScreen(eventId: widget.eventId)),
                // );
              },
            )
          ),
          
          // Adicionar trabalhos
          Visibility(
            visible: this.user["type"] == "GESTOR",
            child: IconButton(
              icon: Icon(Icons.note_add),
              tooltip: "Adicionar trabalhos",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SendArticlesScreen(eventId: widget.eventId)),
                );
              },
            )
          ),
          
          // Compartilhar avaliações
          Visibility(
            visible: this.user["type"] == "GESTOR",
            child: IconButton(
              icon: Icon(Icons.share),
              tooltip: "Compartilhar avaliações",
              onPressed: () {
                getEvaluations();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context){
                    return Center(child: CircularProgressIndicator());
                  }
                );
              },
            )
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

          // Botão de finalizar evento
          Visibility(
            visible: this.user["type"] == "GESTOR",
            child: Column(
              children: [
                ButtonDefault(
                  title: "Finalizar Evento",
                  color: Colors.yellow[100],
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800]
                  ),
                  onTap: () async { 
                    await Firestore.instance.collection("events").document(widget.eventId).updateData({ "finished": true });
                    generateRanking();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context){
                        return Center(child: CircularProgressIndicator());
                      }
                    );
                  },
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

          // Informações do evento
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
                Text(
                  eventFull.data["title"],
                  style: Theme.of(context).textTheme.headline6.merge(
                    TextStyle(fontWeight: FontWeight.bold)
                  ),
                ),
                Divider(),
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

          Visibility(
            visible: _eventFinished || eventFull.data["finished"],
            child: CustomCard(
              body: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  "O evento já foi finalizado",
                  style: Theme.of(context).textTheme.headline6.merge(
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              color: Colors.yellow[100],
            ),
          ),

          Divider(),

          // Lista artigos
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
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    this.user["type"] == "GESTOR" ?
                                    "Você ainda não adicionou nenhum trabalho" : 
                                    snapshot.data ? "Nenhum trabalho atribuído à você" :
                                    "Você não é um avaliador deste evento",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text("Nenhum trabalho atribuído à você",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ) :
              Container(
                child: generateListArticlesTest( e: articlesFull )
              ),

          // Botão de entregar avaliações
          this.user["type"] == "AVALIADOR" ? 
          SizedBox(
            height: 50,
            width: double.maxFinite,
            child: RaisedButton(
              onPressed: articlesEvaluated.values.any((e) => e) || articlesFull.length == 0 || _eventFinished ? null : () async {
                
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

  generateRanking() async {
    List<Map<String, dynamic>> ranking = [];

    // buscar artigos
    QuerySnapshot articles = await Firestore.instance.collection("events").document(widget.eventId).collection("articles").getDocuments();
    
    // pra cada artigo buscar avaliacoes
    for(int i = 0; i < articles.documents.length; i++) {
      QuerySnapshot evaluations = await Firestore.instance.
        collection("events").document(eventFull.documentID).
        collection("articles").document(articles.documents[i].documentID).
        collection("evaluations").getDocuments();

      double sum = 0.0;

      for(int j = 0; j < evaluations.documents.length; j++) {
        // calcula soma das avaliações
        sum += evaluations.documents[j].data["clarity"];
        sum += evaluations.documents[j].data["reasoning"];
        sum += evaluations.documents[j].data["methodologyAdequacy"];
        sum += evaluations.documents[j].data["domain"];
        sum += evaluations.documents[j].data["quality"];
      }

      if(sum > 0) {
        sum = sum / evaluations.documents.length;
        sum = num.parse(sum.toStringAsFixed(1));
      } else {
        sum = 0.0;
      }

      // adiciona à lista
      ranking.add({
        "articleId": articles.documents[i].documentID,
        "articleTitle": articles.documents[i].data["titulo"],
        "evaluate": sum,
      });
    }

    // ordena lista
    ranking.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      return a["evaluate"] < b["evaluate"] ? 1 : 0;
    });

    // salva um por um no /events/:id/ranking
    ranking.forEach((e) {
      Firestore.instance.collection("events").document(widget.eventId).collection("ranking").document(e["articleId"]).setData(e);
    });

    Navigator.pop(context);
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