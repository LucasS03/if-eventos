import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title, buttonText;
  final Widget content;
  final bool skipScreen;

  CustomDialog({
    @required this.title,
    @required this.content,
    this.skipScreen: false,
    this.buttonText
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.0),
                
                this.content,
                
                buttonText != null ? SizedBox(height: 24.0) : SizedBox(),
                buttonText != null ?
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    color: Colors.green,
                    onPressed: () {
                      Navigator.of(context).pop(); // To close the dialog
                      if(skipScreen)
                        Navigator.of(context).pop(); // To close the screen
                    },
                    child: Text(
                      buttonText, 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ) : SizedBox(),
              ],
            ),
          )
        ],
      )
    );
  }
}