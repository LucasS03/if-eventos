import 'package:flutter/material.dart';
import 'package:ifeventos/views/articles/ranking/rateDetail.dart';
import 'package:ifeventos/widgets/custom-card.dart';

class EvaluatorArticleScreen extends StatefulWidget {
  
  final Map<String, dynamic> project;
  EvaluatorArticleScreen({ @required this.project });

  @override
  EvaluatorArticleScreenState createState() => EvaluatorArticleScreenState();
}

class EvaluatorArticleScreenState extends State<EvaluatorArticleScreen> {
  Map<String, dynamic> _article = {
    "title": "Sistema de Videomonitoramento Utilizando Reconhecimento Facial",
    "authors": [
      "Augusto Franco Soares de Moura",
      "Carina Teixeira de Oliveira"
    ],
    "idTrab": 1234,
    "idProj": 4321,
  };

  List evaluators = [
    { 
      "idEvaluation": "123"
    },
    { 
      "idEvaluation": "234"
    },
    { 
      "idEvaluation": "345"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          _article["title"],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        children: <Widget>[
          session(
            color: Colors.blue,
            textColor: Colors.white,
            title: "Avaliadores"
          ),
          SizedBox(height: 5),

          getListEvaluator()

        ],
      ),
    );
  }

  Widget getListEvaluator() {
    List<Widget> ev = new List<Widget>();

    for(int i = 0; i < evaluators.length; i++) {
      ev.add(
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailRateArticleScreen(
                project: widget.project,
                idEvaluation: evaluators[i]["idEvaluation"],
              ))
            );
          },
          child: CustomCard(
            body: Container(
              width: double.maxFinite,
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.grey[200]),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Avaliador ${i+1}",
                    style: TextStyle(
                      fontSize: 16
                    )
                  )
                ],
              ),
            ),
          ),
        )
      );
    }

    return Column(children: ev);
  }

  Widget session({ @required String title, @required Color color, @required Color textColor }) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(3)
        ),
        color: color
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline5.merge(
          TextStyle(color: textColor)
        )
      ),
    );
  }
}