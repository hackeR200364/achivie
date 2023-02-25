import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:task_app/styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/app_providers.dart';
import '../providers/user_details_providers.dart';
import '../services/auth_services.dart';
import '../services/notification_services.dart';

class MenuScreen extends StatefulWidget {
  final ValueSetter setIndex;
  int selectedIndex = 0;
  MenuScreen({
    required this.setIndex,
    required this.selectedIndex,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String pointsSuffix(int points) {
    String pointsString = points.toString();
    switch (pointsString.length) {
      case 4:
        return "${pointsString[0]}k";
      case 5:
        return "${pointsString[0]}${pointsString[1]}k";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SingleChildScrollView(
        physics: AppColors.scrollPhysics,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height / 12,
            bottom: MediaQuery.of(context).size.height / 17,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  if (widget.selectedIndex != 0)
                    Consumer<UserDetailsProvider>(
                      builder: (_, userDetailsProviderProvider,
                          userDetailsProviderChild) {
                        Future.delayed(
                          Duration.zero,
                          (() {
                            userDetailsProviderProvider.userNameFunc();
                            userDetailsProviderProvider.userPointsFunc();
                          }),
                        );
                        return GlassmorphicContainer(
                          margin: EdgeInsets.only(left: 10),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 15,
                          borderRadius: 40,
                          linearGradient: LinearGradient(
                            colors: [
                              AppColors.white.withOpacity(0.1),
                              AppColors.white.withOpacity(0.3),
                            ],
                          ),
                          border: 2,
                          blur: 4,
                          borderGradient: LinearGradient(
                            colors: [
                              AppColors.white.withOpacity(0.3),
                              AppColors.white.withOpacity(0.5),
                            ],
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    userDetailsProviderProvider.userName,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      overflow: TextOverflow.fade,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    "Total points : ${userDetailsProviderProvider.userPoints.toString()}",
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
                  menuList(
                    title: "Email Us",
                    icon: Icons.email,
                    index: 2,
                  ),
                  if (Platform.isAndroid)
                    menuList(
                      title: "Send SMS",
                      icon: Icons.sms,
                      index: 3,
                    ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 6,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      socialMediaButton(
                        icon: "assets/social-icons/twitter-logo.png",
                        onPressed: (() async {
                          await launchUrl(
                            Uri.parse(
                              "https://twitter.com/rupam7803?ref_src=twsrc%5Etfw",
                            ),
                            mode: LaunchMode.externalNonBrowserApplication,
                          );
                        }),
                      ),
                      socialMediaButton(
                        icon: "assets/social-icons/instagram-logo.png",
                        onPressed: (() async {
                          await launchUrl(
                            Uri.parse(
                              "https://www.instagram.com/studnite/",
                            ),
                            mode: LaunchMode.externalNonBrowserApplication,
                          );
                        }),
                      ),
                      socialMediaButton(
                        icon: "assets/social-icons/facebook-logo.png",
                        onPressed: (() async {
                          await launchUrl(
                            Uri.parse(
                              "https://www.facebook.com/rupamkarmaka12",
                            ),
                            mode: LaunchMode.externalNonBrowserApplication,
                          );
                        }),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      socialMediaButton(
                        icon: "assets/social-icons/linkedIn-logo.png",
                        onPressed: (() async {
                          await launchUrl(
                            Uri.parse(
                              "https://www.linkedin.com/in/rupam-karmakar-411157212/",
                            ),
                            mode: LaunchMode.externalNonBrowserApplication,
                          );
                        }),
                      ),
                      socialMediaButton(
                        icon: "assets/social-icons/github-logo.png",
                        onPressed: (() async {
                          await launchUrl(
                            Uri.parse(
                              "https://github.com/hackeR200364",
                            ),
                            mode: LaunchMode.externalNonBrowserApplication,
                          );
                        }),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  importantMenuButton(
                    onTap: () {},
                    title: "Visit Website",
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  importantMenuButton(
                    onTap: (() async {
                      await launchUrl(
                        Uri.parse(
                          "https://github.com/hackeR200364/task_app",
                        ),
                        mode: LaunchMode.externalNonBrowserApplication,
                      );
                    }),
                    title: "GitHub Repository",
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Consumer<GoogleSignInProvider>(builder: (googleSignInContext,
                      googleSignInProvider, googleSignInChild) {
                    return Consumer<AllAppProviders>(
                        builder: (allAppProviderContext, allAppProvider, _) {
                      return importantMenuButton(
                        onTap: (() {
                          allAppProvider.isLoadingFunc(false);
                          const CircularProgressIndicator(
                            color: AppColors.backgroundColour,
                          );
                          Dialogs.bottomMaterialDialog(
                            enableDrag: false,
                            isDismissible: false,
                            barrierDismissible: false,
                            context: googleSignInContext,
                            color: AppColors.backgroundColour,
                            lottieBuilder:
                                Lottie.asset("assets/warning-animation.json"),
                            title: "Warning",
                            titleStyle: TextStyle(
                              color: AppColors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            msg:
                                "If you logout your, all scheduled reminders will be canceled!",
                            msgStyle: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            actions: [
                              InkWell(
                                onTap: (() {
                                  Navigator.pop(googleSignInContext);
                                }),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.mainColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: (() async {
                                  await NotificationServices()
                                      .cancelTasksNotification();
                                  await googleSignInProvider.logOut();
                                  SystemNavigator.pop();
                                }),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.mainColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Logout",
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        title: "Logout",
                      );
                    });
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector menuList({
    required String title,
    required IconData icon,
    required int index,
  }) {
    return GestureDetector(
      onTap: (() {
        setState(() {
          widget.setIndex(index);
          Future.delayed(
            Duration(
              milliseconds: 300,
            ),
            (() {
              ZoomDrawer.of(context)!.close();
            }),
          );
        });
      }),
      child: GlassmorphicContainer(
        margin: EdgeInsets.only(
          top: 20,
          left: 10,
        ),
        width: double.infinity,
        height: 41,
        borderRadius: 40,
        linearGradient: (widget.selectedIndex == index)
            ? LinearGradient(
                colors: [
                  AppColors.backgroundColour.withOpacity(0.3),
                  AppColors.backgroundColour.withOpacity(0.5),
                ],
              )
            : LinearGradient(
                colors: [
                  AppColors.white.withOpacity(0.1),
                  AppColors.white.withOpacity(0.3),
                ],
              ),
        border: 2,
        blur: 4,
        borderGradient: LinearGradient(
          colors: [
            AppColors.white.withOpacity(0.3),
            AppColors.white.withOpacity(0.5),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                icon,
                size: 25,
                color: AppColors.white,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 40,
              ),
              Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class importantMenuButton extends StatelessWidget {
  const importantMenuButton({
    super.key,
    required this.onTap,
    required this.title,
  });

  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        margin: EdgeInsets.only(
          left: 10,
        ),
        width: double.infinity,
        height: 41,
        borderRadius: 40,
        linearGradient: AppColors.customGlassButtonGradient,
        border: 2,
        blur: 4,
        borderGradient: AppColors.customGlassButtonBorderGradient,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ListTile(
// title: Text(
// title,
// style: TextStyle(
// color: AppColors.white,
// fontWeight: FontWeight.bold,
// fontSize: 17,
// ),
// ),
// leading: Icon(
// icon,
// size: 30,
// color: AppColors.white,
// ),
// onTap: (() {
// setState(() {
// widget.setIndex(index);
// Future.delayed(
// Duration(
// milliseconds: 300,
// ),
// (() {
// ZoomDrawer.of(context)!.close();
// }),
// );
// });
// }),
// selected: (widget.selectedIndex == index),
// selectedTileColor: AppColors.backgroundColour,
// )

class socialMediaButton extends StatelessWidget {
  socialMediaButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  String icon;
  VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: EdgeInsets.only(
        left: 13,
      ),
      width: 41,
      height: 41,
      borderRadius: 40,
      linearGradient: LinearGradient(
        colors: [
          AppColors.white.withOpacity(0.1),
          AppColors.white.withOpacity(0.3),
        ],
      ),
      border: 2,
      blur: 4,
      borderGradient: LinearGradient(
        colors: [
          AppColors.white.withOpacity(0.3),
          AppColors.white.withOpacity(0.5),
        ],
      ),
      child: Center(
        child: InkWell(
          onTap: onPressed,
          child: Image.asset(icon),
        ),
      ),
    );
  }
}
