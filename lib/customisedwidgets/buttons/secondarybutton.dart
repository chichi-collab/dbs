import 'package:flutter/material.dart';

import '../../theme/colors.dart';

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
      {super.key,
      this.onPressed,
      this.padding = const EdgeInsets.all(5),
      this.color = DefaultColors.green,
      this.size = 18,
      required this.text,
      this.align = Alignment.center,
      this.backgroundColor = Colors.transparent,
      this.indicator = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
            padding: WidgetStateProperty.all(padding),
            backgroundColor: WidgetStateProperty.all(backgroundColor),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)))),
        onPressed: onPressed,
        child: indicator
            ? const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(DefaultColors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                    fontSize: size, color: color, fontWeight: FontWeight.bold),
              ));
  }
}
