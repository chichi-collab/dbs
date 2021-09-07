
import 'package:dbs/theme/colors.dart';
import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final Function()? onPressed;
  final String text;
  final Alignment align;
  final Color backgroundColor;
  final double size;
  final Color color;
  final EdgeInsets padding;
  final bool indicator;

  const SecondaryButton(
      {Key? key,
        this.onPressed,
        this.padding = const EdgeInsets.all(5),
        this.color = DefaultColors.green,
        this.size = 18,
        required this.text,
        this.align = Alignment.center,
        this.backgroundColor = Colors.transparent,
        this.indicator = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(

            padding: MaterialStateProperty.all(this.padding),
            backgroundColor: MaterialStateProperty.all(backgroundColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)))),
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
            : Text(
          this.text,
          style: TextStyle(
              fontSize: this.size,
              color: this.color,
              fontWeight: FontWeight.bold),
        ));
  }
}
