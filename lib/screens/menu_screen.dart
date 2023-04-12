import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';

import '../services/shared_preferences.dart';
import '../styles.dart';
import '../widgets/menu_screen_widgets.dart';

class MenuScreen extends StatefulWidget {
  final ValueSetter setIndex;
  int selectedIndex = 0;
  ZoomDrawerController zoomDrawerController;

  MenuScreen({
    super.key,
    required this.setIndex,
    required this.selectedIndex,
    required this.zoomDrawerController,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int points = 0;

  @override
  void initState() {
    usrPoints();
    Timer.periodic(const Duration(seconds: 15), (timer) async {
      points = await StorageServices.getUsrPoints();
      log("time started");
      // setState(() {});
    });
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    usrPoints();
    log("message");
  }

  usrPoints() async {
    points = await StorageServices.getUsrPoints();
    log(points.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: MenuScreenColumWithPadding(
        zoomDrawerController: widget.zoomDrawerController,
        widget: widget,
        points: points,
      ),
    );
  }
}
