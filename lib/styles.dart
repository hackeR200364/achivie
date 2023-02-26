import 'package:flutter/material.dart';

class AppColors {
  static const backgroundColour = Color(0xFF665FF4);
  static const white = Colors.white;
  static const grey = Colors.grey;
  static const transparent = Colors.transparent;
  static Color blackLow = Colors.black;
  static Color? sky = Colors.blue;
  static Color? red = Colors.red;
  static Color? green = Colors.green;
  static Color? lightGreen = Colors.lightGreenAccent;
  static Color? orange = Colors.orange;
  static Color? yellow = Colors.yellow;
  static Color? lime = Colors.lime;
  static const mainColor = Color(0xFF1F1F39);
  static const mainColor2 = Color(0xFF3845AB);
  static const floatingButton = Colors.deepPurple;
  static const scrollPhysics = BouncingScrollPhysics();
  static LinearGradient customGlassIconButtonGradient = LinearGradient(
    colors: [
      AppColors.white.withOpacity(0.1),
      AppColors.white.withOpacity(0.3),
    ],
  );
  static LinearGradient customGlassButtonGradient = LinearGradient(
    colors: [
      AppColors.backgroundColour.withOpacity(0.3),
      AppColors.backgroundColour.withOpacity(0.5),
    ],
  );
  static LinearGradient customGlassIconButtonBorderGradient = LinearGradient(
    colors: [
      AppColors.white.withOpacity(0.3),
      AppColors.white.withOpacity(0.5),
    ],
  );
  static const TextStyle headingTextStyle = TextStyle(
    color: AppColors.white,
    overflow: TextOverflow.fade,
    fontSize: 17,
    fontWeight: FontWeight.bold,
    letterSpacing: 3,
  );
}
