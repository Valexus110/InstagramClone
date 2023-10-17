import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_example/resources/auth_methods.dart';
import 'package:instagram_example/responsive/mobile_screen_layout.dart';
import 'package:instagram_example/responsive/resp_layout_screen.dart';
import 'package:instagram_example/responsive/web_screen_layout.dart';
import 'package:instagram_example/screens/signup_screen.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:instagram_example/utils/global_variables.dart';
import 'package:instagram_example/utils/utils.dart';
import 'package:instagram_example/widgets/text_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passController.text);
    if (!mounted) return;
    goToMainScreen(res);
    setState(() {
      _isLoading = false;
    });
  }

  void goToMainScreen(String res) {
    if (res == "Success") {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout())),
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
          //    physics: const NeverScrollableScrollPhysics(),
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
                    hintText: 'Enter your email',
                    textInputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextFieldInput(
                      textEditingController: _passController,
                      hintText: 'Enter your password',
                      textInputType: TextInputType.text,
                      isPass: true),
                  const SizedBox(height: 20),
                  InkWell(
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
                              child: const Text("Log in"))),
                  const SizedBox(height: 12),
                  //  Flexible(child: Container(), flex: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text("Don't have an account yet?"),
                      ),
                      GestureDetector(
                          onTap: navigateToSignup,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
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
