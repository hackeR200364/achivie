import 'package:achivie/screens/news_bloc_profile.dart';
import 'package:achivie/screens/news_discover_screen.dart';
import 'package:achivie/screens/news_saved_screen.dart';
import 'package:achivie/screens/news_screen.dart';
import 'package:achivie/screens/search_screen.dart';
import 'package:achivie/services/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../Utils/custom_glass_icon.dart';
import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';
import 'news_notification_screen.dart';

class NewsMainScreen extends StatefulWidget {
  const NewsMainScreen({Key? key}) : super(key: key);

  @override
  State<NewsMainScreen> createState() => _NewsMainScreenState();
}

class _NewsMainScreenState extends State<NewsMainScreen> {
  int screenTabIndex = 0;
  String usrName = "";
  bool hasBloc = false;
  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  void getUserDetails() async {
    usrName = await StorageServices.getUsrName();
    hasBloc = await StorageServices.getUsrHasBloc();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: CustomAppBarLeading(
          onPressed: (() {
            ZoomDrawer.of(context)!.toggle();
            // print(isPlaying);
          }),
          icon: Icons.menu,
        ),
        actions: [
          if (screenTabIndex == 1)
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Center(
                child: CustomGlassIconButton(
                  onPressed: (() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (notificationContext) => const SearchScreen(),
                      ),
                    );
                  }),
                  icon: Icons.search,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Center(
              child: CustomGlassIconButton(
                onPressed: (() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (notificationContext) =>
                          const NewsNotificationScreen(),
                    ),
                  );
                }),
                icon: Icons.notifications,
              ),
            ),
          ),
        ],
        title: GlassmorphicContainer(
          width: double.infinity,
          height: 41,
          borderRadius: 40,
          linearGradient: AppColors.customGlassIconButtonGradient,
          border: 2,
          blur: 4,
          borderGradient: AppColors.customGlassIconButtonBorderGradient,
          child: Center(
            child: Text(
              (screenTabIndex == 0)
                  ? "All News"
                  : (screenTabIndex == 1)
                      ? "Discover News"
                      : (screenTabIndex == 2)
                          ? "Saved News"
                          : (screenTabIndex == 3)
                              ? usrName
                              : "",
              style: AppColors.subHeadingTextStyle,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: 12,
          right: 12,
        ),
        child: GNav(
          gap: 8,
          activeColor: AppColors.white,
          iconSize: 24,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          duration: Duration(milliseconds: 400),
          tabBackgroundColor: AppColors.backgroundColour.withOpacity(0.55),
          color: Colors.black,
          onTabChange: ((tabIndex) {
            setState(() {
              screenTabIndex = tabIndex;
            });
          }),
          tabs: [
            GButton(
              icon: (screenTabIndex == 0)
                  ? Icons.home_filled
                  : Icons.home_outlined,
              text: "News",
              textColor: AppColors.white,
              iconColor: AppColors.white,
            ),
            GButton(
              icon: (screenTabIndex == 1)
                  ? Icons.explore
                  : Icons.explore_outlined,
              text: "Discover",
              textColor: AppColors.white,
              iconColor: AppColors.white,
            ),
            GButton(
              icon: (screenTabIndex == 2)
                  ? Icons.bookmark
                  : Icons.bookmark_border_outlined,
              text: "Saved",
              textColor: AppColors.white,
              iconColor: AppColors.white,
            ),
            GButton(
              icon: (screenTabIndex == 3)
                  ? Icons.account_circle
                  : Icons.account_circle_outlined,
              text: "Profile",
              textColor: AppColors.white,
              iconColor: AppColors.white,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (screenTabIndex == 0) NewsScreen(),
          if (screenTabIndex == 1) NewsDiscoverScreen(),
          if (screenTabIndex == 2) NewsSavedScreen(),
          if (screenTabIndex == 3)
            NewsBlocProfile(
              hasBloc: hasBloc,
            ),
        ],
      ),
    );
  }
}
