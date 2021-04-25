import 'package:flutter/material.dart';
import 'package:ifeventos/widgets/custom-card.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleScreen extends StatefulWidget {
  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {

  Map<String, dynamic> _article = {
    "title": "Sistema de Videomonitoramento Utilizando Reconhecimento Facial",
    "authors": [
      "Augusto Franco Soares de Moura",
      "Carina Teixeira de Oliveira"
    ],
    "idTrab": 1234,
    "idProj": 4321,
  };

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

      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: <Widget>[
              
              session(
                color: Colors.yellow[200],
                textColor: Colors.yellow[800],
                title: "Este trabalho ainda não possui avaliação",
                align: TextAlign.center,
                bold: FontWeight.w800,
                size: 16
              ),
              SizedBox(height: 10),

              session(
                color: Colors.blueAccent,
                textColor: Colors.white,
                title: "Trabalho",
              ),
              CustomCard(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _article["title"],
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Text("ID Trabalho: "),
                        Text(_article["idTrab"].toString()),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text("ID Projeto: "),
                        Text(_article["idProj"].toString()),
                      ],
                    ),
                  ],
                )
              ),

              session(
                color: Colors.blueAccent,
                textColor: Colors.white,
                title: _article["authors"].length > 1 ? "Autores" : "Autor",
              ),
              CustomCard(
                body: getAuthors(
                  authors: _article["authors"]
                )
              ),

              Row(
                children: <Widget>[
                  Expanded(
                    child: buttonAction(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => RateArticleScreen(project: _article,)),
                        // );
                      },
                      title: "Avaliar Trabalho",
                      icon: Icons.assignment
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: buttonAction(
                      onTap: () => launch("http://www.uenf.br/Uenf/Downloads/Agenda_Social_8427_1312371250.pdf"),
                      title: "Baixar Artigo",
                      icon: Icons.file_download
                    ),
                  ),
                ],
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

  Widget session({ 
    @required String title, 
    @required Color color, 
    @required Color textColor,
    FontWeight bold = FontWeight.normal,
    TextAlign align = TextAlign.left,
    double size = 24 }) {
    return Container(
      width: double.maxFinite,
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
        textAlign: align,
        style: Theme.of(context).textTheme.headline5.merge(
          TextStyle(
            color: textColor,
            fontWeight: bold,
            fontSize: size
          )
        )
      ),
    );
  }

  Widget buttonAction({ 
    @required GestureTapCallback onTap, 
    @required String title,
    @required IconData icon,
    Color color = Colors.green,
    Color titleColor = Colors.white }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: color
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: titleColor
            ),
            SizedBox(width: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 16
              ),
            )
          ],
        )
      )
    );
  }
}