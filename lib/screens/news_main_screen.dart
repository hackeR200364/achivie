import 'package:achivie/screens/reports_upload_screen.dart';
import 'package:achivie/screens/search_screen.dart';
import 'package:achivie/services/shared_preferences.dart';
import 'package:circular_clip_route/circular_clip_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../Utils/custom_glass_icon.dart';
import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';
import 'news_bloc_profile.dart';
import 'news_discover_screen.dart';
import 'news_notification_screen.dart';
import 'news_saved_screen.dart';
import 'news_screen.dart';

class NewsMainScreen extends StatefulWidget {
  const NewsMainScreen({Key? key}) : super(key: key);

  @override
  State<NewsMainScreen> createState() => _NewsMainScreenState();
}

class _NewsMainScreenState extends State<NewsMainScreen>
    with TickerProviderStateMixin {
  int screenTabIndex = 0;
  String usrName = "", blocName = "";
  bool hasBloc = false, isDownwards = false;
  // late AnimationController controllerToIncreasingCurve;
  // late AnimationController controllerToDecreasingCurve;
  // late Animation<double> animationIncreasingCurve;
  // late Animation<double> animationDecreasingCurve;
  // ScrollController? _scrollController;

  Animatable<double>? nextScreenOpacity;
  late AnimationController _animationController;

  @override
  void initState() {
    // _scrollController = ScrollController();
    // controllerToIncreasingCurve = AnimationController(
    //   duration: const Duration(milliseconds: 400),
    //   vsync: this,
    // );
    // controllerToDecreasingCurve = AnimationController(
    //   duration: const Duration(milliseconds: 400),
    //   vsync: this,
    // );
    //
    // animationIncreasingCurve = Tween<double>(begin: 0, end: 100).animate(
    //   CurvedAnimation(
    //     parent: controllerToIncreasingCurve,
    //     curve: Curves.fastLinearToSlowEaseIn,
    //   ),
    // )..addListener(() {
    //     setState(() {});
    //   });
    // animationDecreasingCurve = Tween<double>(begin: 100, end: 0).animate(
    //   CurvedAnimation(
    //     parent: controllerToDecreasingCurve,
    //     curve: Curves.fastLinearToSlowEaseIn,
    //   ),
    // )..addListener(() {
    //     setState(() {});
    //   });

    nextScreenOpacity = Tween<double>(begin: 0.0, end: 1.0);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Set the desired duration
    );
    nextScreenOpacity = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 1.0,
      ),
    ]);
    getUserDetails();
    super.initState();
  }

  void getUserDetails() async {
    usrName = await StorageServices.getUsrName();
    hasBloc = await StorageServices.getUsrHasBloc();
    if (hasBloc) {
      blocName = (await StorageServices.getBlocName())!;
    }
    setState(() {});
  }

  final _searchBtnKey = GlobalKey();
  final _notificationBtnKey = GlobalKey();
  final _uploadBtnKey = GlobalKey();
  // final _avatarKey = GlobalKey();

  // void _scrollToTop() {
  //   _scrollController!.animateTo(
  //     0,
  //     duration: const Duration(milliseconds: 300),
  //     curve: Curves.easeInOut,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // _scrollController!.position.toString();
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
                  key: _searchBtnKey,
                  onPressed: (() {
                    // RenderBox renderbox = _searchBtnKey.currentContext!
                    //     .findRenderObject() as RenderBox;
                    // Offset position = renderbox.localToGlobal(Offset.zero);
                    // double x = position.dx;
                    // double y = position.dy;
                    // log("x = $x");
                    // log("y = $y");
                    // controllerToIncreasingCurve.forward();
                    Navigator.push(
                      context,
                      CircularClipRoute(
                        expandFrom: _searchBtnKey.currentContext!,
                        curve: Curves.fastOutSlowIn,
                        reverseCurve: Curves.fastOutSlowIn.flipped,
                        opacity: ConstantTween(1),
                        transitionDuration: const Duration(milliseconds: 650),
                        builder: ((_) => SearchScreen()),
                      ), // CustomPageTransitionAnimation(
                      //   enterWidget: SearchScreen(),
                      //   x: 0.5,
                      //   y: -0.85,
                      // ),
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
                key: _notificationBtnKey,
                onPressed: (() {
                  Navigator.push(
                    context,
                    CircularClipRoute(
                      expandFrom: _notificationBtnKey.currentContext!,
                      curve: Curves.fastOutSlowIn,
                      reverseCurve: Curves.fastOutSlowIn.flipped,
                      opacity: ConstantTween(1),
                      transitionDuration: const Duration(milliseconds: 700),
                      builder: ((_) => NewsNotificationScreen()),
                    ), // CustomPageTransitionAnimation(
                    //   enterWidget: SearchScreen(),
                    //   x: 0.5,
                    //   y: -0.85,
                    // ),
                  );

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (notificationContext) =>
                  //         const NewsNotificationScreen(),
                  //   ),
                  // );
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
                              ? (hasBloc)
                                  ? blocName
                                  : usrName
                              : "",
              style: AppColors.subHeadingTextStyle,
            ),
          ),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: AnimatedContainer(
        key: _uploadBtnKey,
        duration: Duration(
          milliseconds: 100,
        ),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            color: AppColors.backgroundColour, shape: BoxShape.circle
            // borderRadius: BorderRadius.circular(20),
            ),
        child: Center(
          child: IconButton(
            icon: Center(
              child: const Icon(
                Icons.add,
                size: 30,
                color: AppColors.white,
              ),
            ),
            onPressed: (() {
              _animationController.forward();
              Navigator.push(
                context,
                CircularClipRoute(
                  border: Border.all(
                    width: 0,
                    color: AppColors.transparent,
                  ),
                  shadow: [
                    BoxShadow(
                      color: AppColors.transparent,
                      blurRadius: 100,
                    )
                  ],
                  expandFrom: _uploadBtnKey.currentContext!,
                  curve: Curves.ease,
                  reverseCurve: Curves.fastOutSlowIn.flipped,
                  opacity: nextScreenOpacity,
                  transitionDuration: const Duration(milliseconds: 600),
                  builder: ((_) => const ReportUploadScreen()),
                ), // CustomPageTransitionAnimation(
                //   enterWidget: SearchScreen(),
                //   x: 0.5,
                //   y: -0.85,
                // ),
              );

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (contextNext) => ReportUploadScreen(),
              //   ),
              // );
            }),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        margin: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: 12,
          right: 12,
        ),
        child: GNav(
          gap: 8,
          activeColor: AppColors.white,
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          duration: const Duration(milliseconds: 300),
          tabBackgroundColor: AppColors.backgroundColour.withOpacity(0.55),
          color: Colors.black,
          onTabChange: ((tabIndex) {
            // log(screenTabIndex.toString());
            // _scrollToTop();
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
      body: SafeArea(
        child: Stack(
          children: [
            if (screenTabIndex == 0) const NewsScreen(),
            if (screenTabIndex == 1) const NewsDiscoverScreen(),
            if (screenTabIndex == 2) const NewsSavedScreen(),
            if (screenTabIndex == 3)
              NewsBlocProfile(
                hasBloc: hasBloc,
              ),
          ],
        ),
      ),
    );
  }
}

// log(notification.metrics.pixels.toString());
// if (notification.direction == ScrollDirection.reverse) {
//   if (!isDownwards) {
//     setState(() {
//       isDownwards = true;
//     });
//   }
// }
// if (notification.direction == ScrollDirection.forward) {
//   if (isDownwards) {
//     setState(() {
//       isDownwards = false;
//     });
//   }
// }
// log(isDownwards.toString());
// if (notification.metrics.)
