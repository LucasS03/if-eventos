import 'package:flutter/material.dart';
import 'package:ifeventos/views/event/new-event/new-event-date.dart';
import 'package:ifeventos/widgets/custom-card.dart';

class NewEventSiteScreen extends StatefulWidget {

  final Map<String, dynamic> newEvent;

  NewEventSiteScreen({ @required this.newEvent });

  @override
  _NewEventSiteScreenState createState() => _NewEventSiteScreenState();
}

class _NewEventSiteScreenState extends State<NewEventSiteScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _siteController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffD3D6DA),
      appBar: AppBar(
        title: Text(
          "Criar Evento",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: MediaQuery.of(context).size.height - 80,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 20),
            
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: CustomCard(
                    color: Color(0xffD3D6DA),
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Qual o link do site do seu evento?",
                          style: Theme.of(context).textTheme.headline5.merge(
                            TextStyle(color: Color(0xff313944))
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _siteController,
                            cursorColor: Colors.green,
                            validator: (value) {
                              if(_siteController.text.isEmpty)
                                return 'O site do seu evento não pode ser vazio';

                              if(!_siteController.text.contains('.'))
                                return 'Site inválido';

                              return null;
                            },
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "Exemplo: https://www.meuevento.com",
                              labelStyle: TextStyle(
                                color: Color(0xff313944)
                              ),
                              prefixIcon: Icon(
                                Icons.public, 
                                color: Color(0xff313944)
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
                  child: ElevatedButton(
                    onPressed: () {
                      if(!_formKey.currentState.validate())
                        return;
                        
                      widget.newEvent["site"] = _siteController.text;

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewEventDateScreen(newEvent: widget.newEvent)),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(61.0),
                                ),
                              ),
                    ),
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
          ),
        ),
      )
    );
  }
}