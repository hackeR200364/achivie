import 'package:flutter/cupertino.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:task_app/screens/email_us_screen.dart';
import 'package:task_app/screens/home_screen.dart';
import 'package:task_app/screens/info_screen.dart';
import 'package:task_app/screens/menu_screen.dart';
import 'package:task_app/screens/send_sms_screen.dart';
import 'package:task_app/styles.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPageIndex = 0;

  Widget currentScreen() {
    switch (currentPageIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const InfoScreen();
      case 2:
        return const EmailUSScreen();
      case 3:
        return const SendSMSScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.easeInOut,
      androidCloseOnBackTap: true,
      angle: 0,
      style: DrawerStyle.defaultStyle,
      drawerShadowsBackgroundColor: AppColors.white,
      mainScreen: currentScreen(),
      menuScreen: MenuScreen(
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
