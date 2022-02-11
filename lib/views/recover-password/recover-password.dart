import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecoverPasswordScreen extends StatefulWidget {
  @override
  _RecoverPasswordScreenState createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _mailController = new TextEditingController();
  bool _recovered = false;

  _recoverPassword() {
    setState(() {
      _recovered = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text("Recuperar Senha"),
      ),

      body: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Olá, nós iremos te ajudar a recuperar seu perfil! Para isso, basta inserir abaixo o seu e-mail de cadastro.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16
                  )
                ),

                TextFormField(
                  controller: _mailController,
                  cursorColor: Colors.greenAccent,
                  validator: (value) {
                    if(!_mailController.text.contains('@') || !_mailController.text.contains('.'))
                      return 'E-mail inválido';
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Seu E-mail",
                    labelStyle: TextStyle(
                      color: Colors.grey[800]
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey
                      )
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 2
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.mail, 
                      color: Colors.grey[800]
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[800]
                      )
                    )
                  ),
                ),

                Visibility(
                  visible: _recovered,
                  child: SizedBox(height: 30,)
                ),
                Visibility(
                  visible: _recovered,
                  child: Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      "Em breve você receberá um e-mail de recuperação senha",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30,),
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: RaisedButton(
                    onPressed: () {
                      if(_formKey.currentState.validate()) {
                        _recoverPassword();
                        auth.sendPasswordResetEmail(email: _mailController.text).then((value) {
                          print('Email enviado com sucesso');
                        }).catchError((e) => print(e.toString()));
                      }
                    },
                    color: Colors.green,
                    child: Text(
                      "Recuperar Senha",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
                
              ],
            )
          ),
        ),
      )
    );
  }
}