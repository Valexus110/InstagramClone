import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_example/authentication/ui/auth_provider.dart';
import 'package:instagram_example/authentication/ui/signup_screen.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:instagram_example/utils/global_variables.dart';
import 'package:instagram_example/utils/utils.dart';
import 'package:instagram_example/authentication/widgets/text_input_field.dart';
import 'package:provider/provider.dart';

import '../../coordinate_layout/coordinate_layout.dart';
import '../../main.dart';
import '../../utils/const_variables.dart';
import '../utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await Provider.of<AuthProvider>(context, listen: false)
        .loginUser(
            email: _emailController.text, password: _passController.text);
    if (!mounted) return;
    goToMainScreen(res);
    setState(() {
      _isLoading = false;
    });
  }

  void goToMainScreen(String res) {
    if (res == success) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CoordinateLayout()),
          (Route<dynamic> route) => false);
    } else {
      showSnackBar(context, res);
    }
  }

  void navigateToSignup() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SignupScreen()));
    //   Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SafeArea(
            child: Container(
              padding: MediaQuery.of(context).size.width > webScreenSize
                  ? EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 3)
                  : const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //  Flexible(child: Container(), flex: 2),
                  SvgPicture.asset(
                    'assets/ic_instagram.svg',
                    colorFilter:
                        const ColorFilter.mode(primaryColor, BlendMode.srcIn),
                    height: 64,
                  ),
                  const SizedBox(height: 64),
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
                      errorText: locale.weakPassword,
                      isValidate: passLengthValidation,
                      isPass: true),
                  const SizedBox(height: 20),
                  GestureDetector(
                      onTap: loginUser,
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            )
                          : Container(
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
                              child: Text(locale.login))),
                  const SizedBox(height: 12),
                  //  Flexible(child: Container(), flex: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(locale.haveNotAnAccount),
                      ),
                      GestureDetector(
                          onTap: navigateToSignup,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: Text(
                             locale.signup,
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
