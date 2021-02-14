import 'package:flutter/material.dart';
import 'package:ifeventos/views/articles/homeArticles.dart';
import 'package:ifeventos/views/event/new-event/new-event.dart';

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {

  List _pev = [
    {
      "title": "VIII SEMIC - Semana de Iniciação Científica e Tecnológica 2020",
      "date": "12/12/2020",
      "hour": [
        { "begin": "08:00", "end": "11:00" },
        { "begin": "11:00", "end": "17:00" },
      ],
      "local": "IFCE Aracati - Rodovia CE-040, Km 137,1 s/n Aeroporto, CE"
    }
  ];

  List _evf = [
    {
      "title": "VIII SEMIC - Semana de Iniciação Científica e Tecnológica 2019",
      "date": "12/12/2019",
      "hour": [
        { "begin": "08:00", "end": "11:00" },
        { "begin": "11:00", "end": "17:00" },
      ],
      "local": "IFCE Aracati - Rodovia CE-040, Km 137,1 s/n Aeroporto, CE"
    },
    {
      "title": "VIII SEMIC - Semana de Iniciação Científica e Tecnológica 2018",
      "date": "12/12/2018",
      "hour": [
        { "begin": "08:00", "end": "11:00" },
        { "begin": "11:00", "end": "17:00" },
      ],
      "local": "IFCE Aracati - Rodovia CE-040, Km 137,1 s/n Aeroporto, CE"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text("Eventos"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: "Adicionar Evento",
            icon: Icon(Icons.add_circle_outline, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewEventScreen()),
              );
            }
          )
        ],
      ),

      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        children: <Widget>[
          session(title: 'Próximos eventos', color: Colors.green, textColor: Colors.white),
          generateListEvents(e: _pev),

          session(title: 'Eventos finalizados', color: Colors.orangeAccent, textColor: Colors.white),
          generateListEvents(e: _evf),
        ],
      ),

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
              MaterialPageRoute(builder: (context) => HomeArticlesScreen()),
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