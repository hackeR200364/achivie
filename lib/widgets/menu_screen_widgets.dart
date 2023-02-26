import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/app_providers.dart';
import '../providers/user_details_providers.dart';
import '../screens/menu_screen.dart';
import '../services/auth_services.dart';
import '../services/notification_services.dart';
import '../services/shared_preferences.dart';
import '../styles.dart';

class MenuScreenColumWithPadding extends StatelessWidget {
  const MenuScreenColumWithPadding({
    super.key,
    required this.widget,
  });

  final MenuScreen widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 12,
        bottom: MediaQuery.of(context).size.height / 17,
      ),
      child: MenuScreenMainColumn(
        widget: widget,
      ),
    );
  }
}

class MenuScreenMainColumn extends StatelessWidget {
  const MenuScreenMainColumn({
    super.key,
    required this.widget,
  });

  final MenuScreen widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MenuScreenListUpperColumn(
          widget: widget,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height / 6,
        ),
        const MenuScreenListLowerColumn(),
      ],
    );
  }
}

class MenuScreenListLowerColumn extends StatelessWidget {
  const MenuScreenListLowerColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MenuScreenSocialFirstRow(),
        const SizedBox(
          height: 10,
        ),
        const MenuScreenSocialSecondRow(),
        const SizedBox(
          height: 20,
        ),
        MenuScreenExtraButton(
          onTap: () {},
          title: "Visit Website",
        ),
        const SizedBox(
          height: 20,
        ),
        MenuScreenExtraButton(
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
        const SizedBox(
          height: 20,
        ),
        const MenuScreenExtraLogoutButtonParent(),
      ],
    );
  }
}

class MenuScreenExtraLogoutButtonParent extends StatelessWidget {
  const MenuScreenExtraLogoutButtonParent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleSignInProvider>(builder:
        (googleSignInContext, googleSignInProvider, googleSignInChild) {
      return Consumer<AllAppProviders>(
          builder: (allAppProviderContext, allAppProvider, _) {
        return MenuScreenExtraLogoutButton(
          allAppProvider: allAppProvider,
          googleSignInContext: googleSignInContext,
          googleSignInProvider: googleSignInProvider,
        );
      });
    });
  }
}

class MenuScreenExtraLogoutButton extends StatelessWidget {
  const MenuScreenExtraLogoutButton(
      {super.key,
      required this.allAppProvider,
      required this.googleSignInContext,
      required this.googleSignInProvider});

  final AllAppProviders allAppProvider;
  final BuildContext googleSignInContext;
  final GoogleSignInProvider googleSignInProvider;

  @override
  Widget build(BuildContext context) {
    return MenuScreenExtraButton(
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
          lottieBuilder: Lottie.asset("assets/warning-animation.json"),
          title: "Warning",
          titleStyle: const TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          msg: "If you logout your, all scheduled reminders will be canceled!",
          msgStyle: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
          actions: [
            MenuScreenLogoutBottomSheetCancelButton(
              googleSignInContext: googleSignInContext,
            ),
            MenuScreenLogoutBottomSheetLogoutButton(
              googleSignInProvider: googleSignInProvider,
              googleSignInContext: googleSignInContext,
            ),
          ],
        );
      }),
      title: "Logout",
    );
  }
}

class MenuScreenLogoutBottomSheetLogoutButton extends StatelessWidget {
  const MenuScreenLogoutBottomSheetLogoutButton({
    super.key,
    required this.googleSignInProvider,
    required this.googleSignInContext,
  });

  final GoogleSignInProvider googleSignInProvider;
  final BuildContext googleSignInContext;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() async {
        await NotificationServices().cancelTasksNotification();
        if (await StorageServices.getUserSignInType() == "Google") {
          await googleSignInProvider.logOut();
        } else if (await StorageServices.getUserSignInType() == "Email") {
          EmailPassAuthServices().emailPassLogout(
            context: googleSignInContext,
          );
        }
        SystemNavigator.pop();
      }),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.mainColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text(
            "Logout",
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class MenuScreenLogoutBottomSheetCancelButton extends StatelessWidget {
  const MenuScreenLogoutBottomSheetCancelButton({
    super.key,
    required this.googleSignInContext,
  });
  final BuildContext googleSignInContext;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() {
        Navigator.pop(googleSignInContext);
      }),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.mainColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text(
            "Cancel",
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class MenuScreenSocialSecondRow extends StatelessWidget {
  const MenuScreenSocialSecondRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MenuScreenSocialMediaButton(
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
        MenuScreenSocialMediaButton(
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
    );
  }
}

class MenuScreenSocialFirstRow extends StatelessWidget {
  const MenuScreenSocialFirstRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MenuScreenSocialMediaButton(
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
        MenuScreenSocialMediaButton(
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
        MenuScreenSocialMediaButton(
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
    );
  }
}

class MenuScreenListUpperColumn extends StatelessWidget {
  const MenuScreenListUpperColumn({
    super.key,
    required this.widget,
  });

  final MenuScreen widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MenuScreenProfileContainer(),
        MenuListItem(
          title: "Home",
          icon: Icons.home_filled,
          index: 0,
          selectedIndex: widget.selectedIndex,
          setIndex: widget.setIndex,
        ),
        MenuListItem(
          title: "Info",
          icon: Icons.info,
          index: 1,
          selectedIndex: widget.selectedIndex,
          setIndex: widget.setIndex,
        ),
        MenuListItem(
          title: "Email Us",
          icon: Icons.email,
          index: 2,
          selectedIndex: widget.selectedIndex,
          setIndex: widget.setIndex,
        ),
        if (Platform.isAndroid)
          MenuListItem(
            title: "Send SMS",
            icon: Icons.sms,
            index: 3,
            selectedIndex: widget.selectedIndex,
            setIndex: widget.setIndex,
          ),
      ],
    );
  }
}

class MenuListItem extends StatelessWidget {
  const MenuListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.index,
    required this.selectedIndex,
    required this.setIndex,
  });

  final String title;
  final IconData icon;
  final int index;
  final ValueSetter setIndex;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() {
        setIndex(index);
        Future.delayed(
          const Duration(
            milliseconds: 100,
          ),
          (() {
            ZoomDrawer.of(context)!.close();
          }),
        );
      }),
      child: GlassmorphicContainer(
        margin: const EdgeInsets.only(
          top: 20,
          left: 10,
        ),
        width: double.infinity,
        height: 41,
        borderRadius: 40,
        linearGradient: (selectedIndex == index)
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
                  style: const TextStyle(
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

class MenuScreenProfileContainer extends StatelessWidget {
  const MenuScreenProfileContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (_, userDetailsProviderProvider, userDetailsProviderChild) {
        Future.delayed(
          Duration.zero,
          (() {
            userDetailsProviderProvider.userNameFunc();
            userDetailsProviderProvider.userPointsFunc();
          }),
        );
        return GlassmorphicContainer(
          margin: const EdgeInsets.only(left: 10),
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 15,
          borderRadius: 40,
          linearGradient: AppColors.customGlassIconButtonGradient,
          border: 2,
          blur: 4,
          borderGradient: AppColors.customGlassIconButtonBorderGradient,
          child: MenuScreenProfileContainerChildColumn(
            name: userDetailsProviderProvider.userName,
            points: userDetailsProviderProvider.userPoints,
          ),
        );
      },
    );
  }
}

class MenuScreenProfileContainerChildColumn extends StatelessWidget {
  const MenuScreenProfileContainerChildColumn({
    super.key,
    required this.name,
    required this.points,
  });

  final String name;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            style: AppColors.headingTextStyle,
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            "Total points : ${NumberFormat.compact().format(points)}",
            style: AppColors.subHeadingTextStyle,
          ),
        ],
      ),
    );
  }
}

class MenuScreenExtraButton extends StatelessWidget {
  const MenuScreenExtraButton({
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
        margin: const EdgeInsets.only(
          left: 10,
        ),
        width: double.infinity,
        height: 41,
        borderRadius: 40,
        linearGradient: AppColors.customGlassIconButtonGradient,
        border: 2,
        blur: 4,
        borderGradient: AppColors.customGlassIconButtonBorderGradient,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
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

class MenuScreenSocialMediaButton extends StatelessWidget {
  const MenuScreenSocialMediaButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final String icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(
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
