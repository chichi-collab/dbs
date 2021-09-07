import 'package:dbs/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  CustomInput(
      {required this.controller,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: height,
          margin: margin,
          child: TextField(
            autofocus: autofocus,
            onChanged: this.onChanged,
            controller: this.controller,
            obscureText: this.obscureText,
            inputFormatters: this.inputFormatters,
            keyboardType: this.keyboardType,
            style: TextStyle(
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
                hintStyle: TextStyle(
                    color: DefaultColors.ash, fontWeight: FontWeight.normal),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        style: BorderStyle.solid,
                        color: DefaultColors.green,
                        width: 2)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: DefaultColors.ash, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        style: BorderStyle.solid,
                        color: DefaultColors.ash,
                        width: 2)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: DefaultColors.ash, width: 2))),
          ),
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }
}

class TextInputError {
  final bool visible;
  final String? message;

  TextInputError({this.visible = false, this.message});
}
