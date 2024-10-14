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

datePattern(DateTime messageDate, DateTime dateTime) {
  final difference = daysBetween(dateTime, messageDate);
  if (difference < 1) {
    return 'H:mm';
  } else if (difference < 7) {
    return 'EEEE';
  } else {
    return 'MMM, d';
  }
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}
