import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/colors.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Color filledColor;
  final TextInputError? error;
  final Widget? suffixIcon;
  final bool enabled;
  final EdgeInsets margin;
  final double height;
  final Function(String)? onChanged;
  final bool autofocus;

  const CustomInput(
      {super.key,
      required this.controller,
      required this.hint,
      this.height = 65,
      this.autofocus = false,
      this.onChanged,
      this.obscureText = false,
      this.error,
      this.inputFormatters,
      this.filledColor = DefaultColors.white,
      this.keyboardType = TextInputType.text,
      this.suffixIcon,
      this.margin = EdgeInsets.zero,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      alignment: Alignment.center,
      child: TextField(
        autofocus: autofocus,
        onChanged: onChanged,
        controller: controller,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        style: const TextStyle(
            color: DefaultColors.ash, fontWeight: FontWeight.bold),
        cursorColor: DefaultColors.green,
        decoration: InputDecoration(
            enabled: enabled,
            suffixIcon: suffixIcon,
            errorText: error != null
                ? error!.visible
                    ? error!.message
                    : null
                : null,
            fillColor: filledColor,
            filled: true,
            hintText: hint,
            hintStyle: const TextStyle(
                color: DefaultColors.ash, fontWeight: FontWeight.normal),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    style: BorderStyle.solid,
                    color: DefaultColors.green,
                    width: 2)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: DefaultColors.ash, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    style: BorderStyle.solid,
                    color: DefaultColors.ash,
                    width: 2)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: DefaultColors.ash, width: 2))),
      ),
    );
  }
}

class TextInputError {
  final bool visible;
  final String? message;

  TextInputError({this.visible = false, this.message});
}
