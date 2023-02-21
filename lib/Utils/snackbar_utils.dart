import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class SnackBarUtils {
  static final snackBarKey = GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String message) {
    snackBarKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}
