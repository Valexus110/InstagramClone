// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_example/authentication/ui/auth_provider.dart' as provider;
import 'package:instagram_example/authentication/utils.dart';
import 'package:instagram_example/authentication/widgets/text_input_field.dart';
import 'package:instagram_example/chat/ui/chat_provider.dart';
import 'package:instagram_example/chat/ui/chat_screen.dart';

import 'package:instagram_example/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('find my custom widgets', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final loginTextField = TextFieldInput(
        textEditingController: TextEditingController(),
        hintText: locale.enterEmail,
        errorText: locale.badFormatEmail,
        isValidate: emailValidation,
        textInputType: TextInputType.datetime);
    await tester.pumpWidget(MaterialApp(home: Material(child: loginTextField)));
    expect(find.byWidget(loginTextField), findsOneWidget);
  });

  testWidgets('find Text Widgets', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
        Text(locale.haveNotAnAccount, textDirection: TextDirection.ltr));
    expect(find.text(locale.haveNotAnAccount), findsOneWidget);
    await tester.pumpWidget(
        Text(locale.haveAnAccount, textDirection: TextDirection.ltr));
    expect(find.text(locale.haveAnAccount), findsOneWidget);
  });


}
