import 'package:flutter/material.dart';
import 'package:task_app/styles.dart';

class MenuScreen extends StatefulWidget {
  final ValueSetter setIndex;
  MenuScreen({
    required this.setIndex,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          menuList(
            title: "Home",
            icon: Icons.home_filled,
            index: 0,
          ),
          menuList(
            title: "Info",
            icon: Icons.info,
            index: 1,
          ),
          menuList2(
            title: "Email Us",
            icon: Icons.email,
            onPressed: (() {
              widget.setIndex(2);
            }),
          ),
          menuList2(
            title: "Send SMS",
            icon: Icons.sms,
            onPressed: (() {
              widget.setIndex(3);
            }),
          ),
        ],
      ),
    );
  }

  ListTile menuList2({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      leading: Icon(
        icon,
        size: 30,
        color: AppColors.white,
      ),
      onTap: onPressed,
    );
  }

  ListTile menuList(
      {required String title, required IconData icon, required int index}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      leading: Icon(
        icon,
        size: 30,
        color: AppColors.white,
      ),
      onTap: (() {
        setState(() {
          widget.setIndex(index);
        });
      }),
    );
  }
}
