import 'package:flutter/material.dart';
import 'package:ifeventos/views/event/new-event/new-event-title.dart';
import 'package:ifeventos/widgets/custom-card.dart';

class NewEventScreen extends StatefulWidget {
  @override
  _NewEventScreenState createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          "Criar Evento",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: CustomCard(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Aqui você vai poder criar um novo evento em 5 passos...\n\nVamos lá?",
                      style: Theme.of(context).textTheme.headline5.merge(
                        TextStyle(color: Colors.grey[600])
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              ),
            ),

            SizedBox(
              height: 50,
              width: double.maxFinite,
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewEventTitleScreen()),
                  );
                },
                color: Colors.green,
                child: Text(
                  "Continuar",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ]
        )
      )
    );
  }
}