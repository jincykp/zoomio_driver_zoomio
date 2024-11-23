import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Profilefields extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  String? Function(String?)? validator;
  Widget? prefixIcon;
  Widget? suffixIcon;
  final bool readOnly;
  final TextInputType? keyBoardType;
  final TextStyle? textStyle;
  final List<TextInputFormatter>? inputFormatters;
  Profilefields(
      {super.key,
      required this.controller,
      this.validator,
      required this.hintText,
      this.prefixIcon,
      this.inputFormatters,
      this.suffixIcon,
      this.keyBoardType,
      this.readOnly = false,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyBoardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      style: textStyle,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(19)),
        ),
        hintText: hintText,
        hintStyle: textStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      readOnly: readOnly,
      validator: validator,
      inputFormatters: inputFormatters,
      onTap: readOnly
          ? () {
              FocusScope.of(context).requestFocus(FocusNode());
            }
          : null,
    );
  }
}

class ProfileFields extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  String? Function(String?)? validator;
  Widget? prefixIcon;
  Widget? suffixIcon;
  final bool readOnly;
  final TextInputType? keyBoardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textStyle;
  ProfileFields({
    super.key,
    required this.controller,
    this.validator,
    required this.hintText,
    this.prefixIcon,
    this.inputFormatters,
    this.suffixIcon,
    this.keyBoardType,
    this.readOnly = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyBoardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      // style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(19)),
         // borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(19)),
          // borderSide:
          //     BorderSide(color: Colors.black), // Border color when enabled
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(19)),
          borderSide:
              BorderSide(color: Colors.black), // Border color when focused
        ),
        hintText: hintText,
        //  hintStyle: const TextStyle(color: Colors.black), // Hint text color
        // labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
