import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ifeventos/views/articles/homeArticles.dart';
import 'package:ifeventos/views/event/new-event/new-event.dart';
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {

  final user = GetStorage().read('userData');
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text("Eventos"),
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
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Column(
                            children: [
                              session(title: 'Próximos eventos', color: Colors.green, textColor: Colors.white),
                              // TODO: dateEnd > date.now()
                              generateListEventsTest(e: snapshot.data.documents),
                              
                              session(title: 'Eventos finalizados', color: Colors.orangeAccent, textColor: Colors.white),
                              // TODO: dateEnd < date.now()
                              generateListEventsTest(e: snapshot.data.documents),
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
    DateTime date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget generateListEventsTest({ @required List e }) {
    List<Widget> events = new List<Widget>();

    e.forEach((el) {
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
          Radius.circular(3)
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