import 'package:flutter/material.dart';

import '../styles/styles.dart';

class StyledFlatButton extends StatelessWidget {
  final String text;
  final onPressed;
  final double radius;

  const StyledFlatButton(this.text,
      {this.onPressed, Key? key, this.radius = 5.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      //color: Colors.blue[500],
      //splashColor: Colors.blue[200],
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18.0),
        child: Text(
          this.text,
          style: Styles.p.copyWith(
            color: Colors.white,
            height: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onPressed: () {
        this.onPressed();
      },
    );
  }
}
