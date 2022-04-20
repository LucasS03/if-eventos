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
      backgroundColor: Color(0xffD3D6DA),
      // appBar: AppBar(
      //   title: Text("Recuperar Senha"),
      // ),

      body: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.fromLTRB(30.0, 66.0, 30.0, 0.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 80.0,
                ),
                Center(
                  child: Image.asset('images/person-recovery-password.png'),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Text(
                  "Para recuperação de senha, insira abaixo o seu email de cadastro.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff313944)
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
                      Icons.alternate_email, 
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
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFF70C836)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(61.0),
                                ),
                              ),
                    ),
                    onPressed: () {
                      if(_formKey.currentState.validate()) {
                        _recoverPassword();
                        auth.sendPasswordResetEmail(email: _mailController.text).then((value) {
                          print('Email enviado com sucesso');
                        }).catchError((e) => print(e.toString()));
                      }
                    },
                    child: Text(
                      "Recuperar Senha",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff313944)
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