import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class PrimaryButton extends StatelessWidget {
  final void Function()? onPressed;
  final String buttonText;
  final double elevation;
  final bool indicator;

  const PrimaryButton(
      {super.key,
      this.onPressed,
      this.buttonText = '',
      this.elevation = 10,
      this.indicator = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          padding: WidgetStateProperty.resolveWith((states) {
            return const EdgeInsets.symmetric(vertical: 10, horizontal: 20);
          }),
          elevation: WidgetStateProperty.resolveWith(
              (states) => onPressed == null ? 0 : elevation),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return DefaultColors.green;
          })),
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
          : Text(buttonText,
              style: const TextStyle(
                  color: DefaultColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
    );
  }
}
