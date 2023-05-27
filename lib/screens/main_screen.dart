import 'package:flutter/cupertino.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../styles.dart';
import 'email_us_screen.dart';
import 'home_screen.dart';
import 'info_screen.dart';
import 'menu_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPageIndex = 0;
  late ZoomDrawerController zoomDrawerController;

  @override
  void initState() {
    zoomDrawerController = ZoomDrawerController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget currentScreen() {
    switch (currentPageIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const InfoScreen();
      case 2:
        return const EmailUSScreen();
      // case 3:
      //   return const NewsMainScreen();

      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: zoomDrawerController,
      openCurve: Curves.easeOut,
      androidCloseOnBackTap: true,
      angle: 0,
      style: DrawerStyle.defaultStyle,
      drawerShadowsBackgroundColor: AppColors.white,
      mainScreen: currentScreen(),
      menuScreen: MenuScreen(
        zoomDrawerController: zoomDrawerController,
        selectedIndex: currentPageIndex,
        setIndex: ((index) {
          setState(() {
            currentPageIndex = index;
          });
        }),
      ),
      menuBackgroundColor: AppColors.mainColor,
      showShadow: true,
    );
  }
}
