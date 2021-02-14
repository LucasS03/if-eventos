import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  
  final Widget body;
  CustomCard({ @required this.body });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Colors.white
      ),
      child: body
    );
  }
}