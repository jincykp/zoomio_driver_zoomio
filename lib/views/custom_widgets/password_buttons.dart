import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomPasswordTextFormFields extends StatefulWidget {
  final bool isConfirmPassword;
  TextEditingController controller;
  String hintText;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  CustomPasswordTextFormFields({
    super.key,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.inputFormatters,
    this.isConfirmPassword = false,
  });

  @override
  State<CustomPasswordTextFormFields> createState() =>
      _CustomPasswordTextFormFieldsState();
}

class _CustomPasswordTextFormFieldsState
    extends State<CustomPasswordTextFormFields> {
  bool obscureText = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      obscureText: obscureText,
      decoration: InputDecoration(
          hintText: widget.hintText,
          suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              }),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(19)),
          )),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password ';
        }
        if (widget.isConfirmPassword && value != widget.controller.text) {
          return "Password do not match";
        }
        return widget.validator?.call(value);
      },
      inputFormatters: widget.inputFormatters,
    );
  }
}
