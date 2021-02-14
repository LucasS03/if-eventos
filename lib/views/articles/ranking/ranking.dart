import 'package:flutter/material.dart';
import 'package:ifeventos/views/articles/ranking/evaluator.dart';
import 'package:ifeventos/widgets/custom-card.dart';

class RankingScreen extends StatefulWidget {
  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {

  List<Map<String, dynamic>> _articles = [
    {
      "title": "Aplicação de Técnicas de Machine Learning na Análise Automatizada do Mercado Financeiro",
      "authors": [
        "Alexandre Pereira da Silva"
      ],
      "rate": 20.0
    },
    {
      "title": "Sistema de Videomonitoramento Utilizando Reconhecimento Facial",
      "authors": [
        "Augusto Franco Soares de Moura",
        "Carina Teixeira de Oliveira"
      ],
      "rate": 30.0
    },
    {
      "title": "Mancha Branca? Antes e Hoje",
      "authors": [
        "Antônio José Felipe Cosme"
      ],
      "rate": 10.0
    },
    {
      "title": "Mancha Branca? Antes e Hoje",
      "authors": [
        "Antônio José Felipe Cosme"
      ],
      "rate": 5.0
    },
    {
      "title": "Mancha Branca? Antes e Hoje",
      "authors": [
        "Antônio José Felipe Cosme"
      ],
      "rate": 5.0
    },
    {
      "title": "Mancha Branca? Antes e Hoje",
      "authors": [
        "Antônio José Felipe Cosme"
      ],
      "rate": 5.0
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          "Ranking de Trabalhos",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        children: <Widget>[
          _getRanking(
            articles: _articles
          )
        ],
      )
    );
  }

  Widget _getRanking({ @required List<Map<String, dynamic>> articles }) {
    
    articles.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      return a["rate"] < b["rate"] ? 1 : 0;
    });

    List<Widget> ranking = new List<Widget>();

    Color oneBg = Color.fromRGBO(218, 165, 32, 1);
    Color oneTxt = Colors.black87;

    Color twoBg = Color.fromRGBO(192, 192, 192, 1);
    Color twoTxt = Colors.black87;

    Color threeBg = Color.fromRGBO(156, 82, 33, 1);
    Color threeTxt = Colors.white;

    Color otherBg = Colors.grey[200];
    Color otherTxt = Colors.black87;
    
    for(int i = 0; i < articles.length; i++) {
      ranking.add(
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EvaluatorArticleScreen(
                project: articles[i],
              )),
            );
          },
          child: CustomCard(
            body: Row(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == 0 ? oneBg : i == 1 ? twoBg : i == 2 ? threeBg : otherBg
                  ),
                  child: Center(
                    child: Text(
                      "${i+1}",
                      style: Theme.of(context).textTheme.headline6.merge(
                        TextStyle(
                          color: i == 0 ? oneTxt : i == 1 ? twoTxt : i == 2 ? threeTxt : otherTxt
                        )
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        articles[i]["title"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        "${articles[i]["rate"]}",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w800
                        ),
                      )
                    ],
                  )
                ),
              ],
            )
          ),
        )
      );
    }

    return Column(
      children: ranking
    );
  }
}