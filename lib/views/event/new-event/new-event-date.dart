import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:ifeventos/views/event/new-event/new-event-hour.dart';
import 'package:ifeventos/widgets/custom-card.dart';
import 'package:intl/intl.dart';

class NewEventDateScreen extends StatefulWidget {
  final Map<String, dynamic> newEvent;

  NewEventDateScreen({@required this.newEvent});

  @override
  _NewEventDateScreenState createState() => _NewEventDateScreenState();
}

class _NewEventDateScreenState extends State<NewEventDateScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _dateBegin = DateTime.now();
  DateTime _dateEnd = DateTime.now();

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
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              height: MediaQuery.of(context).size.height - 80,
            ),
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: CustomCard(
                            body: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Quando irá acontecer seu evento?",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .merge(TextStyle(color: Colors.grey[600])),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    DateTimeField(
                                      format: DateFormat("dd/MM/yyyy"),
                                      initialValue: DateTime.now(),
                                      decoration: InputDecoration(
                                        labelText: 'Data de início do evento',
                                        prefixIcon: Icon(Icons.date_range,
                                            color: Colors.grey[600]),
                                      ),
                                      onChanged: (dt) =>
                                          setState(() => _dateBegin = dt),
                                      onShowPicker: (context, currentValue) {
                                        return showDatePicker(
                                            context: context,
                                            firstDate: DateTime.now(),
                                            initialDate:
                                                currentValue ?? DateTime.now(),
                                            lastDate: DateTime(
                                                DateTime.now().year + 1,
                                                12,
                                                31));
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    DateTimeField(
                                      format: DateFormat("dd/MM/yyyy"),
                                      initialValue: DateTime.now(),
                                      decoration: InputDecoration(
                                        labelText: 'Data do fim do evento',
                                        prefixIcon: Icon(Icons.date_range,
                                            color: Colors.grey[600]),
                                      ),
                                      onChanged: (dt) =>
                                          setState(() => _dateEnd = dt),
                                      onShowPicker: (context, currentValue) {
                                        // todo primeira data fim disponível = data de início
                                        return showDatePicker(
                                            context: context,
                                            firstDate: DateTime.now(),
                                            initialDate:
                                                currentValue ?? DateTime.now(),
                                            lastDate: DateTime(
                                                DateTime.now().year + 1,
                                                12,
                                                31));
                                      },
                                    ),
                                  ],
                                )),
                          ],
                        )),
                      ),
                      SizedBox(
                        height: 50,
                        width: double.maxFinite,
                        child: RaisedButton(
                          onPressed: () {
                            if (!_formKey.currentState.validate()) return;

                            widget.newEvent["dateBegin"] = _dateBegin;
                            widget.newEvent["dateEnd"] = _dateEnd;
                            // if (_dateEnd.isBefore(_dateBegin)) {
                            //   AlertDialog(
                            //     title: const Text('AlertDialog Title'),
                            //     content: SingleChildScrollView(
                            //       child: ListBody(
                            //         children: const <Widget>[
                            //           Text('This is a demo alert dialog.'),
                            //           Text(
                            //               'Would you like to approve of this message?'),
                            //         ],
                            //       ),
                            //     ),
                            //     actions: <Widget>[
                            //       TextButton(
                            //         child: const Text('Approve'),
                            //         onPressed: () {
                            //           Navigator.of(context).pop();
                            //         },
                            //       ),
                            //     ],
                            //   );
                            // } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewEventHourScreen(
                                      newEvent: widget.newEvent)),
                            );
                            // }
                          },
                          color: Colors.green,
                          child: Text(
                            "Continuar",
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ])),
          ),
        ));
  }
}
