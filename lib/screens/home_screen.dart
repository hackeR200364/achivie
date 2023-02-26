import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:task_app/Utils/custom_glass_icon.dart';
import 'package:task_app/services/shared_preferences.dart';
import 'package:task_app/styles.dart';
import 'package:task_app/widgets/email_us_screen_widgets.dart';

import '../widgets/home_screen_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double percent = 0.2;
  int newPercent = 0;
  DateTime date = DateTime.now();
  late TabController tabController;
  String selected = "Personal", userName = "";
  // List<String> taskType = ["Business", "Personal"];
  List<String> taskType = [
    "Personal",
    "Business",
  ];
  String email = 'email', profileType = "";
  String inboxStatus = "INBOX",
      completedStatus = "Completed",
      pendingStatus = "Pending",
      deleteStatus = "Deleted";
  BannerAd? bannerAd;
  bool isBannerAdLoaded = false;
  int counter = 0;
  final assetsAudioPlayer = AssetsAudioPlayer();
  late ScrollController _scrollController;
  bool pageLoading = true;

  @override
  void initState() {
    _scrollController = ScrollController();

    tabController = TabController(
      length: 4,
      vsync: this,
    );

    getUserDetails();
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      listener: BannerAdListener(
        onAdLoaded: ((ad) {
          setState(() {
            isBannerAdLoaded = true;
            pageLoading = false;
          });
        }),
      ),
      request: const AdRequest(),
    );
    bannerAd!.load();
    assetsAudioPlayer.open(
      Audio("assets/audios/song1.mp3"),
      autoStart: false,
      showNotification: false,
      volume: 50,
    );

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void getUserDetails() async {
    email = await StorageServices.getUserEmail();
    profileType = await StorageServices.getUserSignInType();
    // print(profileType);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.mainColor,
        appBar: AppBar(
          leading: CustomAppBarLeading(
            onPressed: (() {
              ZoomDrawer.of(context)!.toggle();
            }),
            icon: Icons.menu,
          ),
          title: CustomHomeScreenAppBarTitle(
            date: date,
          ),
          actions: [
            Center(
              child: CustomGlassIconButton(
                onPressed: (() {}),
                icon: Icons.notifications,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
          ],
          elevation: 0,
          backgroundColor: AppColors.backgroundColour,
        ),
        floatingActionButton: const CustomFloatingActionButton(),
        bottomNavigationBar: (isBannerAdLoaded)
            ? CustomHomeScreenBottomNavBarWithBannerAd(bannerAd: bannerAd)
            : null,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                physics: AppColors.scrollPhysics,
                child: CustomHomeScreenContainerWithConnectivityWidget(
                    taskType: taskType,
                    tabController: tabController,
                    pendingStatus: pendingStatus,
                    email: email,
                    widget: widget,
                    scrollController: _scrollController,
                    date: date,
                    completedStatus: completedStatus,
                    inboxStatus: inboxStatus),
              ),
            ),
            if (pageLoading)
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    color: AppColors.mainColor,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
