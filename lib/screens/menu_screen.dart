import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:task_app/styles.dart';
import 'package:url_launcher/url_launcher.dart';

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
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height / 5,
          bottom: MediaQuery.of(context).size.height / 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
                GestureDetector(
                  onTap: (() {}),
                  child: GlassmorphicContainer(
                    margin: EdgeInsets.only(
                      left: 10,
                    ),
                    width: double.infinity,
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
                      child: Text(
                        "Visit Website",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: (() async {
                    await launchUrl(
                      Uri.parse(
                        "https://github.com/hackeR200364/task_app",
                      ),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  }),
                  child: GlassmorphicContainer(
                    margin: EdgeInsets.only(
                      left: 10,
                    ),
                    width: double.infinity,
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
                      child: Text(
                        "GitHub Repository",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  ListTile menuList({
    required String title,
    required IconData icon,
    required int index,
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
      onTap: (() {
        setState(() {
          widget.setIndex(index);
        });
      }),
    );
  }
}

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
