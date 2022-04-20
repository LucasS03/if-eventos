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
      backgroundColor: Color(0xffD3D6DA),
      appBar: AppBar(
        title: Text(
          "Criar Evento",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        automaticallyImplyLeading: false,
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
                      "Parabéns!\n\nO seu evento foi criado com sucesso!",
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
                    MaterialPageRoute(builder: (context) => HomeApp()),
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