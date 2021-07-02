import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ifeventos/widgets/custom-card.dart';

class EvaluatorArticleScreen extends StatefulWidget {
  
  final String eventId;
  final String articleId;

  EvaluatorArticleScreen({ @required this.eventId, @required this.articleId });

  @override
  EvaluatorArticleScreenState createState() => EvaluatorArticleScreenState();
}

class EvaluatorArticleScreenState extends State<EvaluatorArticleScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          "Avaliações",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: StreamBuilder(
          stream: Firestore.instance
            .collection("events").document(widget.eventId)
            .collection("articles").document(widget.articleId)
            .collection("evaluations").where("finished", isEqualTo: true).snapshots(),
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator()
                );
              default:
                if(snapshot.data.documents.length == 0) 
                  return Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Text(
                      "Nenhuma avaliação foi entregue",
                      style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(
                          fontSize: 16,
                        )
                      ),
                      textAlign: TextAlign.center,
                    )
                  );

                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (c, i) {
                    return CustomCard(
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Avaliador ${i+1}",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Divider(),

                            Visibility(
                              visible: !snapshot.data.documents[i].data.containsKey("didNotAttend") || !snapshot.data.documents[i].data["didNotAttend"],
                              child: Column(
                                children: [
                                  item(description: "Na Introdução consta claramente a relevância do tema e os seus objetivos:", value: snapshot.data.documents[i].data["clarity"]),
                                  SizedBox(height:15),
                                  item(description: "Fundamentação teórico-científica:", value: snapshot.data.documents[i].data["reasoning"]),
                                  SizedBox(height:15),
                                  item(description: "Adequação da metodologia ao tipo de trabalho:", value: snapshot.data.documents[i].data["methodologyAdequacy"]),
                                  SizedBox(height:15),
                                  item(description: "Domínio do conteúdo na apresentação:", value: snapshot.data.documents[i].data["domain"]),
                                  SizedBox(height:15),
                                  item(description: "Qualidade da organização e apresentação do trabalho (recursos didáticos utilizados, slides e outros):", value: snapshot.data.documents[i].data["quality"]),
                                  SizedBox(height:15),
                                  item(description: "Apresentação dos resultados (parciais ou finais) e conclusões:", value: snapshot.data.documents[i].data["results"]),
                                  SizedBox(height:15),
                                  item(description: "Adequação da apresentação ao tempo disponível:", value: snapshot.data.documents[i].data["time"]),
                                ],
                              )
                            ),

                            Visibility(
                              visible: snapshot.data.documents[i].data.containsKey("didNotAttend") && snapshot.data.documents[i].data["didNotAttend"],
                              child: CustomCard(
                                color: Colors.yellow[100],
                                body: Text(
                                  "Apresentador não compareceu",
                                  style: Theme.of(context).textTheme.headline6.merge(
                                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              )
                            ),
                          
                        ],
                      ),
                    );
                  }
                );
                
            }
          }
        )
      )
    );
  }

  Widget item({ @required String description, @required double value }) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Text(
            description,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.green,
            child: Text(
              value.toString(),
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            )
          ),
        ),
      ]
    );
  }

}