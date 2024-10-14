import 'package:flutter/material.dart';
import 'package:instagram_example/authentication/utils.dart';

import '../../main.dart';

class TextFieldInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final String errorText;
  final Function isValidate;
  final TextInputType textInputType;

  const TextFieldInput(
      {super.key,
      required this.textEditingController,
      this.isPass = false,
      required this.hintText,
      required this.errorText,
      required this.isValidate,
      required this.textInputType});

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  String? currentErrorText;

  @override
  void initState() {
    widget.textEditingController.addListener(() => setState(() {
          currentErrorText = errorString(widget.textEditingController.text);
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return TextField(
      controller: widget.textEditingController,
      decoration: InputDecoration(
        hintText: widget.hintText,
        errorText: currentErrorText,
        errorMaxLines: 2,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(0),
      ),
      keyboardType: widget.textInputType,
      obscureText: widget.isPass,
    );
  }

  String? errorString(String text) {
    if (text.isEmpty) return null;
    var validate = widget.isValidate(widget.textEditingController.text);
    if (validate) {
      if (widget.isPass) {
        return passLengthValidation(widget.textEditingController.text)
            ? null
            : locale.weakPassword;
      } else {
        return null;
      }
    }
    return widget.errorText;
  }
}
