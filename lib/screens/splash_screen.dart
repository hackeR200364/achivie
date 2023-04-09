import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:task_app/screens/main_screen.dart';
import 'package:task_app/screens/permission_denied_screen.dart';
import 'package:task_app/screens/sign_screen.dart';
import 'package:task_app/services/shared_preferences.dart';
import 'package:task_app/styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool signStatus = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    getUserSignStatus();
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    Timer(
      const Duration(seconds: 3),
      () => checkAllPermissions(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkAllPermissions() async {
    signStatus = await StorageServices.getSignStatus();

    Map<Permission, PermissionStatus> statuses = await [
      Permission.accessNotificationPolicy,
      Permission.notification,
      // Permission.phone,
      // Permission.sms,
    ].request();

    // Check if any of the permissions are denied
    bool isAnyPermissionDenied =
        statuses.values.any((status) => status.isDenied);

    if (isAnyPermissionDenied) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PermissionDeniedScreen(),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = 0.0;
            var end = 1.0;
            var curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return ScaleTransition(
              scale: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } else {
      // All permissions are granted
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              (signStatus) ? const MainScreen() : const SignUpScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = 0.0;
            var end = 1.0;
            var curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return ScaleTransition(
              scale: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  void getUserSignStatus() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.mainColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png",
              scale: 1,
              height: MediaQuery.of(context).size.height / 3,
              opacity: _animation,
            ),
            TextLiquidFill(
              loadDuration: const Duration(seconds: 3),
              waveDuration: const Duration(seconds: 2),
              boxHeight: MediaQuery.of(context).size.height / 10,
              boxWidth: MediaQuery.of(context).size.width,
              waveColor: Colors.white,
              boxBackgroundColor: AppColors.mainColor,
              text: 'Achivie',
              textStyle: const TextStyle(
                letterSpacing: 7,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
