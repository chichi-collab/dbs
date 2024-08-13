import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class BlackText extends StatelessWidget {
  final String text;
  final FontWeight weight;
  final double size;
  final EdgeInsets margin;

  const BlackText(
      {super.key,
      required this.text,
      this.weight = FontWeight.bold,
      this.size = 16,
      this.margin = const EdgeInsets.all(5)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          color: DefaultColors.black,
          fontWeight: weight,
        ),
        // textAlign: TextAlign.left,
      ),
    );
  }
}
