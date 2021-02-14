import 'package:flutter/material.dart';
import 'package:ifeventos/widgets/custom-card.dart';

class DetailRateArticleScreen extends StatefulWidget {

  final Map<String, dynamic> project;
  final String idEvaluation;
  
  DetailRateArticleScreen({ 
    @required this.project ,
    @required this.idEvaluation
  });

  @override
  _DetailRateArticleScreenState createState() => _DetailRateArticleScreenState();
}

class _DetailRateArticleScreenState extends State<DetailRateArticleScreen> {

  double _item1 = 3;
  double _item2 = 3;
  double _item3 = 3;
  double _item4 = 3;
  double _item5 = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          widget.project["title"],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: <Widget>[
              session(
                color: Colors.blue,
                textColor: Colors.white,
                title: "Avaliador"
              ),
              CustomCard(
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
                        "Samuel Lucas da Silva Sena",
                        style: TextStyle(
                          fontSize: 16
                        )
                      )
                    ],
                  ),
                ),
              ),

              session(
                color: Colors.blue,
                textColor: Colors.white,
                title: "Trabalho e Avaliação"
              ),
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
                      "Na Introdução consta claramente a relevância do tema e os seus objetivos:",
                      style: Theme.of(context).textTheme.headline6,
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
                            onChanged: null,
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
                      style: Theme.of(context).textTheme.headline6,
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
                            onChanged: null,
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
                      style: Theme.of(context).textTheme.headline6,
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
                            onChanged: null,
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
                      style: Theme.of(context).textTheme.headline6,
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
                            onChanged: null,
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
                      style: Theme.of(context).textTheme.headline6,
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
                            onChanged: null,
                          ),
                        ),
                        Text("5", style: TextStyle(fontSize: 16))
                      ],
                    ),
                  ],
                )
              ),

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
              Text(el)
            ],
          ),
        )
      );
    });

    return Column(children: a);
  }

  Widget session({ @required String title, @required Color color, @required Color textColor }) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(5),
      width: double.maxFinite,
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