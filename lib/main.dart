import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_example/providers/user_provider.dart';
import 'package:instagram_example/responsive/mobile_screen_layout.dart';
import 'package:instagram_example/responsive/resp_layout_screen.dart';
import 'package:instagram_example/responsive/web_screen_layout.dart';
import 'package:instagram_example/screens/login_screen.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCm4_khkMDfZkZ5SbPQRMs8J1XjSixPCGY",
            appId: "1:140328162940:web:7ac93922719e3aafcbdbf9",
            messagingSenderId: "140328162940",
            projectId: "instagram-clone-b9b4b",
            storageBucket: "instagram-clone-b9b4b.appspot.com"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Widget screen;
  bool _isLoading = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  getUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await InternetAddress.lookup('example.com');
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print("user is found");
        screen = const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout());
        setState(() {
          _isLoading = false;
        });
      } else {
        print("user is not exist");
        screen = const LoginScreen();
        setState(() {
          _isLoading = false;
        });
      }
    } on SocketException catch (_) {
      print("reconnecting");
      startTimer();
    }
  }

  void startTimer() {
    const time = Duration(seconds: 5);
    _timer = Timer.periodic(
      time,
      (Timer timer) {
        getUser();
        _timer.cancel();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Instagram Clone',
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: mobileBackgroundColor,
            ),
            home: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: primaryColor,
                  ))
                : LayoutBuilder(builder: (context, constraints) {
                    return screen;
                  })));
  }
}
