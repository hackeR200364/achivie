import 'package:flutter/material.dart';

class AppColors {
  static const backgroundColour = Color(0xFF665FF4);
  static const white = Colors.white;
  static const grey = Colors.grey;
  static const transparent = Colors.transparent;
  static const blackLow = Colors.black;
  static const sky = Colors.blue;
  static const red = Colors.red;
  static const diamond = Colors.lightBlue;
  static const diamondDark = Colors.blueAccent;
  static const green = Colors.green;
  static const lightGreen = Colors.lightGreenAccent;
  static const orange = Colors.orange;
  static const yellow = Colors.yellow;
  static const lime = Colors.lime;
  static const mainColor = Color(0xFF1F1F39);
  static const gold = Color(0xFFF2CD5C);
  static const goldDark = Color(0xFFF2921D);
  static const mainColor2 = Color(0xFF3845AB);
  static const floatingButton = Colors.deepPurple;
  static const mentionText = Color(0xFFcff4fe);
  static const mentionTextDark = Color(0xFFa3ebff);
  static const scrollPhysics = BouncingScrollPhysics();
  static final LinearGradient customGlassIconButtonGradient = LinearGradient(
    colors: [
      AppColors.white.withOpacity(0.1),
      AppColors.white.withOpacity(0.3),
    ],
  );
  static final LinearGradient customGlassButtonGradient = LinearGradient(
    colors: [
      AppColors.backgroundColour.withOpacity(0.3),
      AppColors.backgroundColour.withOpacity(0.5),
    ],
  );
  static const LinearGradient customGlassButtonTransparentGradient =
      LinearGradient(
    colors: [
      AppColors.transparent,
      AppColors.transparent,
    ],
  );
  static final LinearGradient customGlassIconButtonBorderGradient =
      LinearGradient(
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
  static final TextStyle subHeadingTextStyle = TextStyle(
    color: AppColors.white.withOpacity(0.7),
    fontSize: 15,
  );
}
