import 'package:animated_button/animated_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleButton extends StatefulWidget {

  final String title;
  final VoidCallback fun;


  SimpleButton(this.title, this.fun);

  @override
  _SimpleButtonState createState() => _SimpleButtonState();
}

class _SimpleButtonState extends State<SimpleButton> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedButton(
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          color: Colors.blue,
          onPressed: widget.fun,
          enabled: true,
          shadowDegree: ShadowDegree.light,
        ),
    );
  }
}