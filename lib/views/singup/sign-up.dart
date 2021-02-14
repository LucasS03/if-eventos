import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ifeventos/widgets/custom-dialog-box.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _registrationController = new TextEditingController();
  TextEditingController _mailController = new TextEditingController();
  TextEditingController _pwdController = new TextEditingController();
  TextEditingController _cnfPwdController = new TextEditingController();
  bool _created = false;

  _register() async {
    try {
      AuthResult auth = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _mailController.text, 
        password: _pwdController.text
      );

      if(auth.user.uid != null && auth.user.uid.length > 0) {
        showDialog(context: context,
          builder: (BuildContext context){
            return CustomDialogBox(
              title: "Tudo Certo!",
              descriptions: "Sua conta foi criada. Agora você pode fazer login com seu e-mail e senha!",
              text: "Ir para o Login",
              icon: Icons.check,
              iconColor: Colors.white,
              color: Colors.greenAccent,
              skipScreen: true,
            );
          }
        );
      }
    } catch (e) {
      print(e);
      showDialog(context: context,
        builder: (BuildContext context){
          return CustomDialogBox(
            title: "Ops... :(",
            descriptions: "Houve algum erro ao criar sua conta... Que tal tentar mais tarde?",
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
    return Scaffold(
      backgroundColor: Color(0xffdddddd),
      appBar: AppBar(
        title: Text("Cadastre-se"),
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
                  "Seja bem-vindo! Nós iremos te ajudar a criar seu perfil! Para isso, basta inserir abaixo suas informações pessoais, ok?",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16
                  )
                ),

                fieldForm(
                  icon: Icons.person, 
                  label: "Nome", 
                  controller: _nameController,
                  validator: (value) {
                    if(_nameController.text.isEmpty)
                      return 'Não pode ser vazio';
                    return null;
                  }
                ),
                SizedBox(height: 10),
                fieldForm(
                  icon: Icons.branding_watermark, 
                  label: "Matrícula", 
                  controller: _registrationController,
                  mail: true,
                  validator: (value) {
                    return null;
                  }
                ),
                fieldForm(
                  icon: Icons.mail, 
                  label: "E-mail", 
                  controller: _mailController,
                  mail: true,
                  validator: (value) {
                    if(!_mailController.text.contains('@') || !_mailController.text.contains('.'))
                      return 'E-mail inválido';
                    return null;
                  }
                ),
                SizedBox(height: 10),
                fieldForm(
                  icon: Icons.lock, 
                  label: "Senha", 
                  controller: _pwdController,
                  pwd: true,
                  validator: (value) {
                    if(_pwdController.text.length < 6)
                      return 'Mínimo de 6 caracteres';
                    return null;
                  }
                ),
                SizedBox(height: 10),
                fieldForm(
                  icon: Icons.lock, 
                  label: "Confirmar Senha", 
                  controller: _cnfPwdController,
                  pwd: true,
                  validator: (value) {
                    if(_cnfPwdController.text != _pwdController.text) 
                      return 'As senhas não coincidem';
                    return null;
                  }
                ),

                SizedBox(height: 30,),
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: RaisedButton(
                    color: Colors.green,
                    onPressed: _created ? null : () {
                      if(_formKey.currentState.validate())
                        _register();
                    },
                    child: Text(
                      "Cadastrar",
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
            ),
          ),
        ),
      ),
    );
  }
}

Widget fieldForm({
    bool mail = true,
    bool pwd = false,
    @required IconData icon, 
    @required String label, 
    @required var controller,
    @required FormFieldValidator validator
  }) {
  return TextFormField(
    controller: controller,
    cursorColor: Colors.greenAccent,
    obscureText: pwd,
    validator: validator,
    keyboardType: mail ? TextInputType.emailAddress : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
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
        icon, 
        color: Colors.grey[800]
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey[800]
        )
      )
    ),
  );
}