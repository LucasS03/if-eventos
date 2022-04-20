import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:ifeventos/views/event/new-event/new-event-local.dart';
import 'package:ifeventos/widgets/custom-card.dart';
import 'package:intl/intl.dart';

class NewEventHourScreen extends StatefulWidget {
  final Map<String, dynamic> newEvent;

  NewEventHourScreen({@required this.newEvent});

  @override
  _NewEventHourScreenState createState() => _NewEventHourScreenState();
}

class _NewEventHourScreenState extends State<NewEventHourScreen> {
  final _formKey = GlobalKey<FormState>();
  final format = DateFormat("HH:mm");
  TextEditingController _startTimeController = TextEditingController(
      text:
          "${TimeOfDay.fromDateTime(DateTime.now()).hour}:${TimeOfDay.fromDateTime(DateTime.now()).minute}");
  TextEditingController _endTimeController = TextEditingController(
      text:
          "${TimeOfDay.fromDateTime(DateTime.now()).hour}:${TimeOfDay.fromDateTime(DateTime.now()).minute}");

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
                              "Quando irá acontecer seu evento?",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .merge(TextStyle(color: Color(0xff313944))),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    DateTimeField(
                                      controller: _startTimeController,
                                      decoration: InputDecoration(
                                        labelText:
                                            'Horário de início do evento',
                                        prefixIcon: Icon(
                                            Icons.access_time_rounded,
                                            color: Color(0xff313944)),
                                      ),
                                      format: format,
                                      onShowPicker:
                                          (context, currentValue) async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                              currentValue ?? DateTime.now()),
                                        );
                                        return DateTimeField.convert(time);
                                      },
                                    ),
                                    SizedBox(height: 20),
                                    DateTimeField(
                                      controller: _endTimeController,
                                      decoration: InputDecoration(
                                        labelText:
                                            'Horário de fim do evento',
                                        prefixIcon: Icon(
                                            Icons.access_time_rounded,
                                            color: Color(0xff313944)),
                                      ),
                                      format: format,
                                      onShowPicker:
                                          (context, currentValue) async {
                                        final TimeOfDay time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                              currentValue ?? DateTime.now()),
                                        );
                                        return DateTimeField.convert(time);
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
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState.validate()) return;

                            // widget.newEvent["hourBegin"] = TimeOfDay(hour: int.parse(_startTimeController.text.split(':')[0]), minute: int.parse(_startTimeController.text.split(':')[1]));
                            // widget.newEvent["hourEnd"] = TimeOfDay(hour: int.parse(_endTimeController.text.split(':')[0]), minute: int.parse(_endTimeController.text.split(':')[1]));
                            widget.newEvent["hourBegin"] =
                                _startTimeController.text;
                            widget.newEvent["hourEnd"] =
                                _endTimeController.text;

                            widget.newEvent["dateBegin"] = DateTime.utc(
                                    widget.newEvent["dateBegin"].year,
                                    widget.newEvent["dateBegin"].month,
                                    widget.newEvent["dateBegin"].day,
                                    int.parse(_startTimeController.text
                                        .split(":")[0]),
                                    int.parse(_startTimeController.text
                                        .split(":")[1]),
                                    0)
                                .add(Duration(hours: 3));
                            widget.newEvent["dateEnd"] = DateTime.utc(
                                    widget.newEvent["dateEnd"].year,
                                    widget.newEvent["dateEnd"].month,
                                    widget.newEvent["dateEnd"].day,
                                    int.parse(
                                        _endTimeController.text.split(":")[0]),
                                    int.parse(
                                        _endTimeController.text.split(":")[1]),
                                    59)
                                .add(Duration(hours: 3));
                            // if (_endTimeController == _startTimeController) {
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
                                  builder: (context) => NewEventLocalScreen(
                                      newEvent: widget.newEvent)),
                            );
                            // }
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
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ])),
          ),
        ));
  }
}
