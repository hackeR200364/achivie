import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:task_app/styles.dart';

import '../widgets/email_us_screen_widgets.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.mainColor,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          leading: CustomAppBarLeading(
            icon: CupertinoIcons.back,
            onPressed: (() {
              Navigator.pop(context);
            }),
          ),
          title: const CustomAppBarTitle(
            heading: "Notifications",
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/empty_animation.json",
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 6,
            ),
            Center(
              child: Text(
                "Nothing to show",
                style: AppColors.headingTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
