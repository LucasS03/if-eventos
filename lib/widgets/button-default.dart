import 'package:flutter/material.dart';

class ButtonDefault extends StatelessWidget {
  
  final String title;
  final GestureTapCallback onTap;

  ButtonDefault({ @required this.title, @required this.onTap });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: onTap,
        color: Colors.green,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white
          ),
        ),
      ),
    );
  }
}