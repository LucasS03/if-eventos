import 'package:flutter/material.dart';
import 'package:ifeventos/views/event/new-event/new-event-date.dart';
import 'package:ifeventos/widgets/custom-card.dart';

class NewEventTitleScreen extends StatefulWidget {
  @override
  _NewEventTitleScreenState createState() => _NewEventTitleScreenState();
}

class _NewEventTitleScreenState extends State<NewEventTitleScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          "Criar Evento",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: CustomCard(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Qual vai ser o título do seu evento?",
                      style: Theme.of(context).textTheme.headline5.merge(
                        TextStyle(color: Colors.grey[600])
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _titleController,
                        cursorColor: Colors.green,
                        validator: (value) {
                          if(_titleController.text.isEmpty)
                            return 'O título do seu evento não pode ser vazio';

                          if(_titleController.text.length < 5)
                            return 'O título do seu evento está muito curto';

                          return null;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Exemplo: SEMIC 2021",
                          labelStyle: TextStyle(
                            color: Colors.grey[600]
                          ),
                          prefixIcon: Icon(
                            Icons.title, 
                            color: Colors.grey[600]
                          ),
                        ),
                      )
                    ),
                  ],
                )
              ),
            ),

            SizedBox(
              height: 50,
              width: double.maxFinite,
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewEventDateScreen()),
                  );
                },
                color: Colors.green,
                child: Text(
                  "Continuar",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ]
        )
      )
    );
  }
}