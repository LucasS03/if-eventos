import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ifeventos/widgets/custom-card.dart';
import 'package:ifeventos/widgets/custom-dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class RateArticleScreen extends StatefulWidget {

  final Map<String, dynamic> project;
  RateArticleScreen({ this.project });

  @override
  _RateArticleScreenState createState() => _RateArticleScreenState();
}

class _RateArticleScreenState extends State<RateArticleScreen> {

  final String _oral = "ORAL";
  final String _poster = "POSTER";

  String _radioValue = "ORAL";
  DateTime _date = DateTime.now();
  double _item1 = 3;
  bool _item1changed = false;
  double _item2 = 3;
  bool _item2changed = false;
  double _item3 = 3;
  bool _item3changed = false;
  double _item4 = 3;
  bool _item4changed = false;
  double _item5 = 3;
  bool _item5changed = false;
  
  _handleRadioValueChange(String value) {
    setState(() {
      _radioValue = value == _poster ? _poster : _oral;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          "Avaliar Trabalho",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () => launch("http://www.uenf.br/Uenf/Downloads/Agenda_Social_8427_1312371250.pdf"),
            color: Colors.white,
            tooltip: "Baixar Artigo"
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: <Widget>[
              
              CustomCard(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.project["title"],
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Divider(),
                    getAuthors(authors: widget.project["authors"])
                  ],
                )
              ),

              CustomCard(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Modalidade:",
                      style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(fontSize: 16)
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Radio(
                              value: _oral, 
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange
                            ),
                            GestureDetector(
                              onTap: () {
                                _handleRadioValueChange(_oral);
                              },
                              child: Text(_oral),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio(
                              value: _poster, 
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange
                            ),
                            GestureDetector(
                              onTap: () {
                                _handleRadioValueChange(_poster);
                              },
                              child: Text(_poster),
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                )
              ),

              CustomCard(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Apresentado em:",
                      style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(fontSize: 16)
                      ),
                    ),

                    DateTimeField(
                      format: DateFormat("dd/MM/yyyy"),
                      initialValue: DateTime.now(),
                      decoration: InputDecoration(labelText: 'Data'),
                      onChanged: (dt) => setState(() => _date = dt),
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime.now()
                        );
                      },
                    ),
                  ],
                )
              ),

              CustomCard(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Na Introdução consta claramente a relevância do tema e os seus objetivos:",
                      style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(fontSize: 16)
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("1", style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Slider(
                            value: _item1,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: _item1.round().toString(),
                            activeColor: _item1changed ? Colors.green : Colors.grey[400],
                            inactiveColor: Colors.grey,
                            onChangeStart: (d) {
                              setState(() => _item1changed = true);
                            },
                            onChanged: (double value) {
                              setState(() {
                                _item1 = value;
                              });
                            },
                          ),
                        ),
                        Text("5", style: TextStyle(fontSize: 16))
                      ],
                    ),
                  ],
                )
              ),

              CustomCard(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Fundamentação teórico-científica:",
                      style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(fontSize: 16)
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("1", style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Slider(
                            value: _item2,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: _item2.round().toString(),
                            activeColor: _item2changed ? Colors.green : Colors.grey[400],
                            inactiveColor: Colors.grey,
                            onChangeStart: (d) {
                              setState(() => _item2changed = true);
                            },
                            onChanged: (double value) {
                              setState(() {
                                _item2 = value;
                              });
                            },
                          ),
                        ),
                        Text("5", style: TextStyle(fontSize: 16))
                      ],
                    ),
                  ],
                )
              ),

              CustomCard(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Adequação da metodologia ao tipo de trabalho:",
                      style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(fontSize: 16)
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("1", style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Slider(
                            value: _item3,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: _item3.round().toString(),
                            activeColor: _item3changed ? Colors.green : Colors.grey[400],
                            inactiveColor: Colors.grey,
                            onChangeStart: (d) {
                              setState(() => _item3changed = true);
                            },
                            onChanged: (double value) {
                              setState(() {
                                _item3 = value;
                              });
                            },
                          ),
                        ),
                        Text("5", style: TextStyle(fontSize: 16))
                      ],
                    ),
                  ],
                )
              ),

              CustomCard(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Domínio do conteúdo na apresentação:",
                      style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(fontSize: 16)
                      ),
                    ),
                    
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("1", style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Slider(
                            value: _item4,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: _item4.round().toString(),
                            activeColor: _item4changed ? Colors.green : Colors.grey[400],
                            inactiveColor: Colors.grey,
                            onChangeStart: (d) {
                              setState(() => _item4changed = true);
                            },
                            onChanged: (double value) {
                              setState(() {
                                _item4 = value;
                              });
                            },
                          ),
                        ),
                        Text("5", style: TextStyle(fontSize: 16))
                      ],
                    ),
                  ],
                )
              ),

              CustomCard(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Qualidade da organização e apresentação do trabalho (recursos didáticos utilizados, slides e outros):",
                      style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(fontSize: 16)
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("1", style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Slider(
                            value: _item5,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: _item5.round().toString(),
                            activeColor: _item5changed ? Colors.green : Colors.grey[400],
                            inactiveColor: Colors.grey,
                            onChangeStart: (d) {
                              setState(() => _item5changed = true);
                            },
                            onChanged: (double value) {
                              setState(() {
                                _item5 = value;
                              });
                            },
                          ),
                        ),
                        Text("5", style: TextStyle(fontSize: 16))
                      ],
                    ),
                  ],
                )
              ),

              SizedBox(
                height: 50,
                width: double.maxFinite,
                child: FlatButton(
                  disabledColor: Colors.grey,
                  color: Colors.green,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(color: Colors.transparent)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Finalizar Avaliação", 
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 20
                        ),
                      )
                    ],
                  ),
                  onPressed: 
                  _item1changed && _item2changed && _item3changed && _item4changed && _item5changed ? 
                  () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => CustomDialog(
                        title: "Trabalho Avaliado",
                        content: Column(
                          children: <Widget>[
                            Text(
                              "Trabalho avaliado com sucesso!",
                              style: TextStyle(fontSize: 18),
                            )
                          ],
                        ),
                        buttonText: "Ok",
                        skipScreen: true,
                      ),
                    );
                    
                  } : null,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getAuthors({ @required List authors }) {
    List<Widget> a = new List<Widget>();

    authors.forEach((el) {
      a.add(
        Container(
          width: double.maxFinite,
          margin: EdgeInsets.only(bottom: authors[authors.length - 1] != el ? 10 : 0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.grey[200]),
              ),
              SizedBox(width: 10),
              Text(el["name"])
            ],
          ),
        )
      );
    });

    return Column(children: a);
  }

}