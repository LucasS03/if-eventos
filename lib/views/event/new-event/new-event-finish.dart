import 'package:flutter/material.dart';
import 'package:ifeventos/views/home/home.dart';
import 'package:ifeventos/widgets/custom-card.dart';

class NewEventFinishScreen extends StatefulWidget {
  @override
  _NewEventFinishScreenState createState() => _NewEventFinishScreenState();
}

class _NewEventFinishScreenState extends State<NewEventFinishScreen> {
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
        automaticallyImplyLeading: false,
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
                      color: Colors.green,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Parabéns!\n\nO seu evento foi criado com sucesso :)",
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
                    MaterialPageRoute(builder: (context) => HomeApp()),
                  );
                },
                color: Colors.green,
                child: Text(
                  "Finalizar",
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