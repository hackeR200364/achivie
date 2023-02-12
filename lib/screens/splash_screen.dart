import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
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
      const Duration(seconds: 7),
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
          child: TextLiquidFill(
            boxHeight: 70,
            boxWidth: 200,
            waveColor: Colors.white,
            boxBackgroundColor: AppColors.backgroundColour,
            text: 'TASKAPP',
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
        ),
      ),
    );
  }
}
