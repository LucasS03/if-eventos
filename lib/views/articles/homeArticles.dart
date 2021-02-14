import 'package:flutter/material.dart';
import 'package:ifeventos/views/articles/listArticles.dart';
import 'package:ifeventos/views/articles/ranking/ranking.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

class HomeArticlesScreen extends StatefulWidget {
  @override
  _HomeArticlesScreenState createState() => _HomeArticlesScreenState();
}

class _HomeArticlesScreenState extends State<HomeArticlesScreen> {

  int _currentIndex = 0;
  List _screens = new List();
  
  @override
  void initState() {
    super.initState();
    _screens.add(ListArticlesScreen());
    _screens.add(RankingScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: TitledBottomNavigationBar(
        currentIndex: _currentIndex,
        reverse: true,
        curve: Curves.elasticIn,
        onTap: (index){
          setState(() => _currentIndex = index);
        },
        items: [
          TitledNavigationBarItem(title: 'Artigos', icon: Icons.content_paste),
          TitledNavigationBarItem(title: 'Ranking', icon: Icons.view_list)
        ]
      )
    );
  }
}