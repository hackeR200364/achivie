import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:http/http.dart' as http;
import 'package:task_app/services/shared_preferences.dart';
import 'package:task_app/styles.dart';

import '../services/keys.dart';
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
    allFunc();
    super.initState();
  }

  allFunc() async {
    await usrPoints();
  }

  Future<void> usrPoints() async {
    String uid = await StorageServices.getUID();
    String token = await StorageServices.getUsrToken();
    http.Response responsePoints = await http
        .get(Uri.parse("${Keys.apiTasksBaseUrl}/usrPoints/$uid"), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    Map<String, dynamic> responseJsonPoints = jsonDecode(responsePoints.body);

    if (responsePoints.statusCode == 200) {
      if (responseJsonPoints["success"]) {
        points = responseJsonPoints[Keys.data]["usrPoints"];
      }
    }
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
