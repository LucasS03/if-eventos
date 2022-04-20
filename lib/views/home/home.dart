import 'package:flutter/material.dart';
import 'package:ifeventos/views/event/event.dart';
import 'package:ifeventos/views/signIn/sign-in.dart';
import 'package:ifeventos/views/splash-screen/splash-screen.dart';
import 'package:ifeventos/views/user/home-user-screen.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {

  int _currentIndex = 0;
  List _screens = new List();
  
  @override
  void initState() {
    super.initState();
    _screens.add(EventScreen());
    _screens.add(HomeUserScreen());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            body: _screens[_currentIndex],

            bottomNavigationBar: TitledBottomNavigationBar(
                activeColor: Color(0xff313944),
                currentIndex: _currentIndex,
                reverse: true,
                curve: Curves.elasticIn,
                onTap: (index){
                  setState(() => _currentIndex = index);
                },
                items: [
                  TitledNavigationBarItem(title: 'Início', icon: Icons.home),
                  // TitledNavigationBarItem(title: 'Ranking', icon: Icons.view_list),
                  TitledNavigationBarItem(title: 'Perfil', icon: Icons.person_pin)
                ]
            )
        ),
    );
  }

  Future<bool> _onBackPressed() {
    return null;
  }
}

//}
