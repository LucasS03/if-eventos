import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ifeventos/views/home/home.dart';
import 'package:ifeventos/views/signIn/sign-in.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  void initState() {
    getUser();
    super.initState();
  }

  getUser() async {
    await GetStorage.init('username');
    final user = GetStorage().read('username');

    if(user != null) {
      String userId = GetStorage().read('userId');
      DocumentSnapshot userData = await Firestore.instance.collection("users").document(userId).snapshots().first;
      
      await GetStorage.init('userData');
      GetStorage().write('userData', userData.data);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeApp()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(50,60,70,1),
              Color.fromRGBO(28,29,42,1),
            ]
          )
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'images/if.png',
                    height: 100
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(113, 200, 55, 1)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).pop();
      //   },
      //   child: Icon(Icons.navigate_before),
      // ),
    );
  }
}
