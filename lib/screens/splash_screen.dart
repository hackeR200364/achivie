import 'dart:async';

import 'package:flutter/material.dart';
import 'package:task_app/screens/sign_screen.dart';
import 'package:task_app/shared_preferences.dart';
import 'package:task_app/styles.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? signStatus = false;

  @override
  void initState() {
    getUserSignStatus();
    super.initState();
    Timer(
      const Duration(seconds: 5),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              (signStatus!) ? const HomeScreen() : const SignUpScreen(),
        ),
      ),
    );
  }

  void getUserSignStatus() async {
    signStatus = await StorageServices.getSignStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.backgroundColour,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Text(
                "TASKAPP",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
