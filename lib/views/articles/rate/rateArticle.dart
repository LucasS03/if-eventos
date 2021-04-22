import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ifeventos/widgets/custom-dialog-box.dart';
import 'package:intl/intl.dart';
import 'package:ifeventos/widgets/custom-card.dart';
import 'package:ifeventos/widgets/custom-dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class RateArticleScreen extends StatefulWidget {

  final String eventId;
  final String projectId;

  RateArticleScreen({ @required this.eventId, @required this.projectId });

  @override
  _RateArticleScreenState createState() => _RateArticleScreenState();
}

class _RateArticleScreenState extends State<RateArticleScreen> {

  final userId = GetStorage().read('userId');
  final String _oral = "ORAL";
  final String _poster = "POSTER";

  bool _finished = false;
  bool _didNotAttend = false;
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

  DocumentSnapshot article;
  bool _load = true;
  
  getArticle() async {
    article = await Firestore.instance.
      collection("events").document(widget.eventId).
      collection("articles").document(widget.projectId).snapshots().first;

    print(article.data);
    setState(() {
      _load = false;
    });
  }

  getEvaluation() async {
    DocumentSnapshot eval = await Firestore.instance.
                      collection("events").document(widget.eventId).
                      collection("articles").document(widget.projectId).
                      collection("evaluations").document(userId).snapshots().first;
    
    if(eval.data != null) {
      setState(() {
        _radioValue = eval.data["modality"];
        _date = DateTime.fromMillisecondsSinceEpoch(eval.data["date"].seconds * 1000);
        _item1 = eval.data["clarity"];
        _item2 = eval.data["reasoning"];
        _item3 = eval.data["methodologyAdequacy"];
        _item4 = eval.data["domain"];
        _item5 = eval.data["quality"];
        _didNotAttend = eval.data["didNotAttend"] != null ? eval.data["didNotAttend"] : false;
        _finished = eval.data["finished"] != null ? eval.data["finished"] : false;
        _item1changed = true;
        _item2changed = true;
        _item3changed = true;
        _item4changed = true;
        _item5changed = true;
      });
    }
  }

  @override
  void initState() {
    getArticle();
    getEvaluation();

    super.initState();
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
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.file_download),
        //     onPressed: () => launch("http://www.uenf.br/Uenf/Downloads/Agenda_Social_8427_1312371250.pdf"),
        //     color: Colors.white,
        //     tooltip: "Baixar Artigo"
        //   )
        // ],
      ),

      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: 
          _load ? 
          Center(
            child: CircularProgressIndicator()
          ) :
          Column(
            children: <Widget>[
              // Dados trabalho
              CustomCard(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      article.data["titulo"],
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Divider(),

                    Text(
                      "Autor(es):",
                      style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                        )
                      ),
                    ),
                    getAuthors(authors: [{ "name": article.data["nome"] }])
                  ],
                )
              ),

              _finished ? 
              CustomCard(
                color: Colors.green[100],
                body: Text(
                  "Trabalho já avaliado e entregue. Não pode mais ser editado.",
                  style: Theme.of(context).textTheme.headline6.merge(
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                  textAlign: TextAlign.center,
                )
              ) :
              SizedBox(),

              // Não Compareceu
              CustomCard(
                color: Colors.yellow[200],
                body: Column(
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headline6.merge(
                          TextStyle(fontSize: 16)
                        ),
                        children: _didNotAttend ? 
                        <TextSpan>[
                          TextSpan(text: "Caso o apresentador tenha comparecido, clique no botão abaixo \""),
                          TextSpan(text: "Compareceu", style: new TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "\" para liberar a avaliação.")
                        ] :
                        <TextSpan>[
                          TextSpan(text: "Caso o apresentador não tenha comparecido, clique no botão abaixo \""),
                          TextSpan(text: "Não Compareceu", style: new TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "\" e em seguida clique em \""),
                          TextSpan(text: "Finalizar avaliação", style: new TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "\"."),
                        ]
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      width: double.maxFinite,
                      child: FlatButton(
                        color: Colors.yellow[800],
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(color: Colors.transparent)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _didNotAttend ? "Compareceu" : "Não Compareceu", 
                              style: TextStyle(
                                color: _finished ? Colors.grey[600] : Colors.white, 
                                fontSize: 20
                              ),
                            )
                          ],
                        ),
                        onPressed: _finished ? null : () {
                          if(_didNotAttend) {
                            setState(() {
                              _didNotAttend = !_didNotAttend;
                              _item1 = _item2 = _item3 = _item4 = _item5 = _didNotAttend ? 1.0 : 3.0;
                            });
                          } else {
                            showDialog(context: context,
                              builder: (BuildContext context){
                                return new AlertDialog(
                                  title: new Text("Tem certeza?"),
                                  content: Container(
                                    height: 100.0,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget> [
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.headline6.merge(TextStyle(fontSize: 16)),
                                            children: <TextSpan>[
                                              TextSpan(text: "Ao clicar em "),
                                              TextSpan(text: "SIM ", style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                              TextSpan(text: "você informa que o apresentador não compareceu.")
                                            ]
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            FlatButton(
                                              color: Colors.green,
                                              onPressed: () {
                                                setState(() {
                                                  _didNotAttend = !_didNotAttend;
                                                  _item1 = _item2 = _item3 = _item4 = _item5 = _didNotAttend ? 1.0 : 3.0;
                                                });
                                                Navigator.of(context).pop();
                                              }, 
                                              child: Text("SIM", style: TextStyle(color: Colors.white))
                                            ),
                                            SizedBox(width: 10.0),
                                            FlatButton(
                                              color: Colors.redAccent[200],
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              }, 
                                              child: Text("NÃO", style: TextStyle(color: Colors.white))
                                            ),
                                          ],
                                        )
                                      ]
                                    )
                                  )
                                );
                              }
                            );
                          }
                        }
                      ),
                    )
                  ]
                )
              ),

              // Modalidade
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
                              onChanged: _finished ? null : _handleRadioValueChange
                            ),
                            GestureDetector(
                              onTap: _finished ? null : () {
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
                              onChanged: _finished ? null : _handleRadioValueChange
                            ),
                            GestureDetector(
                              onTap: _finished ? null : () {
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

              // Data
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
                      onChanged: _finished ? null : (dt) => setState(() => _date = dt),
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

              // 1 - Clareza na relevância do tema
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
                            onChanged: _finished ? null : _didNotAttend ? null : (double value) {
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

              // 2 - Fundamentação
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
                            onChanged: _finished ? null : _didNotAttend ? null : (double value) {
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

              // 3 - Adequação da metodologia
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
                            onChanged: _finished ? null : _didNotAttend ? null : (double value) {
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

              // 4 - Domínio do conteúdo
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
                            onChanged: _finished ? null : _didNotAttend ? null : (double value) {
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

              // 5 - Qualidade da organização e apresentação
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
                            onChanged: _finished ? null : _didNotAttend ? null : (double value) {
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
                  _didNotAttend || (_item1changed && _item2changed && _item3changed && _item4changed && _item5changed) ? 
                  () {
                    Map<String, dynamic> eval = {
                      "date": _date,
                      "modality": _radioValue,
                      "clarity": _item1,
                      "reasoning": _item2,
                      "methodologyAdequacy": _item3,
                      "domain": _item4,
                      "quality": _item5,
                      "idEvaluator": userId,
                      "didNotAttend": _didNotAttend,
                      "finished": false
                    };
                    Firestore.instance.
                      collection("events").document(widget.eventId).
                      collection("articles").document(widget.projectId).
                      collection("evaluations").document(userId).setData(eval).then((value) {
                        showDialog(context: context,
                          builder: (BuildContext context){
                            return CustomDialogBox(
                              title: "Tudo Certo!",
                              descriptions: "Sua avaliação foi salva! Não esqueça de entregar para o coordenador do evento. Após entregar não será mais possível editar as avaliações.",
                              text: "Ok",
                              icon: Icons.check,
                              iconColor: Colors.white,
                              color: Colors.greenAccent,
                              skipScreen: true,
                            );
                          }
                        );
                      });                    
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
          child: Text(
            el["name"],
            overflow: TextOverflow.ellipsis,
          ),
        )
      );
    });

    return Container(
      child: Column(children: a)
    );
  }

}