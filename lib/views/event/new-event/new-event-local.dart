import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ifeventos/views/event/new-event/new-event-finish.dart';
import 'package:ifeventos/widgets/custom-card.dart';

class NewEventLocalScreen extends StatefulWidget {

  final Map<String, dynamic> newEvent;

  NewEventLocalScreen({ @required this.newEvent });

  @override
  _NewEventLocalScreenState createState() => _NewEventLocalScreenState();
}

class _NewEventLocalScreenState extends State<NewEventLocalScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _localController = new TextEditingController();
  String _campusEvent = "ARACATI";

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

      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: MediaQuery.of(context).size.height - 80,
          ),
          child: Container(
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
                        Text(
                          "Onde irá acontecer seu evento?",
                          style: Theme.of(context).textTheme.headline5.merge(
                            TextStyle(color: Color(0xff313944))
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _localController,
                                cursorColor: Colors.green,
                                validator: (value) {
                                  if(_localController.text.isEmpty)
                                    return 'O local do seu evento não pode ser vazio';

                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: "Exemplo: IFCE Aracati - Campus Centro",
                                  labelStyle: TextStyle(
                                    color: Color(0xff313944)
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_on_outlined, 
                                    color: Color(0xff313944)
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Campus do evento",
                                    style: TextStyle(fontSize: 18, color: Color(0xff313944)),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: DropdownButton<dynamic>(
                                      icon: Icon(Icons.keyboard_arrow_down),
                                      isExpanded: true,
                                      value: _campusEvent,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _campusEvent = newValue;
                                        });
                                      },
                                      items: [
                                        DropdownMenuItem<dynamic>(
                                          value: "ARACATI",
                                          child: Text("Aracati", style: TextStyle(fontSize: 18, color: Color(0xff313944)),)
                                        )
                                      ]
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
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
                      widget.newEvent["local"] = _localController.text;
                      widget.newEvent["campus"] = _campusEvent;
                      widget.newEvent["finished"] = false;
                      
                      Firestore.instance.collection("events")
                        .add(widget.newEvent).then((value) => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NewEventFinishScreen()),
                          )
                        }).catchError((err) => {
                          print(err)
                        });

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
          ),
        ),
      )
    );
  }
}