import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:instagram_example/utils/const_variables.dart';
import 'package:instagram_example/utils/utils.dart';
import 'package:instagram_example/authentication/widgets/text_input_field.dart';
import 'package:provider/provider.dart';

import '../../coordinate_layout/coordinate_layout.dart';
import '../../main.dart';
import '../utils.dart';
import 'auth_provider.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void _selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await Provider.of<AuthProvider>(context, listen: false)
        .signupUser(
            email: _emailController.text,
            password: _passController.text,
            username: _usernameController.text,
            bio: _bioController.text,
            file: _image);
    if (!mounted) return;
    if (res == success) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CoordinateLayout()),
          (Route<dynamic> route) => false);
    } else {
      showSnackBar(context, res);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void navigateToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          //   physics: const NeverScrollableScrollPhysics(),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/ic_instagram.svg',
                    colorFilter:
                        const ColorFilter.mode(primaryColor, BlendMode.srcIn),
                    height: 64,
                  ),
                  const SizedBox(height: 20),
                  Stack(children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : const CircleAvatar(
                            radius: 64,
                            backgroundImage:
                                AssetImage('assets/ic_picture.png'),
                          ),
                    Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                            onPressed: _selectImage,
                            icon: const Icon(Icons.add_a_photo))),
                  ]),
                  const SizedBox(height: 20),
                  TextFieldInput(
                      textEditingController: _usernameController,
                      hintText: locale.enterUsername,
                      errorText: locale.usernameLength,
                      isValidate: (String text) => text.length > 2,
                      textInputType: TextInputType.text),
                  const SizedBox(height: 20),
                  TextFieldInput(
                    textEditingController: _emailController,
                    hintText: locale.enterEmail,
                    textInputType: TextInputType.emailAddress,
                    errorText: locale.badFormatEmail,
                    isValidate: emailValidation,
                  ),
                  const SizedBox(height: 20),
                  TextFieldInput(
                      textEditingController: _passController,
                      hintText: locale.enterPassword,
                      textInputType: TextInputType.text,
                      errorText: locale.passwordFormat,
                      isValidate: passFormatValidation,
                      isPass: true),
                  const SizedBox(height: 20),
                  TextFieldInput(
                      textEditingController: _bioController,
                      hintText: locale.enterBio,
                      errorText: '',
                      isValidate: (String str) => true,
                      textInputType: TextInputType.text),
                  const SizedBox(height: 20),
                  GestureDetector(
                      onTap: signUpUser,
                      child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            color: blueColor,
                          ),
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                  color: primaryColor,
                                ))
                              : Text(locale.signup))),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(locale.haveAnAccount),
                      ),
                      GestureDetector(
                          onTap: navigateToLogin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: Text(
                              locale.login,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
