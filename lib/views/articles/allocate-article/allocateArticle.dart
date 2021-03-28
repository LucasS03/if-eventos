import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ifeventos/widgets/button-default.dart';
import 'package:ifeventos/widgets/custom-card.dart';
import 'package:ifeventos/widgets/custom-dialog-box.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AllocateArticleScreen extends StatefulWidget {

  final String eventId;
  final String articleId;
  AllocateArticleScreen({ @required this.eventId, @required this.articleId });

  @override
  _AllocateArticleScreenState createState() => _AllocateArticleScreenState();
}

class _AllocateArticleScreenState extends State<AllocateArticleScreen> {

  List _evaluators = [];
  List _selectedEvaluators = [];
  List _selectedEvaluatorsInit = [];
  bool loadEvaluators = true;

  getEvaluators() async {
    // Busca avaliadores deste evento
    await Firestore.instance
      .collection("events").document(widget.eventId)
      .collection("evaluators").getDocuments().then((evaluatorsThisEvent) {
        evaluatorsThisEvent.documents.forEach((element) async {
          DocumentSnapshot user = await Firestore.instance.collection("users").document(element.data["userId"]).get();
          Map<String, dynamic> u = {
            "documentID": user.documentID,
            "name": user.data["name"],
            "articlesToEvaluate": element.data["articleIds"].length
          };
          print(u);
          setState(() => _evaluators.add(u));
        });
      });
    // TODO: mostrando só alguns dos avaliadores salvos.... ????????????????????????/
    // TODO: adicionar quantos artigos o avaliador já tem para avaliar
    print(_evaluators);
    // _evaluators.forEach((element) async {
    //   DocumentSnapshot evaluator = await Firestore.instance.collection("events").document(widget.eventId)
    //   .collection("evaluators").document(element.documentID).get();
    //   element.data["articlesToEvaluate"] = evaluator.data["articleIds"].length;
    //   print(element.data);
    // });

    // Busca avaliadores deste trabalho
    await Firestore.instance
      .collection("events").document(widget.eventId)
      .collection("evaluators").where("articleIds", arrayContains: widget.articleId).getDocuments().then((evaluatorsThisArticle) {
        evaluatorsThisArticle.documents.forEach((element) async {
          int index = _evaluators.indexWhere((u) => u["documentID"] == element.data["userId"]);
          if(index >= 0) {
            print("?? -> ${_evaluators[index]} ${_evaluators[index].runtimeType}");
            setState(() => _selectedEvaluators.add(_evaluators[index]));
          }
        });
      });

//  (${e.data["articlesToEvaluate"]})
    _selectedEvaluatorsInit.addAll(_evaluators);

    setState(() => loadEvaluators = false);
  }

  @override
  void initState() {
    getEvaluators();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          "Alocar Trabalho",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body:   Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: StreamBuilder(
          stream: Firestore.instance.collection("events").document(widget.eventId).collection("articles").document(widget.articleId).snapshots(),
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator()
                );
              default:
                return SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        CustomCard(
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                snapshot.data.data["titulo"],
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
                              getAuthors(authors: [{ "name": snapshot.data.data["nome"] }])
                            ]
                          ),
                        ),

                        CustomCard(
                          body: Column(
                            children: [
                              loadEvaluators ? SizedBox() :
                              MultiSelectDialogField(
                                searchable: true,
                                buttonIcon: Icon(Icons.keyboard_arrow_down, size: 30),
                                buttonText: Text("Selecione os avaliadores",style: TextStyle(fontSize: 16)), 
                                cancelText: Text("Cancelar",style: TextStyle(fontSize: 16)),
                                confirmText: Text("Ok",style: TextStyle(fontSize: 16)),
                                title: Text("Avaliadores"),
                                items: _evaluators.map((e) => MultiSelectItem(e, "(${e["articlesToEvaluate"]}) ${e["name"]}")).toList(),
                                listType: MultiSelectListType.LIST,
                                initialValue: _selectedEvaluators,
                                chipDisplay: MultiSelectChipDisplay(
                                  items: _selectedEvaluators.map((e) => MultiSelectItem(e, "${e["name"]}")).toList(),
                                  onTap: (value) {
                                    setState(() {
                                      _selectedEvaluators.remove(value);
                                    });
                                  },
                                ),
                                onConfirm: (values) {
                                  _selectedEvaluators = values;
                                  
                                  print("Avaliadores selecionados:");
                                  _selectedEvaluators.forEach((element) {
                                    print(element);
                                  });
                                },
                              ),

                              SizedBox(height: 20),
                              ButtonDefault(
                                title: "Salvar Avaliadores",
                                onTap: () {
                                  // aloca o trabalho para o avaliador 
                                  _selectedEvaluators.forEach((ev) async {
                                    DocumentSnapshot doc = await Firestore.instance
                                      .collection("events").document(widget.eventId)
                                      .collection("evaluators").document(ev["documentID"]).snapshots().first;

                                    List events = [];
                                    List articles = [];
                                    if(doc.data["eventIds"] != null)
                                      events.addAll(doc.data["eventIds"]);  
                                    if(!events.contains(widget.eventId))
                                      events.add(widget.eventId);
                                    
                                    if(doc.data["articleIds"] != null)
                                      articles.addAll(doc.data["articleIds"]);  
                                    if(!articles.contains(widget.articleId))
                                      articles.add(widget.articleId);

                                    Firestore.instance
                                      .collection("events").document(widget.eventId)
                                      .collection("evaluators").document(ev["documentID"])
                                      .updateData({
                                        "eventIds": events,
                                        "articleIds": articles
                                      });
                                  });

                                  // remove os que não estão mais como avaliadores deste trabalho
                                  _selectedEvaluatorsInit.forEach((ev) async {
                                    if(!_selectedEvaluators.contains(ev)) {
                                      DocumentSnapshot doc = await Firestore.instance
                                        .collection("events").document(widget.eventId)
                                        .collection("evaluators").document(ev["documentID"]).snapshots().first;

                                      List events = [];
                                      List articles = [];
                                      if(doc.data["eventIds"] != null)
                                        events.addAll(doc.data["eventIds"]);  
                                      if(!events.contains(widget.eventId))
                                        events.add(widget.eventId);
                                      
                                      if(doc.data["articleIds"] != null)
                                        articles.addAll(doc.data["articleIds"]);  
                                      
                                      int indexRemove = articles.indexWhere((element) => element == widget.articleId);
                                      if(indexRemove >= 0)
                                        articles.removeAt(indexRemove);

                                      Firestore.instance
                                        .collection("events").document(widget.eventId)
                                        .collection("evaluators").document(ev["documentID"])
                                        .updateData({
                                          "eventIds": events,
                                          "articleIds": articles
                                        });
                                    }
                                  });

                                  showDialog(context: context,
                                    builder: (BuildContext context){
                                      return CustomDialogBox(
                                        title: "Tudo Certo!",
                                        descriptions: "Avaliadores salvos com sucesso! Agora eles terão acesso ao formulário de avaliação deste trabalho.",
                                        text: "Ok",
                                        icon: Icons.check,
                                        iconColor: Colors.white,
                                        color: Colors.greenAccent,
                                        skipScreen: true,
                                      );
                                    }
                                  );
                                }
                              )
                            ],
                          ),
                        ),
                      ]
                    )
                  )
                );
            }
          },
        ),
      )
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