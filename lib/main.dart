import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ifeventos/views/signIn/sign-in-teste.dart';
import 'package:ifeventos/views/splash-screen/splash-screen.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

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
      home: SplashScreen()
    );
  }
}