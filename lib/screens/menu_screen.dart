import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

// import 'package:flutter_zoom_drawer/config.dart';

import '../services/shared_preferences.dart';
import '../styles.dart';
import '../widgets/menu_screen_widgets.dart';

class MenuScreen extends StatefulWidget {
  final ValueSetter setIndex;
  final int selectedIndex;
  final ZoomDrawerController zoomDrawerController;

  const MenuScreen({
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

  @override
  void reassemble() {
    super.reassemble();
    usrPoints();
    // log("message");
  }

  @override
  void dispose() {
    super.dispose();
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
