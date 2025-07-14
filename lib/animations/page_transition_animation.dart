import 'package:flutter/material.dart';

class CustomPageTransitionAnimation extends PageRouteBuilder {
  final Widget enterWidget;
  final double x, y;

  CustomPageTransitionAnimation({
    required this.enterWidget,
    required this.y,
    required this.x,
  }) : super(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) =>
                enterWidget,
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              animation = CurvedAnimation(
                parent: animation,
                curve: Curves.fastLinearToSlowEaseIn,
                reverseCurve: Curves.fastOutSlowIn,
              );
              return ScaleTransition(
                scale: animation,
                alignment: Alignment(x, y),
                child: child,
              );
            });
}
