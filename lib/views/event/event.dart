import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ifeventos/views/articles/homeArticles.dart';
import 'package:ifeventos/views/event/new-event/new-event.dart';
import 'package:ifeventos/widgets/custom-card.dart';
import 'package:ifeventos/widgets/custom-dialog-box.dart';
import 'package:intl/intl.dart';
import 'package:expandable/expandable.dart';

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {

  final user = GetStorage().read('userData');
  final userId = GetStorage().read('userId');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffD3D6DA),
      appBar: AppBar(
        title: Text(" Eventos",
                style: Theme.of(context).textTheme.headline5.merge(
                TextStyle(color: Colors.white))
        ),
        automaticallyImplyLeading: false,
        actions: [
          this.user["type"] == "GESTOR" ?
          IconButton(
            tooltip: "Adicionar Evento",
            icon: Icon(Icons.add_circle_outline, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewEventScreen()),
              );
            }
          ) : SizedBox()
        ],
      ),

      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance.collection("events").snapshots(),
                builder: (context, snapshot) {
                  switch(snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator()
                      );
                    default:
                      return 
                      SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                          child: Column(
                            children: [
                              ExpandablePanel(
                                header: session(title: ' Próximos eventos', color: Color(0xff313944), textColor: Colors.white),
                                collapsed: null,
                                expanded: generateListEventsTest(e: snapshot.data.documents, isAfter: true)
                              ),

                          

                              ExpandablePanel(
                                  header: session(title: ' Eventos finalizados', color: Color(0xffD40000), textColor: Colors.white),
                                  collapsed: null,
                                  expanded: generateListEventsTest(e: snapshot.data.documents, isAfter: false)
                              )
                            ],
                          ),
                        ),
                      );
                  }
                },
              )
            )
          ],
        )
      ),
      // body: ListView(
      //   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      //   children: <Widget>[
      //     session(title: 'Próximos eventos', color: Colors.green, textColor: Colors.white),
      //     generateListEvents(e: _pev),

      //     session(title: 'Eventos finalizados', color: Colors.orangeAccent, textColor: Colors.white),
      //     generateListEvents(e: _evf),
      //   ],
      // ),

    );
  }

  timestampToDateTimeFormated(seconds) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch((seconds - (60*60*3)) * 1000);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget generateListEventsTest({ @required List e, @required bool isAfter }) {
    List<Widget> events = new List<Widget>();

    e.forEach((el) {
      DateTime dateEvent = DateTime.fromMillisecondsSinceEpoch((el.data["dateEnd"].seconds - (60*60*3)) * 1000);
      DateTime dateNow = new DateTime.now();

      if(isAfter ? dateEvent.isAfter(dateNow) : dateEvent.isBefore(dateNow)) {
        events.add(
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeArticlesScreen(eventId: el.documentID)),
              );
            },
            child: Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Colors.white
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    el.data["title"], 
                    style: Theme.of(context).textTheme.headline6,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Divider(),
                  Text(
                    "Data: ${timestampToDateTimeFormated(el.data["dateBegin"].seconds)} à ${timestampToDateTimeFormated(el.data["dateEnd"].seconds)}",
                    style: Theme.of(context).textTheme.headline6.merge(
                      TextStyle(fontSize: 15)
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Horário:  ${el.data["hourBegin"]} às ${el.data["hourEnd"]}",
                    style: Theme.of(context).textTheme.headline6.merge(
                      TextStyle(fontSize: 15)
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Local: ${el.data["local"]}",
                    style: Theme.of(context).textTheme.headline6.merge(
                      TextStyle(fontSize: 15)
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  FutureBuilder(
                    future: isEvaluatorOfThisEvent(el.documentID),
                    builder: (context, snapshot) {
                      switch(snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator()
                          );
                        default:
                          return !snapshot.data && this.user["type"] == "AVALIADOR" && dateEvent.isAfter(dateNow) ?
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SizedBox(
                              height: 40,
                              width: double.maxFinite,
                              child: FlatButton(
                                disabledColor: Colors.grey,
                                color: Color(0xFF305745),
                                shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(color: Colors.transparent)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Quero ser avaliador", 
                                      style: TextStyle(
                                        color: Colors.white, 
                                        fontSize: 20
                                      ),
                                    )
                                  ],
                                ),
                                onPressed: () {
                                  Firestore.instance.collection("events")
                                    .document(el.documentID)
                                    .collection("evaluators")
                                    .document(userId)
                                    .setData({
                                      "userId": userId
                                    }).then((value) {
                                      Firestore.instance
                                        .collection("users").document(userId)
                                        .collection("events_attended").add({
                                          "eventId": el.documentID
                                        });
                                      setState(() {});
                                      
                                      showDialog(context: context,
                                        builder: (BuildContext context){
                                          return CustomDialogBox(
                                            title: "Tudo certo!",
                                            descriptions: "Você foi adicionado como avaliador neste evento. Em breve o coordenador deve alocar alguns trabalhos para você avaliar.",
                                            text: "Ok",
                                            icon: Icons.check,
                                            iconColor: Colors.white,
                                            color: Colors.greenAccent,
                                          );
                                        }
                                      );
                                    }).catchError((err) => {
                                      showDialog(context: context,
                                        builder: (BuildContext context){
                                          return CustomDialogBox(
                                            title: "Ops... :(",
                                            descriptions: "Desculpe!\nHouve um erro ao adicionar você como avaliador deste evento.\nQue tal tentar novamente?",
                                            text: "Voltar",
                                            icon: Icons.close,
                                            iconColor: Colors.white,
                                            color: Colors.redAccent
                                          );
                                        }
                                      )
                                    });
                                },
                              ),
                            ),
                          ) : SizedBox();
                      }
                    }
                  ),
                ],
              ),
            ),
          )
        );
      }
    });

    if(events.isEmpty) {
      events.add(
        CustomCard(
          body: Text(
            isAfter ? "Nenhum evento programado para acontecer." : "Nenhum evento finalizado",
            style: Theme.of(context).textTheme.headline6.merge(
              TextStyle(fontSize: 16)
            ),
          ),
        )
      );
    }

    return Column(
      children: events
    );
  }

  Future<bool> isEvaluatorOfThisEvent(String eventId) async {
    DocumentSnapshot evaluator = await Firestore.instance.collection("events").document(eventId).collection("evaluators").document(userId).snapshots().first;
    
    return evaluator.data != null;
  }

  Widget generateListEvents({ @required List e }) {
    List<Widget> events = new List<Widget>();
    
    e.forEach((el) {
      events.add(
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeArticlesScreen(eventId: el["id"])),
            );
          },
          child: Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  el["title"], 
                  style: Theme.of(context).textTheme.headline6,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Divider(),
                Text(
                  "Data: ${el["date"]}",
                  style: Theme.of(context).textTheme.headline6.merge(
                    TextStyle(fontSize: 15)
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Horário:  ${getHourEvent(hours: el["hour"])}",
                  style: Theme.of(context).textTheme.headline6.merge(
                    TextStyle(fontSize: 15)
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Local: ${el["local"]}",
                  style: Theme.of(context).textTheme.headline6.merge(
                    TextStyle(fontSize: 15)
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        )
      );
    });

    return Column(
      children: events
    );
  }

  String getHourEvent({ @required List hours }) {
    String h = "";
    
    hours.forEach((i) {
      h += "${i["begin"]} às ${i["end"]}; ";
    });

    return h.substring(0, h.length-2);
  }

  Widget session({ @required String title, @required Color color, @required Color textColor }) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(5),
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(6)
        ),
        color: color
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline5.merge(
          TextStyle(color: textColor)
        )
      ),
    );
  }

}