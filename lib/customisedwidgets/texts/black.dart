import 'package:dbs/theme/colors.dart';
import 'package:flutter/material.dart';

class BlackText extends StatelessWidget {
  final String text;
  final FontWeight weight;
  final double size;
  final EdgeInsets margin;

  const BlackText(
      {Key? key,
      required this.text,
      this.weight = FontWeight.bold,
      this.size = 16,
      this.margin = const EdgeInsets.all(5)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: this.margin,
      child: Text(
        this.text,
        style: TextStyle(
          fontSize: this.size,
          color: DefaultColors.black,
          fontWeight: this.weight,
        ),
        // textAlign: TextAlign.left,
      ),
    );
  }
}
