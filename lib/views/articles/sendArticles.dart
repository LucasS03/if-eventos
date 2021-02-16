import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SendArticlesScreen extends StatefulWidget {

  final String eventId;
  SendArticlesScreen({ @required this.eventId });

  @override
  _SendArticlesScreenState createState() => _SendArticlesScreenState();
}

class _SendArticlesScreenState extends State<SendArticlesScreen> {

  DocumentSnapshot eventFull;
  String _typeFile = "CSV";

  getEvent() async {
    eventFull = await Firestore.instance.collection("events").document(widget.eventId).snapshots().first;
  }

  @override
  void initState() {
    getEvent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          "Submissão de Trabalhos",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              children: <Widget> [
                Row(
                  children: <Widget>[
                    Text(
                      "Tipo de arquivo: ",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: DropdownButton<dynamic>(
                        icon: Icon(Icons.keyboard_arrow_down),
                        isExpanded: true,
                        value: _typeFile,
                        onChanged: (newValue) {
                          setState(() {
                            _typeFile = newValue;
                          });
                        },
                        items: [
                          DropdownMenuItem<dynamic>(
                            value: "CSV",
                            child: Text("arquivo .csv")
                          ),
                        ]
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: RaisedButton(
                    onPressed: () { 
                      
                    },
                    color: Colors.green,
                    child: Text(
                      "Enviar Arquivo",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),
                  ),
                )
              ]
            ),
          )
        ),
      )
    );
  }
}