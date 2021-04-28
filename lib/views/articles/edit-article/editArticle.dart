import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:ifeventos/widgets/button-default.dart';
import 'package:ifeventos/widgets/custom-card.dart';
import 'package:ifeventos/widgets/custom-dialog-box.dart';
import 'package:intl/intl.dart';

class EditArticleScreen extends StatefulWidget {

  final String eventId;
  final String articleId;
  EditArticleScreen({ @required this.eventId, @required this.articleId});

  @override
  _EditArticleScreenState createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {

  final _formKey = GlobalKey<FormState>();
  final format = DateFormat("HH:mm");
  bool _load = false;
  DocumentSnapshot event;
  DocumentSnapshot article;

  TextEditingController _areaController = new TextEditingController();
  TextEditingController _dataController = new TextEditingController();
  TextEditingController _idEventoController = new TextEditingController();
  TextEditingController _idProjetoController = new TextEditingController();
  TextEditingController _idTrabalhoController = new TextEditingController();
  TextEditingController _nomeController = new TextEditingController();
  TextEditingController _pdfController = new TextEditingController();
  TextEditingController _resumoController = new TextEditingController();
  TextEditingController _tituloController = new TextEditingController();
  TextEditingController _localController = new TextEditingController();
  TextEditingController _numeroController = new TextEditingController();
  TextEditingController _horaInicioController = TextEditingController(text: "${TimeOfDay.fromDateTime(DateTime.now()).hour}:${TimeOfDay.fromDateTime(DateTime.now()).minute}");
  TextEditingController _horaFinalController = TextEditingController(text: "${TimeOfDay.fromDateTime(DateTime.now()).hour}:${TimeOfDay.fromDateTime(DateTime.now()).minute}");
  String _campusEvent = "ARACATI";

  getEventAndArticle() async {
    setState(() => _load = true);
    event = await Firestore.instance.collection("events").document(widget.eventId).get();
    article = await Firestore.instance.collection("events").document(widget.eventId).collection("articles").document(widget.articleId).get();

    if(event.data != null) {
      setState(() {
        _campusEvent = event.data.containsKey("campus") ? event.data["campus"] : "ARACATI";
      });
    }

    if(article.data != null) {
      setState(() {
        _areaController.text = article.data.containsKey("area") ? article.data["area"] : "";
        _dataController.text = article.data.containsKey("dataInsercao") ? article.data["dataInsercao"] : "";
        _idEventoController.text = article.data.containsKey("idEvento") ? article.data["idEvento"] : "";
        _idProjetoController.text = article.data.containsKey("idProjeto") ? article.data["idProjeto"] : "";
        _idTrabalhoController.text = article.data.containsKey("idTrabalho") ? article.data["idTrabalho"] : "";
        _nomeController.text = article.data.containsKey("nome") ? article.data["nome"] : "";
        _pdfController.text = article.data.containsKey("pdf") ? article.data["pdf"] : "";
        _resumoController.text = article.data.containsKey("resumo") ? article.data["resumo"] : "";
        _tituloController.text = article.data.containsKey("titulo") ? article.data["titulo"] : "";
        _localController.text = article.data.containsKey("local") ? article.data["local"] : event.data["local"];
        _numeroController.text = article.data.containsKey("numero") ? article.data["numero"] : "0";
        _horaInicioController.text = article.data.containsKey("horaInicio") ? article.data["horaInicio"] : event.data["hourBegin"];
        _horaFinalController.text = article.data.containsKey("horaFinal") ? article.data["horaFinal"] : event.data["hourEnd"];
      });
    }
    setState(() => _load = false);
  }

  updateEvent() async {
    if(!_formKey.currentState.validate())
      return;

    Map<String, dynamic> editArticle = {
      "titulo": "",
      "campus": "",
      "local": "",
      "horaInicio": "",
      "horaFinal": "",
      "numero": 0
    };

    editArticle["titulo"] = _tituloController.text;
    editArticle["campus"] = _campusEvent;
    editArticle["local"] = _localController.text;
    editArticle["horaInicio"] = _horaInicioController.text;
    editArticle["horaFinal"] = _horaFinalController.text;
    editArticle["numero"] = _numeroController.text;

    Firestore.instance
      .collection("events").document(widget.eventId)
      .collection("articles").document(widget.articleId)
      .updateData(editArticle)
      .then((value) {
        showDialog(context: context,
          builder: (BuildContext context){
            return CustomDialogBox(
              title: "Tudo Certo!",
              descriptions: "O artigo foi editado com sucesso!",
              text: "Voltar",
              icon: Icons.check,
              iconColor: Colors.white,
              color: Colors.greenAccent,
              skipScreen: true
            );
          }
        );
      }).catchError((onError) {
        showDialog(context: context,
          builder: (BuildContext context){
            return CustomDialogBox(
              title: "Ops... :(",
              descriptions: "Houve algum erro ao editar este trabalho... Que tal tentar mais tarde?",
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
    getEventAndArticle();
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

              CustomCard(
                body: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      
                      // título
                      TextFormField(
                        controller: _tituloController,
                        cursorColor: Colors.green,
                        validator: (value) {
                          if(_tituloController.text.isEmpty)
                            return 'O título do artigo não pode ser vazio';

                          if(_tituloController.text.length < 5)
                            return 'O título do artigo está muito curto';

                          return null;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Exemplo: Nome do Meu Artigo",
                          labelStyle: TextStyle(
                            color: Colors.grey[600]
                          ),
                          prefixIcon: Icon(
                            Icons.article_outlined, 
                            color: Colors.grey[600]
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      
                      // resumo
                      TextFormField(
                        controller: _resumoController,
                        enabled: false,
                        keyboardType: TextInputType.text,
                        minLines: 3,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: "Exemplo: Esta pesquisa teve o intuito de desmonstrar...",
                          labelStyle: TextStyle(
                            color: Colors.grey[600]
                          ),
                          prefixIcon: Icon(
                            Icons.article_rounded, 
                            color: Colors.grey[600]
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // nome
                      TextFormField(
                        controller: _nomeController,
                        enabled: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Exemplo: João da Silva",
                          labelStyle: TextStyle(
                            color: Colors.grey[600]
                          ),
                          prefixIcon: Icon(
                            Icons.person, 
                            color: Colors.grey[600]
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // evento / projeto / trabalho
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _idEventoController,
                              enabled: false,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Evento",
                                labelStyle: TextStyle(
                                  color: Colors.grey[600]
                                ),
                                prefixIcon: Icon(
                                  Icons.calendar_today_sharp, 
                                  color: Colors.grey[600]
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: TextFormField(
                              controller: _idProjetoController,
                              enabled: false,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Projeto",
                                labelStyle: TextStyle(
                                  color: Colors.grey[600]
                                ),
                                prefixIcon: Icon(
                                  Icons.list_alt,
                                  color: Colors.grey[600]
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: TextFormField(
                              controller: _idTrabalhoController,
                              enabled: false,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Trabalho",
                                labelStyle: TextStyle(
                                  color: Colors.grey[600]
                                ),
                                prefixIcon: Icon(
                                  Icons.ballot, 
                                  color: Colors.grey[600]
                                ),
                              ),
                            ),
                          )
                        ]
                      ),

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
                            "Campus",
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
                      
                      // número
                      TextFormField(
                        controller: _numeroController,
                        cursorColor: Colors.green,
                        validator: (value) {
                          if(_tituloController.text.isEmpty)
                            return 'O número da apresentação do artigo não pode ser vazio';

                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Número da apresentação do artigo",
                          labelStyle: TextStyle(
                            color: Colors.grey[600]
                          ),
                          prefixIcon: Icon(
                            Icons.looks_one_outlined, 
                            color: Colors.grey[600]
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // hora inicio / fim
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DateTimeField(
                              controller: _horaInicioController,
                              decoration: InputDecoration(
                                labelText: 'Horário início',
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
                              controller: _horaFinalController,
                              decoration: InputDecoration(
                                labelText: 'Horário final',
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