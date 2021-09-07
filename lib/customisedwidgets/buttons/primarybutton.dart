import 'package:dbs/theme/colors.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final void Function()? onPressed;
  final String buttonText;
  final double elevation;
  final bool indicator;

  PrimaryButton(
      {this.onPressed,
      this.buttonText = '',
      this.elevation = 10,
      this.indicator = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          padding: MaterialStateProperty.resolveWith((states) {
            return EdgeInsets.symmetric(vertical: 10, horizontal: 20);
          }),
          elevation: MaterialStateProperty.resolveWith(
              (states) => this.onPressed == null ? 0 : this.elevation),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            return DefaultColors.green;
          })),
      onPressed: this.onPressed,
      child: indicator
          ? Container(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(DefaultColors.white),
                strokeWidth: 2,
              ),
            )
          : Text(this.buttonText,
              style: TextStyle(
                  color: DefaultColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
    );
  }
}
