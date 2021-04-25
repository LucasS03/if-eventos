import 'package:flutter/material.dart';

class ButtonDefault extends StatelessWidget {
  
  final String title;
  final GestureTapCallback onTap;
  final Color color;
  final TextStyle textStyle;

  ButtonDefault({ 
    @required this.title,
    @required this.onTap,
    this.color: Colors.green,
    this.textStyle: const TextStyle(
      fontFamily: 'Nunito',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white
    )
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: onTap,
        color: color,
        child: Text(
          title,
          style: textStyle
        ),
      ),
    );
  }
}