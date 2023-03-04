import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Utils/custom_glass_icon.dart';
import 'package:task_app/providers/song_playing_provider.dart';
import 'package:task_app/screens/notification_screen.dart';
import 'package:task_app/services/shared_preferences.dart';
import 'package:task_app/styles.dart';
import 'package:task_app/widgets/email_us_screen_widgets.dart';
import 'package:telephony/telephony.dart';

import '../widgets/home_screen_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

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
  String songName = "";
  String songArtist = "";
  bool isPlaying = false;
  final animationDuration = const Duration(milliseconds: 300);
  bool isShowingIsland = false;
  final telephony = Telephony.instance;
  String message = "";

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
    checkCallStatus();

    Future.delayed(
      const Duration(
        milliseconds: 700,
      ),
      (() {
        setState(() {
          pageLoading = false;
        });
      }),
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

  void checkCallStatus() async {
    final callState = await telephony.callState;

    if (callState == CallState.RINGING) {
      // Incoming call
    } else if (callState == CallState.OFFHOOK) {
      // Active call
    } else {
      // No call
    }
  }

  void getIncomingSMS() async {
    if (await Telephony.instance.isSmsCapable ?? false) {
      Telephony.instance.listenIncomingSms(onNewMessage: (message) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: (isBannerAdLoaded)
            ? CustomHomeScreenBottomNavBarWithBannerAd(bannerAd: bannerAd)
            : null,
        floatingActionButton: const CustomFloatingActionButton(),
        backgroundColor: AppColors.mainColor,
        body: Stack(
          children: [
            SingleChildScrollView(
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
            Positioned(
              top: 45,
              right: 15,
              child: CustomGlassIconButton(
                onPressed: (() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (notificationContext) =>
                          const NotificationScreen(),
                    ),
                  );
                }),
                icon: Icons.notifications,
              ),
            ),
            Positioned(
              top: 45,
              left: 15,
              height: 41,
              width: 41,
              child: CustomAppBarLeading(
                onPressed: (() {
                  ZoomDrawer.of(context)!.toggle();
                  // print(isPlaying);
                }),
                icon: Icons.menu,
              ),
            ),
            Positioned(
              top: 45,
              left: 66,
              right: 66,
              // width: size.width,
              child: Consumer<SongPlayingProvider>(
                builder: (allAppContext, allAppProvider, allAppChild) {
                  return Consumer<NowPlayingTrack>(
                    builder: (nowPlayingContext, nowPlayingTrack, _) {
                      if (nowPlayingTrack.isPaused) {
                        isPlaying = true;
                        songName = nowPlayingTrack.title!;
                        songArtist = nowPlayingTrack.artist!;
                        Future.delayed(
                          Duration.zero,
                          (() {
                            allAppProvider.isSongPlayingFunc(isPlaying);
                            allAppProvider.songNameFunc(songName);
                            allAppProvider.songArtistFunc(songArtist);
                          }),
                        );
                        return Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: (() {}),
                            child: GlassmorphicContainer(
                              width: double.infinity,
                              height: 41,
                              borderRadius: 40,
                              linearGradient:
                                  AppColors.customGlassIconButtonGradient,
                              border: 2,
                              blur: 4,
                              borderGradient:
                                  AppColors.customGlassIconButtonBorderGradient,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                ),
                                child: (nowPlayingTrack.image != null &&
                                        nowPlayingTrack.title != null &&
                                        nowPlayingTrack.artist != null &&
                                        nowPlayingTrack.source != null)
                                    ? HomeAppBarTitleRow(
                                        isPaused: nowPlayingTrack.isPaused,
                                        size: size,
                                        hasImage: nowPlayingTrack.hasImage,
                                        image: nowPlayingTrack.image!,
                                        title: nowPlayingTrack.title!,
                                        artist: nowPlayingTrack.artist!,
                                        source: nowPlayingTrack.source!,
                                      )
                                    : const Center(
                                        child: Text(
                                          "Loading...",
                                          style: AppColors.headingTextStyle,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      }

                      if (nowPlayingTrack.isStopped) {
                        isPlaying = false;
                        Future.delayed(
                          Duration.zero,
                          (() {
                            allAppProvider.isSongPlayingFunc(isPlaying);
                          }),
                        );
                        return CustomHomeScreenAppBarTitle(
                          date: date,
                        );
                      }

                      if (nowPlayingTrack.isPlaying) {
                        if (nowPlayingTrack.image != null &&
                            nowPlayingTrack.title != null &&
                            nowPlayingTrack.artist != null &&
                            nowPlayingTrack.source != null) {
                          isPlaying = true;
                          songName = nowPlayingTrack.title!;
                          songArtist = nowPlayingTrack.artist!;
                          Future.delayed(
                            Duration.zero,
                            (() {
                              allAppProvider.isSongPlayingFunc(isPlaying);
                              allAppProvider.songNameFunc(songName);
                              allAppProvider.songArtistFunc(songArtist);
                            }),
                          );
                        } else {
                          Future.delayed(
                            Duration.zero,
                            (() {
                              setState(() {});
                            }),
                          );
                        }
                        return Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: (() {}),
                            child: GlassmorphicContainer(
                              width: double.infinity,
                              height: 41,
                              borderRadius: 40,
                              linearGradient:
                                  AppColors.customGlassIconButtonGradient,
                              border: 2,
                              blur: 4,
                              borderGradient:
                                  AppColors.customGlassIconButtonBorderGradient,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                ),
                                child: (nowPlayingTrack.image != null &&
                                        nowPlayingTrack.title != null &&
                                        nowPlayingTrack.artist != null &&
                                        nowPlayingTrack.source != null)
                                    ? HomeAppBarTitleRow(
                                        isPaused: nowPlayingTrack.isPaused,
                                        size: size,
                                        hasImage: nowPlayingTrack.hasImage,
                                        image: nowPlayingTrack.image!,
                                        title: nowPlayingTrack.title!,
                                        artist: nowPlayingTrack.artist!,
                                        source: nowPlayingTrack.source!,
                                      )
                                    : const Center(
                                        child: Text(
                                          "Loading...",
                                          style: AppColors.headingTextStyle,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      }
                      return CustomHomeScreenAppBarTitle(
                        date: date,
                      );
                    },
                  );
                },
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

class HomeAppBarTitleRow extends StatelessWidget {
  const HomeAppBarTitleRow({
    super.key,
    required this.size,
    required this.hasImage,
    required this.image,
    required this.artist,
    required this.title,
    required this.source,
    required this.isPaused,
  });

  final Size size;
  final bool hasImage;
  final image;
  final String title;
  final String artist;
  final String source;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasImage)
          HomeAppBarSongImage(
            image: image,
          ),
        HomeAppBarSongTittleAndArtist(
          size: size,
          title: title,
          artist: artist,
        ),
        if (!isPaused)
          HomeAppBarTitleSongLastAnimation(
            source: source,
          ),
        if (isPaused)
          Container(
            margin: const EdgeInsets.only(right: 5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            height: 33,
            width: 33,
            child: Lottie.network(
              "https://assets3.lottiefiles.com/packages/lf20_z0b82vos.json",
            ),
          ),
      ],
    );
  }
}

class HomeAppBarSongImage extends StatelessWidget {
  const HomeAppBarSongImage({
    super.key,
    required this.image,
  });

  final image;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: image,
          ),
          shape: BoxShape.circle,
        ),
        height: 33,
        width: 33,
      ),
    );
  }
}

class HomeAppBarSongTittleAndArtist extends StatelessWidget {
  const HomeAppBarSongTittleAndArtist({
    super.key,
    required this.size,
    required this.artist,
    required this.title,
  });

  final Size size;
  final String title;
  final String artist;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width / 2.5,
      height: 41,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 3,
            ),
            if (title.trim().split(" ").length < 2)
              Text(
                title,
                style: AppColors.headingTextStyle,
              ),
            if (title.trim().split(" ").length > 1)
              SizedBox(
                height: 41 / 2.2,
                child: Marquee(
                  fadingEdgeStartFraction: 0.3,
                  fadingEdgeEndFraction: 0.3,
                  velocity: 50,
                  blankSpace: 1,
                  text: title.padLeft(30),
                  style: AppColors.headingTextStyle,
                ),
              ),
            if (artist.trim().split(" ").length < 3)
              Text(
                artist,
                style: AppColors.subHeadingTextStyle,
              ),
            if (artist.trim().split(" ").length > 2)
              SizedBox(
                height: 41 / 2.2,
                child: Marquee(
                  fadingEdgeStartFraction: 0.3,
                  fadingEdgeEndFraction: 0.3,
                  blankSpace: 10,
                  velocity: 30,
                  text: artist.padLeft(10),
                  style: AppColors.subHeadingTextStyle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HomeAppBarTitleSongLastAnimation extends StatelessWidget {
  const HomeAppBarTitleSongLastAnimation({super.key, required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      height: (source == "com.spotify.music") ? 33 : 40,
      width: (source == "com.spotify.music") ? 33 : 40,
      child: (source == "com.spotify.music")
          ? Lottie.network(
              "https://assets6.lottiefiles.com/packages/lf20_7fdtc2jOL0.json",
            )
          : Lottie.network(
              "https://assets9.lottiefiles.com/packages/lf20_SxMfIUiQaT.json",
            ),
    );
  }
}
