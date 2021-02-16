import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ifeventos/views/articles/rate/rateArticle.dart';
import 'package:ifeventos/views/articles/sendArticles.dart';
import 'package:ifeventos/widgets/custom-dialog.dart';
import 'package:intl/intl.dart';
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
  DocumentSnapshot eventFull;
  bool _load = true;
  
  Map event = {
    "title": "VIII SEMIC - Semana de Iniciação Científica e Tecnológica 2020",
    "date": "12/12/2020",
    "hour": [
      { "begin": "08:00", "end": "11:00" },
      { "begin": "11:00", "end": "17:00" },
    ],
    "local": "IFCE Aracati - Rodovia CE-040, Km 137,1 s/n Aeroporto, CE"
  };

  List _articles = [
    {
      "title": "Sistema de Videomonitoramento Utilizando Reconhecimento Facial",
      "authors": [
        {
          "name": "Augusto Franco Soares de Moura",
          "presenter": true
        },
        {
          "name": "Carina Teixeira de Oliveira",
          "presenter": false
        }
      ],
      "evaluate": true,
      "local": "1° Andar",
      "code": "15",
      "hour": [
        { "begin": "08:00", "end": "11:00" }
      ]
    },
    {
      "title": "Aplicação de Tecnicas de Machine Learning na Análise Automatizada do Mercado Financeiro",
      "authors": [
        {
          "name": "Alexandre Pereira da Silva",
          "presenter": true
        }
      ],
      "evaluate": false,
      "local": "1° Andar",
      "code": "18",
      "hour": [
        { "begin": "08:00", "end": "11:00" }
      ]
    },
    {
      "title": "Mancha Branca? Antes e Hoje",
      "authors": [
        {
          "name": "Antônio José Felipe Cosme",
          "presenter": true
        }
      ],
      "evaluate": false,
      "local": "2° Andar",
      "code": "25",
      "hour": [
        { "begin": "13:00", "end": "17:00" }
      ]
    },
  ];

  @override
  void initState() {
    getEvent();
    super.initState();
  }

  getEvent() async {
    eventFull = await Firestore.instance.collection("events").document(widget.eventId).snapshots().first;

    setState(() {
      _load = false;
    });
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
          event["title"],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
                    // "http://prpi.ifce.edu.br/nl/e/?id=106",
                    eventFull.data["site"],
                    style: Theme.of(context).textTheme.headline6.merge(
                      TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline
                      )
                    )
                  ),
                  onTap: () => launch("http://prpi.ifce.edu.br/nl/e/?id=106"),
                ) : SizedBox(),
                
                // addInfo(first: "Data: ", last: "${event["date"]}"),
                addInfo(first: "Data: ", last: "${timestampToDateTimeFormated(eventFull.data["dateBegin"].seconds)}"),
                addInfo(first: "Horário: ", last: "${eventFull.data["hourBegin"]} às ${eventFull.data["hourEnd"]}"),
                addInfo(first: "Local: ", last: "${eventFull.data["local"]}")
              ],
            ),
          ),

          generateListArticles( e: _articles ),

          SizedBox(
            height: 50,
            width: double.maxFinite,
            child: RaisedButton(
              onPressed: _articles.indexWhere((e) => e["evaluate"] == false) >= 0 ? null :
              () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => CustomDialog(
                    title: "Avaliações Enviadas",
                    content: Column(
                      children: <Widget>[
                        Text(
                          "Suas avaliações foram enviadas com sucesso!",
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                    buttonText: "Ok"
                  ),
                );
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
          ),
        ],
      )
    );
  }

  Widget generateListArticles({ @required List e }) {
    List<Widget> articles = new List<Widget>();
    
    e.forEach((el) {
      articles.add(
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RateArticleScreen(project: el,)),
            );
          },
          child: Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.maxFinite,
                  child: Stack(
                    children: <Widget>[
                      Text(
                        el["title"], 
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
                            color: el["evaluate"] ? Colors.green : Colors.transparent,
                          ),
                        )
                      )
                    ],
                  ),
                ),
                Divider(),
                getAuthors(authors: el["authors"]),
                addInfo(
                  first: "Local: ",
                  last: el["local"],
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold
                ),
                addInfo(
                  first: "Número: ",
                  last: el["code"],
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold
                ),
                addInfo(
                  first: "Horário: ",
                  last: getHourEvent(hours: el["hour"]),
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