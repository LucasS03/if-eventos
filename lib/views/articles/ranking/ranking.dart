import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ifeventos/views/articles/ranking/evaluator.dart';
import 'package:ifeventos/widgets/custom-card.dart';

class RankingScreen extends StatefulWidget {

  final String eventId;
  RankingScreen({ @required this.eventId });

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {

  bool _load = true;
  QuerySnapshot _articles;

  getRanking() async {
    setState(() => _load = true);
    _articles = await Firestore.instance.collection("events").document(widget.eventId).collection("ranking").orderBy("evaluate", descending: true).getDocuments();
    setState(() => _load = false);
  }

  @override
  void initState() {
    getRanking();
    super.initState();
  }

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

      body: _load ? 
        Center(child: CircularProgressIndicator()) : 
        ListView(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          children: <Widget>[
            _getRanking(
              articles: _articles
            )
          ],
        )
    );
  }

  Widget _getRanking({ @required QuerySnapshot articles }) {
    
    List<Widget> ranking = new List<Widget>();

    Color oneBg = Color.fromRGBO(218, 165, 32, 1);
    Color oneTxt = Colors.black87;

    Color twoBg = Color.fromRGBO(192, 192, 192, 1);
    Color twoTxt = Colors.black87;

    Color threeBg = Color.fromRGBO(156, 82, 33, 1);
    Color threeTxt = Colors.white;

    Color otherBg = Colors.grey[200];
    Color otherTxt = Colors.black87;
    
    for(int i = 0; i < articles.documents.length; i++) {
      ranking.add(
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EvaluatorArticleScreen(
                articleId: articles.documents[i].documentID,
                eventId: widget.eventId,
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
                        articles.documents[i]["articleTitle"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        "${articles.documents[i]["evaluate"]}",
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