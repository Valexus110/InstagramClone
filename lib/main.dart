import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_example/authentication/ui/auth_provider.dart' as provider;
import 'package:instagram_example/firebase_options.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:provider/provider.dart';

import 'authentication/ui/login_screen.dart';
import 'coordinate_layout/coordinate_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
        if (kDebugMode) {
          print("user is found");
        }
        screen = const CoordinateLayout();
        setState(() {
          _isLoading = false;
        });
      } else {
        if (kDebugMode) {
          print("user is not exist");
        }
        screen = const LoginScreen();
        setState(() {
          _isLoading = false;
        });
      }
    } on SocketException catch (_) {
      if (kDebugMode) {
        print("reconnecting");
      }
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
          ChangeNotifierProvider(create: (_) => provider.AuthProvider()),
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
