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
      backgroundColor: Color(0xffD3D6DA),
      appBar: AppBar(
        title: Text(
          "Criar Evento",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: Container(
        padding: EdgeInsets.fromLTRB(15, 10, 15, 20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: CustomCard(
                color: Color(0xffD3D6DA),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 80,
                      color: Color(0xff313944),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Aqui você vai poder criar um novo evento em 5 passos...\n\nVamos lá?",
                      style: Theme.of(context).textTheme.headline5.merge(
                        TextStyle(color: Color(0xff313944))
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
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewEventTitleScreen()),
                  );
                },
                style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(61.0),
                                ),
                              ),
                    ),
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