import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();

  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return await file.readAsBytes();
  }
  if (kDebugMode) {
    print("No image selected");
  }
  return null;
}

showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 2500), content: Text(content)));
}
