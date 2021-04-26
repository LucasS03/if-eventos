import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:ifeventos/widgets/button-default.dart';
import 'package:ifeventos/widgets/custom-card.dart';
import 'package:ifeventos/widgets/custom-dialog-box.dart';
import 'package:intl/intl.dart';

class EditEventScreen extends StatefulWidget {

  final String eventId;
  EditEventScreen({ @required this.eventId });

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {

  final _formKey = GlobalKey<FormState>();
  bool _load = false;
  DocumentSnapshot event;

  TextEditingController _titleController = new TextEditingController();
  TextEditingController _siteController = new TextEditingController();

  final format = DateFormat("HH:mm");
  TextEditingController _startTimeController = TextEditingController(text: "${TimeOfDay.fromDateTime(DateTime.now()).hour}:${TimeOfDay.fromDateTime(DateTime.now()).minute}");
  TextEditingController _endTimeController = TextEditingController(text: "${TimeOfDay.fromDateTime(DateTime.now()).hour}:${TimeOfDay.fromDateTime(DateTime.now()).minute}");

  DateTime _dateBegin = DateTime.now();
  DateTime _dateEnd = DateTime.now();

  TextEditingController _localController = new TextEditingController();
  String _campusEvent = "ARACATI";

  bool _finished = false;

  getEvent() async {
    setState(() => _load = true);
    event = await Firestore.instance.collection("events").document(widget.eventId).get();
    if(event != null && event.data != null) {
      setState(() {
        _titleController.text = event.data["title"];
        _siteController.text = event.data["site"];
        _localController.text = event.data["local"];
        _startTimeController.text = event.data["hourBegin"];
        _endTimeController.text = event.data["hourEnd"];
        _campusEvent = event.data["campus"];
        _finished = event.data.containsKey("finished") ? event.data["finished"] : false;

        _dateBegin = DateTime.fromMillisecondsSinceEpoch((event.data["dateBegin"].seconds - (60*60*3)) * 1000);
        _dateEnd = DateTime.fromMillisecondsSinceEpoch((event.data["dateEnd"].seconds - (60*60*3)) * 1000);
      });
    }
    setState(() => _load = false);
  }

  updateEvent() async {
    if(!_formKey.currentState.validate())
      return;

    Map<String, dynamic> editEvent = {
      "title": "",
      "site": "",
      "campus": "",
      "dateBegin": "",
      "dateEnd": "",
      "hourBegin": "",
      "hourEnd": "",
      "local": "",
      "finished": false
    };

    editEvent["title"] = _titleController.text;
    editEvent["site"] = _siteController.text;
    editEvent["hourBegin"] = _startTimeController.text;
    editEvent["hourEnd"] = _endTimeController.text;
    editEvent["local"] = _localController.text;
    editEvent["campus"] = _campusEvent;
    editEvent["finished"] = _finished;
    editEvent["dateBegin"] = DateTime(_dateBegin.year, _dateBegin.month, _dateBegin.day, int.parse(_startTimeController.text.split(":")[0]), int.parse(_startTimeController.text.split(":")[1]), 0).add(Duration(hours: 3));
    editEvent["dateEnd"] = DateTime(_dateEnd.year, _dateEnd.month, _dateEnd.day, int.parse(_endTimeController.text.split(":")[0]), int.parse(_endTimeController.text.split(":")[1]), 59).add(Duration(hours: 3));

    Firestore.instance.collection("events").document(widget.eventId).updateData(editEvent)
      .then((value) {
        showDialog(context: context,
          builder: (BuildContext context){
            return CustomDialogBox(
              title: "Tudo Certo!",
              descriptions: "Seu evento foi editado com sucesso!",
              text: "Voltar",
              icon: Icons.check,
              iconColor: Colors.white,
              color: Colors.greenAccent,
              skipScreen: true,
              returnData: true
            );
          }
        );
      }).catchError((onError) {
        showDialog(context: context,
          builder: (BuildContext context){
            return CustomDialogBox(
              title: "Ops... :(",
              descriptions: "Houve algum erro ao editar este evento... Que tal tentar mais tarde?",
              text: "Voltar",
              icon: Icons.close,
              iconColor: Colors.white,
              color: Colors.redAccent,
              skipScreen: true,
            );
          }
        );
      });
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
        title: Text("Editar evento"),
      ),

      body: _load ? 
      Center(
        child: CircularProgressIndicator()
      ) : 
      SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              // CustomCard(
              //   body: Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 5),
              //     child: Text(
              //       "Aqui você pode editar as informações do seu evento!",
              //       style: Theme.of(context).textTheme.headline6.merge(
              //         TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              //       ),
              //       textAlign: TextAlign.center,
              //     ),
              //   ),
              //   color: Colors.yellow[100],
              // ),

              CustomCard(
                body: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // título
                      TextFormField(
                        controller: _titleController,
                        cursorColor: Colors.green,
                        validator: (value) {
                          if(_titleController.text.isEmpty)
                            return 'O título do seu evento não pode ser vazio';

                          if(_titleController.text.length < 5)
                            return 'O título do seu evento está muito curto';

                          return null;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Exemplo: SEMIC 2021",
                          labelStyle: TextStyle(
                            color: Colors.grey[600]
                          ),
                          prefixIcon: Icon(
                            Icons.title, 
                            color: Colors.grey[600]
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      
                      // site
                      TextFormField(
                        controller: _siteController,
                        cursorColor: Colors.green,
                        validator: (value) {
                          if(_siteController.text.isEmpty)
                            return 'O site do seu evento não pode ser vazio';

                          if(!_siteController.text.contains('.'))
                            return 'Site inválido';

                          return null;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Exemplo: https://www.meuevento.com",
                          labelStyle: TextStyle(
                            color: Colors.grey[600]
                          ),
                          prefixIcon: Icon(
                            Icons.public, 
                            color: Colors.grey[600]
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // data inicio / fim
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DateTimeField(
                              format: DateFormat("dd/MM/yyyy"),
                              initialValue: _dateBegin,
                              decoration: InputDecoration(
                                labelText: 'Data de início do evento',
                                prefixIcon: Icon(
                                  Icons.date_range, 
                                  color: Colors.grey[600]
                                ),
                              ),
                              onChanged: (dt) => setState(() => _dateBegin = dt),
                              onShowPicker: (context, currentValue) {
                                return showDatePicker(
                                  context: context,
                                  firstDate: _dateBegin,
                                  initialDate: currentValue ?? _dateBegin,
                                  lastDate: DateTime(DateTime.now().year + 1, 12, 31)
                                );
                              },
                            ),
                          ),

                          SizedBox(width: 10,),
                          Expanded(
                            child: DateTimeField(
                              format: DateFormat("dd/MM/yyyy"),
                              initialValue: _dateEnd,
                              decoration: InputDecoration(
                                labelText: 'Data do fim do evento',
                                prefixIcon: Icon(
                                  Icons.date_range, 
                                  color: Colors.grey[600]
                                ),
                              ),
                              onChanged: (dt) => setState(() => _dateEnd = dt),
                              onShowPicker: (context, currentValue) {
                                // todo primeira data fim disponível = data de início
                                return showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(DateTime.now().year + 1, 12, 31)
                                );
                              },
                            ),
                          ),
                        ]
                      ),
                      SizedBox(height: 10),

                      // hora inicio / fim
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DateTimeField(
                              controller: _startTimeController,
                              decoration: InputDecoration(
                                labelText: 'Horário início do evento',
                                prefixIcon: Icon(
                                  Icons.access_time_rounded, 
                                  color: Colors.grey[600]
                                ),
                              ),
                              format: format,
                              onShowPicker: (context, currentValue) async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                );
                                return DateTimeField.convert(time);
                              },
                            ),
                          ),

                          SizedBox(width: 10,),
                          Expanded(
                            child: DateTimeField(
                              controller: _endTimeController,
                              decoration: InputDecoration(
                                labelText: 'Horário final do evento',
                                prefixIcon: Icon(
                                  Icons.access_time_rounded, 
                                  color: Colors.grey[600]
                                ),
                              ),
                              format: format,
                              onShowPicker: (context, currentValue) async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                );
                                return DateTimeField.convert(time);
                              },
                            ),
                          ),
                        ]
                      ),
                      SizedBox(height: 10),

                      // local
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
                            color: Colors.grey[600]
                          ),
                          prefixIcon: Icon(
                            Icons.location_on_outlined, 
                            color: Colors.grey[600]
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // campus
                      Row(
                        children: <Widget>[
                          Text(
                            "Campus do evento",
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
                                  child: Text("Aracati", style: TextStyle(fontSize: 18, color: Colors.grey[600]),)
                                )
                              ]
                            ),
                          )
                        ],
                      ),

                      // finalizado
                      Row(
                        children: <Widget>[
                          Text(
                            "Evento finalizado:",
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: DropdownButton<dynamic>(
                              icon: Icon(Icons.keyboard_arrow_down),
                              isExpanded: true,
                              value: _finished,
                              onChanged: (newValue) {
                                setState(() {
                                  _finished = newValue;
                                });
                              },
                              items: [
                                DropdownMenuItem<dynamic>(
                                  value: true,
                                  child: Text("Sim", style: TextStyle(fontSize: 18, color: Colors.grey[600]),)
                                ),
                                DropdownMenuItem<dynamic>(
                                  value: false,
                                  child: Text("Não", style: TextStyle(fontSize: 18, color: Colors.grey[600]),)
                                )
                              ]
                            ),
                          )
                        ],
                      ),

                      ButtonDefault(
                        title: "Salvar",
                        onTap: () {
                          updateEvent();
                        },
                      )
                    ],
                  )
                ),
              ),

              
              
            ]
          )
        )
      )
    );
  }
}