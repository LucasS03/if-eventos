import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ifeventos/views/recover-password/recover-password.dart';
import 'package:ifeventos/views/singup/sign-up.dart';
import 'package:ifeventos/views/splash-screen/splash-screen.dart';
import 'package:ifeventos/widgets/custom-dialog-box.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  TextEditingController _mailController = new TextEditingController();
  TextEditingController _pwdController = new TextEditingController();
  bool _validatePwd = false;
  bool _validateMail = false;
  bool _hiddenPassword = true;
  String _pwdError = "";
  String _mailError = "";

  _login() async {
    try {
      
      if(_pwdController.text.length < 6) {
        setState(() {
          _validatePwd = true;
          _pwdError = 'Mínimo de 6 caracteres';
        });
        return;
      } else {
        setState(() {
          _validatePwd = false;
          _pwdError = '';
        });
      }

      if(!_mailController.text.contains('@') || !_mailController.text.contains('.')){
        setState(() {
          _validateMail = true;
          _mailError = 'E-mail inválido';
        });
        return;
      } else {
        setState(() {
          _validateMail = false;
          _mailError = '';
        });
      }

      AuthResult user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _mailController.text,
        password: _pwdController.text
      );

      if(user != null ) {
        await GetStorage.init('username');
        GetStorage().write('username', _mailController.text);
        
        await GetStorage.init('userId');
        GetStorage().write('userId', user.user.uid);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      }
    } catch(err) {
      print(err);
      String error = 'Falha ao realizar login';

      if(err.code == 'ERROR_INVALID_EMAIL')
        error = 'Seu endereço de e-mail parece estar incorreto. Que tal tentar novamente?';
      else if(err.code == 'ERROR_WRONG_PASSWORD')
        error = 'Sua senha parece estar incorreta. Que tal tentar novamente?';
      else if(err.code == 'ERROR_USER_NOT_FOUND')
        error = 'O usuário [${_mailController.text}] não foi encontrado. Caso não tenha cadastro, crie uma conta no botão "Cadastre-se"';
      else if(err.code == 'ERROR_USER_DISABLED')
        error = 'O usuário [${_mailController.text}] parece ter sido desativado';
      else if(err.code == 'ERROR_TOO_MANY_REQUESTS')
        error = 'Desculpe, houveram muitas tentativas de login deste usuário [${_mailController.text}]. Tente mais tarde.';
      else if(err.code == 'ERROR_OPERATION_NOT_ALLOWED')
        error = 'Este usuário ainda não está ativo';
      
      showDialog(context: context,
        builder: (BuildContext context){
          return CustomDialogBox(
            title: "Ops... :(",
            descriptions: error,
            text: "Voltar",
            icon: Icons.close,
            iconColor: Colors.white,
            color: Colors.redAccent
          );
        }
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: Color(0xFF313944),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(30.0, 66.0, 30.0, 0.0),                  
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 50,
                            ),
                            Center(                          
                          child: Image.asset(
                            'images/logo-if-eventos.png',
                            //height: 100,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                          ],
                        ),
                        SizedBox(
                          height: 84.0,
                        ),

                        TextField(
                          controller: _mailController,
                          cursorColor: Colors.greenAccent,
                          style: TextStyle(
                              color: Color(0xFFD3D6DA)
                          ),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: "Email",
                              errorText: _validateMail ? _mailError : null,
                              labelStyle: TextStyle(
                                  color: Color(0xFFD3D6DA),
                                  fontSize: 18,
                                  fontFamily: 'Nunito'
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFD3D6DA)
                                  )
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFD3D6DA),
                                    width: 2
                                ),
                              ),
                              prefixIcon: Icon(
                                  Icons.person,
                                  color: Color(0xFFD3D6DA)
                              ),
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFD3D6DA)
                                  )
                              )
                          ),
                        ),
                        SizedBox(
                            height: 10
                        ),
                        TextField(
                          controller: _pwdController,
                          cursorColor: Colors.greenAccent,
                          obscureText: _hiddenPassword,
                          style: TextStyle(
                              color: Color(0xFFD3D6DA)
                          ),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: "Senha",
                              errorText: _validatePwd ? _pwdError : null,
                              suffix: IconButton(
                                  icon: _hiddenPassword ? Icon(Icons.visibility, color: Colors.white) : Icon(Icons.visibility_off, color: Colors.white),
                                  onPressed: () {
                                    setState(() => _hiddenPassword = !_hiddenPassword);
                                  }
                              ),
                              labelStyle: TextStyle(
                                  color: Color(0xFFD3D6DA),
                                  fontSize: 18
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFD3D6DA)
                                  )
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFD3D6DA),
                                    width: 2
                                ),
                              ),
                              prefixIcon: Icon(
                                  Icons.lock,
                                  color: Color(0xFFD3D6DA)
                              ),
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFD3D6DA)
                                  )
                              )
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RecoverPasswordScreen()),
                              );
                            },
                            child: Text(
                              "Esqueceu sua senha?",
                              style: TextStyle(
                                  color: Color(0xFFD3D6DA),
                                  fontFamily: 'Nunito',
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal
                              ),
                            ),
                          ),
                        ),

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
                              _login();
                            },
                            child: Text(
                              "Entrar",
                              style: TextStyle(
                                  color: Color(0xFF313944),
                                  fontFamily: 'Nunito',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 20.0,
                        ),

                        SizedBox(
                          height: 50,
                          width: double.maxFinite,
                          child: ElevatedButton(                    
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color(0xFF5EC095)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(61.0),
                                  
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                                      );
                            },
                            child: Text(
                              "Cadastre-se",
                              style: TextStyle(
                                  color: Color(0xFF313944),
                                  fontFamily: 'Nunito',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),

                        // Padding(
                        //     padding: const EdgeInsets.symmetric(vertical: 20.0),
                        //     child: Row(
                        //       children: <Widget>[
                        //         Text(
                        //           'Não tem conta?',
                        //           style: TextStyle(
                        //               color: Colors.white,
                        //               fontFamily: 'Nunito',
                        //               fontSize: 18,
                        //               fontWeight: FontWeight.normal
                        //           ),
                        //         ),
                        //         GestureDetector(
                        //             onTap: () {
                        //               Navigator.push(
                        //                 context,
                        //                 MaterialPageRoute(builder: (context) => SignUpScreen()),
                        //               );
                        //             },
                        //             child: Text(
                        //                 ' Cadastre-se',
                        //                 style: TextStyle(
                        //                     color: Colors.greenAccent,
                        //                     fontFamily: 'Nunito',
                        //                     fontSize: 18,
                        //                     fontWeight: FontWeight.normal
                        //                 )
                        //             )
                        //         )
                        //       ],
                        //     )
                          // RichText(
                          //   textAlign: TextAlign.center,
                          //   text: TextSpan(
                          //     text: "Não tem conta?",
                          //     style: TextStyle(
                          //       color: Colors.white,
                          //       fontFamily: 'Nunito',
                          //       fontSize: 18,
                          //       fontWeight: FontWeight.normal
                          //     ),
                          //     children: <TextSpan>[
                          //       TextSpan(
                          //         text: " Cadastre-se",
                          //         style: TextStyle(
                          //           color: Colors.greenAccent,
                          //           fontFamily: 'Nunito',
                          //           fontSize: 18,
                          //           fontWeight: FontWeight.normal
                          //         )
                          //       )
                          //     ],
                          //   ),
                          // ),
                        //),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

Future<bool> _onBackPressed() {
  return null;
}

Widget fieldForm({
    bool mail = true,
    bool pwd = false,
    @required IconData icon, 
    @required String label, 
    @required var controller
  }) {
  return TextField(
    controller: controller,
    cursorColor: Colors.greenAccent,
    obscureText: pwd,
    style: TextStyle(
      color: Colors.white
    ),
    keyboardType: mail ? TextInputType.emailAddress : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey
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
        icon, 
        color: Colors.grey
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey
        )
      )
    ),
  );
}