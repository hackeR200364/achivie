import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:task_app/services/shared_preferences.dart';
import 'package:task_app/styles.dart';

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
    super.initState();
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
      body: SingleChildScrollView(
        physics: AppColors.scrollPhysics,
        child: MenuScreenColumWithPadding(
          zoomDrawerController: widget.zoomDrawerController,
          widget: widget,
          points: points,
        ),
      ),
    );
  }
}
