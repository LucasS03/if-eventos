import 'package:flutter/material.dart';
import 'package:ifeventos/views/home/home.dart';
import 'package:ifeventos/views/signIn/sign-in.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IF Eventos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        cursorColor: Colors.white,
        fontFamily: 'Nunito',
      ),
      // home: SignInScreen()
      home: HomeApp()
    );
  }
}