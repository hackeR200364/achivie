import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:task_app/screens/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/app_providers.dart';
import '../providers/user_details_providers.dart';
import '../screens/menu_screen.dart';
import '../services/notification_services.dart';
import '../services/shared_preferences.dart';
import '../styles.dart';

class MenuScreenColumWithPadding extends StatelessWidget {
  const MenuScreenColumWithPadding({
    super.key,
    required this.widget,
    required this.zoomDrawerController,
    required this.points,
  });

  final ZoomDrawerController zoomDrawerController;
  final MenuScreen widget;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 12,
        bottom: MediaQuery.of(context).size.height / 17,
      ),
      child: MenuScreenMainColumn(
        zoomDrawerController: zoomDrawerController,
        widget: widget,
        points: points,
      ),
    );
  }
}

class MenuScreenMainColumn extends StatelessWidget {
  const MenuScreenMainColumn({
    super.key,
    required this.widget,
    required this.zoomDrawerController,
    required this.points,
  });

  final ZoomDrawerController zoomDrawerController;
  final MenuScreen widget;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MenuScreenListUpperColumn(
          zoomDrawerController: zoomDrawerController,
          widget: widget,
          points: points,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height / 2.4,
        ),
        const Padding(
          padding: EdgeInsets.only(
            left: 10,
          ),
          child: MenuScreenExtraLogoutButtonParent(),
        ),
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
    return Consumer<AllAppProviders>(
        builder: (allAppProviderContext, allAppProvider, _) {
      return MenuScreenExtraLogoutButton(
        allAppProvider: allAppProvider,
        parentContext: allAppProviderContext,
        // googleSignInContext: googleSignInContext,
        // googleSignInProvider: googleSignInProvider,
      );
    });
  }
}

class MenuScreenExtraLogoutButton extends StatelessWidget {
  const MenuScreenExtraLogoutButton(
      {super.key, required this.allAppProvider, required this.parentContext
      // required this.googleSignInContext,
      // required this.googleSignInProvider,
      });

  final AllAppProviders allAppProvider;
  final BuildContext parentContext;
  // final GoogleSignInProvider googleSignInProvider;

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
          context: parentContext,
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
              googleSignInContext: parentContext,
            ),
            MenuScreenLogoutBottomSheetLogoutButton(
              // googleSignInProvider: parentContext,
              googleSignInContext: parentContext,
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
    // required this.googleSignInProvider,
    required this.googleSignInContext,
  });

  // final GoogleSignInProvider googleSignInProvider;
  final BuildContext googleSignInContext;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() async {
        await NotificationServices().cancelTasksNotification();
        if (await StorageServices.getUsrSignInType() == "Google") {
          // await googleSignInProvider.logOut();
        } else if (await StorageServices.getUsrSignInType() == "Email") {
          // EmailPassAuthServices().emailPassLogout(
          //   context: googleSignInContext,
          // );
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
    final double spacerWidth = MediaQuery.of(context).size.width / 15;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
        SizedBox(
          width: spacerWidth,
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
    final double spacerWidth = MediaQuery.of(context).size.width / 20;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
        SizedBox(
          width: spacerWidth,
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
        SizedBox(
          width: spacerWidth,
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
        SizedBox(
          width: MediaQuery.of(context).size.width / 30,
        ),
      ],
    );
  }
}

class MenuScreenListUpperColumn extends StatelessWidget {
  const MenuScreenListUpperColumn({
    super.key,
    required this.widget,
    required this.zoomDrawerController,
    required this.points,
  });

  final MenuScreen widget;
  final ZoomDrawerController zoomDrawerController;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MenuScreenProfileContainer(
          points: points,
        ),
        MenuListItem(
          title: "Home",
          icon: Icons.home_filled,
          index: 0,
          selectedIndex: widget.selectedIndex,
          setIndex: widget.setIndex,
          zoomDrawerController: zoomDrawerController,
        ),
        MenuListItem(
          title: "Info",
          icon: Icons.info,
          index: 1,
          selectedIndex: widget.selectedIndex,
          setIndex: widget.setIndex,
          zoomDrawerController: zoomDrawerController,
        ),
        MenuListItem(
          title: "Email Us",
          icon: Icons.email,
          index: 2,
          selectedIndex: widget.selectedIndex,
          setIndex: widget.setIndex,
          zoomDrawerController: zoomDrawerController,
        ),
        // if (Platform.isAndroid)
        //   MenuListItem(
        //     title: "Send SMS",
        //     icon: Icons.sms,
        //     index: 3,
        //     selectedIndex: widget.selectedIndex,
        //     setIndex: widget.setIndex,
        //     zoomDrawerController: zoomDrawerController,
        //   ),
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
    required this.zoomDrawerController,
  });

  final String title;
  final IconData icon;
  final int index;
  final ValueSetter setIndex;
  final int selectedIndex;
  final ZoomDrawerController zoomDrawerController;

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
            ZoomDrawer.of(context)!.toggle();
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
            ? AppColors.customGlassButtonGradient
            : AppColors.customGlassButtonTransparentGradient,
        border: 2,
        blur: 4,
        borderGradient: AppColors.customGlassButtonTransparentGradient,
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
    required this.points,
  });

  final int points;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (_, userDetailsProviderProvider, userDetailsProviderChild) {
        Future.delayed(
          Duration.zero,
          (() {
            userDetailsProviderProvider.userNameFunc();
          }),
        );
        return InkWell(
          onTap: (() {
            ZoomDrawer.of(context)!.toggle();
            Navigator.push(
              _,
              MaterialPageRoute(
                builder: (profilePageContext) => const ProfileScreen(),
              ),
            );
          }),
          child: GlassmorphicContainer(
            margin: const EdgeInsets.only(left: 10),
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 15,
            borderRadius: 40,
            linearGradient: AppColors.customGlassIconButtonGradient,
            border: 2,
            blur: 4,
            borderGradient: AppColors.customGlassButtonTransparentGradient,
            child: MenuScreenProfileContainerChildColumn(
              name: userDetailsProviderProvider.userName,
              points: points,
            ),
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
        width: double.infinity,
        height: 45,
        borderRadius: 40,
        linearGradient: AppColors.customGlassButtonGradient,
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
      width: 50,
      height: 50,
      borderRadius: 40,
      linearGradient: AppColors.customGlassIconButtonGradient,
      border: 2,
      blur: 4,
      borderGradient: AppColors.customGlassIconButtonGradient,
      child: Center(
        child: InkWell(
          onTap: onPressed,
          child: Image.asset(icon),
        ),
      ),
    );
  }
}
