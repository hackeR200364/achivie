import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:achivie/screens/notification_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:badges/badges.dart' as badges;
import 'package:circular_clip_route/circular_clip_route.dart';
import 'package:flutter/cupertino.dart';
// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_marquee/flutter_marquee.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:provider/provider.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:telephony/telephony.dart';

import '../Utils/custom_glass_icon.dart';
import '../Utils/snackbar_utils.dart';
import '../models/task_model.dart';
import '../providers/app_providers.dart';
import '../providers/song_playing_provider.dart';
import '../services/keys.dart';
import '../services/notification_services.dart';
import '../services/shared_preferences.dart';
import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';
import '../widgets/home_screen_widgets.dart';
import 'new_task_screen.dart';

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
  List<String> taskTypeList = [
    "Personal",
    "Business",
  ];
  List<String> taskStatusList = [
    "Pending",
    "Completed",
    "Inbox",
  ];
  String email = 'email', profileType = "", uid = "", token = "";
  // String inboxStatus = "INBOX",
  //     completedStatus = "Completed",
  //     pendingStatus = "Pending",
  //     deleteStatus = "Deleted";
  BannerAd? bannerAd;
  bool isBannerAdLoaded = false;
  int counter = 0;
  // final assetsAudioPlayer = AssetsAudioPlayer();
  late ScrollController _scrollController;
  bool pageLoading = false;
  String songName = "";
  String songArtist = "";
  bool isPlaying = false;
  final animationDuration = const Duration(milliseconds: 300);
  bool isShowingIsland = false, backed = false;
  final telephony = Telephony.instance;
  String message = "";
  int userPoints = 0,
      taskDone = 0,
      taskCount = 0,
      taskDelete = 0,
      taskPending = 0,
      taskBusiness = 0,
      taskPersonal = 0,
      notificationCount = 0,
      taskTypeIndexMain = 0,
      taskStatusIndexMain = 0;
  // RewardedAd? rewardedAd;
  bool activeConnection = false, isLoading = false;
  late bool expanded;
  final _newTaskBtnKey = GlobalKey();
  final _notificationBtnKey = GlobalKey();

  Animatable<double>? nextScreenOpacity;
  late AnimationController _opacityAnimationController;

  ValueNotifier<bool> expandedNotifier = ValueNotifier<bool>(false);

  List<Task> tasks = [];
  // List<String> taskType = [];

  // late AudioSession session;
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        // Change this color to your desired color
      ),
    );
    expanded = false;
    _scrollController = ScrollController();
    tabController = TabController(
      length: 3,
      vsync: this,
    );
    getUserDetails();
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-7050103229809241/3214418719",
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
    // RewardedAd.load(
    //   adUnitId: "ca-app-pub-7050103229809241/3148880623",
    //   request: const AdRequest(),
    //   rewardedAdLoadCallback: RewardedAdLoadCallback(
    //     onAdLoaded: ((onAdLoaded) {
    //       rewardedAd = onAdLoaded;
    //     }),
    //     onAdFailedToLoad: ((onAdFailedToLoad) {
    //       // print("Failed: ${onAdFailedToLoad.message}");
    //     }),
    //   ),
    // );

    // assetsAudioPlayer.open(
    //   Audio("assets/audios/song1.mp3"),
    //   autoStart: false,
    //   showNotification: false,
    //   volume: 50,
    // );
    // if (Platform.isAndroid) checkCallStatus();

    nextScreenOpacity = Tween<double>(begin: 0.0, end: 1.0);
    _opacityAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Set the desired duration
    );
    nextScreenOpacity = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 1.0,
      ),
    ]);

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    expandedNotifier.dispose();
    super.dispose();
  }

  void getUserDetails() async {
    email = await StorageServices.getUsrEmail();
    profileType = await StorageServices.getUsrSignInType();
    uid = await StorageServices.getUID();
    token = await StorageServices.getUsrToken();
    log(token);
    await updateTasks(0, 0);
    // session = await AudioSession.instance;
    //
    // session.configure(const AudioSessionConfiguration.speech());

    // await session.setCategory(Category.playAndRecord);

    // session.interruptionEventStream.listen((event) {
    //   // Handle interruption events here
    //   print('Audio session interruption: $event');
    // });

    await refresh();
    // Future.delayed(
    //   const Duration(
    //     milliseconds: 700,
    //   ),
    //   (() {
    //
    //   }),
    // );

    // print(profileType);
  }

  // void checkCallStatus() async {
  //   final callState = await telephony.callState;
  //
  //   if (callState == CallState.RINGING) {
  //     // Incoming call
  //   } else if (callState == CallState.OFFHOOK) {
  //     // Active call
  //   } else {
  //     // No call
  //   }
  // }

  Future<void> refresh() async {
    // setState(() {
    //   pageLoading = true;
    // });
    http.Response response = await http.get(
      Uri.parse("${Keys.apiUsersBaseUrl}/taskRecords/$uid"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      if (responseJson["success"]) {
        log(responseJson.toString());
        StorageServices.setUsrPoints(responseJson[Keys.data][Keys.usrPoints]);
        taskDone = responseJson[Keys.data][Keys.taskDone];
        taskDelete = responseJson[Keys.data][Keys.taskDelete];
        taskPending = responseJson[Keys.data][Keys.taskPending];
        taskBusiness = responseJson[Keys.data][Keys.taskBusiness];
        taskPersonal = responseJson[Keys.data][Keys.taskPersonal];
        taskCount = responseJson[Keys.data][Keys.taskCount];
        setState(() {});
      }
    }

    await AwesomeNotifications().listScheduledNotifications().then((value) {
      setState(() {
        notificationCount = value.length;
        // pageLoading = false;
      });
    });

    updateTasks(taskTypeIndexMain, taskStatusIndexMain);
  }

  Future checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('achivie.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          activeConnection = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        activeConnection = false;
      });
    }
  }
  // Future<void> initValues() async {
  //   http.Response response = await http.get(
  //     Uri.parse("${Keys.apiUsersBaseUrl}/taskRecords/$uid"),
  //     headers: {
  //       'content-Type': 'application/json',
  //       'authorization': 'Bearer $token',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> responseJson = jsonDecode(response.body);
  //
  //     if (responseJson["success"]) {
  //       StorageServices.setUsrPoints(responseJson[Keys.data][Keys.usrPoints]);
  //       taskDone = responseJson[Keys.data][Keys.taskDone];
  //       taskDelete = responseJson[Keys.data][Keys.taskDelete];
  //       taskPending = responseJson[Keys.data][Keys.taskPending];
  //       taskBusiness = responseJson[Keys.data][Keys.taskBusiness];
  //       taskPersonal = responseJson[Keys.data][Keys.taskPersonal];
  //       taskCount = responseJson[Keys.data][Keys.taskCount];
  //       log(responseJson[Keys.data][Keys.usrPoints].toString());
  //       setState(() {});
  //     }
  //   }
  // }

  // static const platform = MethodChannel('music_control');
  //
  // Future<void> playMusic(String url) async {
  //   try {
  //     await platform.invokeMethod('play', {"url": url});
  //   } on PlatformException catch (e) {
  //     print('Error playing music: ${e.message}');
  //   }
  // }
  //
  // Future<void> pauseMusic() async {
  //   try {
  //     await platform.invokeMethod('pause');
  //     // log("message");
  //   } on PlatformException catch (e) {
  //     print('Error pausing music: ${e.message}');
  //   }
  // }
  //
  // Future<void> nextTrack() async {
  //   try {
  //     await platform.invokeMethod('next');
  //   } on PlatformException catch (e) {
  //     print('Error playing next track: ${e.message}');
  //   }
  // }
  //
  // Future<void> previousTrack() async {
  //   try {
  //     await platform.invokeMethod('previous');
  //   } on PlatformException catch (e) {
  //     print('Error playing previous track: ${e.message}');
  //   }
  // }

  void expandableUpdate(bool update) {
    setState(() {
      expanded = update;
    });
  }

  Future<void> updateTasks(int taskTypeIndex, int taskStatusIndex) async {
    setState(() {
      isLoading = true;
    });
    if (tabController.index == 2) {
      http.Response response = await http.get(
        Uri.parse(
            "${Keys.apiTasksBaseUrl}/getAllTasksSpecificType/$uid/${taskTypeList[taskTypeIndex]}"),
        headers: {
          "content-Type": "application/json",
          "authorization": "Bearer $token",
        },
      );

      Map<String, dynamic> resJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (resJson["success"]) {
          Tasks allTasks = Tasks.fromJson(resJson);
          tasks.clear();
          tasks = allTasks.data;
          setState(() {});
        }
      }
    } else if (tabController.index == 0 || tabController.index == 1) {
      http.Response response = await http.get(
        Uri.parse(
            "${Keys.apiTasksBaseUrl}/getTasksOfTypeStatus/$uid/${taskTypeList[taskTypeIndex]}/${taskStatusList[taskStatusIndex]}"),
        headers: {
          'content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );

      Map<String, dynamic> resJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (resJson["success"]) {
          Tasks allTasks = Tasks.fromJson(resJson);
          tasks.clear();
          tasks = allTasks.data;
          setState(() {});
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: (() async {
        // await rewardedAd?.show(
        //   onUserEarnedReward: ((ad, point) {}),
        // );

        // rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        //   onAdClicked: ((ad) {}),
        //   onAdDismissedFullScreenContent: ((ad) {
        //     // print("ad dismissed");
        //     SystemNavigator.pop();
        //   }),
        //   onAdFailedToShowFullScreenContent: ((ad, err) {
        //     ad.dispose();
        //     // print("ad error $err");
        //   }),
        //   onAdImpression: ((ad) {}),
        //   onAdShowedFullScreenContent: ((ad) {
        //     // print("ad shown ${ad.responseInfo}");
        //   }),
        //   onAdWillDismissFullScreenContent: ((ad) {
        //     SystemNavigator.pop();
        //   }),
        // );

        return true;
      }),
      child: Scaffold(
        bottomNavigationBar: (isBannerAdLoaded)
            ? CustomHomeScreenBottomNavBarWithBannerAd(bannerAd: bannerAd)
            : null,
        floatingActionButton: GlassmorphicContainer(
          margin: const EdgeInsets.only(
            right: 10,
          ),
          width: 50,
          height: 50,
          borderRadius: 40,
          linearGradient: AppColors.customGlassIconButtonGradient,
          border: 2,
          blur: 4,
          borderGradient: AppColors.customGlassIconButtonBorderGradient,
          child: Center(
            child: IconButton(
              key: _newTaskBtnKey,
              onPressed: () {
                HapticFeedback.lightImpact();

                _opacityAnimationController.forward();
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
                    expandFrom: _newTaskBtnKey.currentContext!,
                    curve: Curves.ease,
                    reverseCurve: Curves.fastOutSlowIn.flipped,
                    opacity: nextScreenOpacity,
                    transitionDuration: const Duration(milliseconds: 600),
                    builder: ((_) => const NewTaskScreen()),
                  ), // CustomPageTransitionAnimation(
                ).then((value) {
                  refresh();
                  // setState(() {});
                });

                // Navigator.push(
                //   context,
                //   CircularClipRoute(
                //     expandFrom: _newTaskBtnKey.currentContext!,
                //     curve: Curves.fastOutSlowIn,
                //     reverseCurve: Curves.fastOutSlowIn.flipped,
                //     opacity: ConstantTween(1),
                //     transitionDuration: const Duration(milliseconds: 650),
                //     builder: ((_) => const NewTaskScreen()),
                //   ), // CustomPageTransitionAnimation(
                //   //   enterWidget: SearchScreen(),
                //   //   x: 0.5,
                //   //   y: -0.85,
                //   // ),
                // ).then((value) {
                //   refresh();
                //   // setState(() {});
                // });

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (nextPageContext) {
                //       return const NewTaskScreen();
                //     },
                //   ),
                // ).then((value) {
                //   refresh();
                //   // setState(() {});
                // });
              },
              icon: const Icon(
                Icons.add,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        backgroundColor: AppColors.mainColor,
        body: ValueListenableBuilder<bool>(
          valueListenable: expandedNotifier,
          builder: (expandCtx, expandVal, _) {
            return RefreshIndicator(
              displacement: 5,
              edgeOffset: expandVal ? 87 + 38 : 87,
              color: AppColors.backgroundColour,
              backgroundColor: AppColors.mainColor,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: refresh,
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          color: AppColors.backgroundColour,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: HomeScreenGraphContainer(
                          taskDone: taskDone,
                          taskDelete: taskDelete,
                          taskPersonal: taskPersonal,
                          taskPending: taskPending,
                          taskCount: taskCount,
                          taskBusiness: taskBusiness,
                        ),
                      ),
                      SliverAppBar(
                        expandedHeight: 40,
                        collapsedHeight: 40,
                        elevation: 0,
                        // pinned: true,
                        backgroundColor: AppColors.transparent,
                        flexibleSpace: Container(
                          height: 40,
                          margin: EdgeInsets.only(
                            top: 19,
                            bottom: 15,
                            left: 15,
                            right: 15,
                          ),
                          padding: EdgeInsets.only(
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColour,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CupertinoPicker(
                            backgroundColor: AppColors.transparent,
                            itemExtent: 23,
                            magnification: 1.1,
                            selectionOverlay:
                                CupertinoPickerDefaultSelectionOverlay(
                              background:
                                  AppColors.backgroundColour.withOpacity(0.4),
                            ),
                            onSelectedItemChanged: (value) {
                              HapticFeedback.heavyImpact();
                              taskTypeIndexMain = value;
                              updateTasks(
                                  taskTypeIndexMain, taskStatusIndexMain);

                              // allAppProvidersProvider
                              //     .selectedTypeFunc(taskType[value]);
                              // print(AllAppProvidersProvider.selectedType);
                              // print(taskType[value]);
                            },
                            children: taskTypeList
                                .map((e) => Text(
                                      e,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      SliverAppBar(
                        // pinned: true,
                        elevation: 0,
                        backgroundColor: AppColors.transparent,
                        flexibleSpace: Center(
                          child: TabBar(
                            onTap: ((index) {
                              HapticFeedback.heavyImpact();
                              taskStatusIndexMain = index;
                              updateTasks(
                                  taskTypeIndexMain, taskStatusIndexMain);
                            }),
                            enableFeedback: true,
                            splashBorderRadius: BorderRadius.circular(50),
                            splashFactory: NoSplash.splashFactory,
                            physics: AppColors.scrollPhysics,
                            isScrollable: true,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicator: BoxDecoration(
                              color: AppColors.backgroundColour,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            labelColor: AppColors.white,
                            labelStyle: const TextStyle(
                              // color: AppColors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelColor: AppColors.backgroundColour,
                            controller: tabController,
                            tabs: taskStatusList
                                .map(
                                  (e) => CustomTabBarItems(
                                    label: e.toUpperCase(),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      if (!isLoading && tasks.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: tasks.length,
                            (listContext, listIndex) {
                              // final individualTask = snapshotList[listIndex];

                              int taskSavedDay = int.parse(
                                  "${tasks[listIndex].taskDate[0]}${tasks[listIndex].taskDate[1]}");
                              int taskSavedMonth = int.parse(
                                  "${tasks[listIndex].taskDate[3]}${tasks[listIndex].taskDate[4]}");
                              int taskSavedYear = int.parse(
                                  "${tasks[listIndex].taskDate[6]}${tasks[listIndex].taskDate[7]}${tasks[listIndex].taskDate[8]}${tasks[listIndex].taskDate[9]}");
                              int taskSavedHour = int.parse(
                                  "${tasks[listIndex].taskTime[0]}${tasks[listIndex].taskTime[1]}");
                              int taskSavedMinute = int.parse(
                                  "${tasks[listIndex].taskTime[3]}${tasks[listIndex].taskTime[4]}");

                              DateTime taskSavedDate = DateTime(
                                taskSavedYear,
                                taskSavedMonth,
                                taskSavedDay,
                                taskSavedHour,
                                taskSavedMinute,
                              );

                              // String taskDocID = snapshotList[listIndex].reference.id;

                              return Container(
                                margin: EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                ),
                                child: CustomFocusedMenuTile(
                                  name: tasks[listIndex].taskName,
                                  des: tasks[listIndex].taskDes,
                                  status: tasks[listIndex].taskStatus,
                                  time: tasks[listIndex].taskTime,
                                  date: tasks[listIndex].taskDate,
                                  type: tasks[listIndex].taskType,
                                  taskDocID: "taskDocID",
                                  tileOnPressed: (() {
                                    HapticFeedback.heavyImpact();
                                  }),
                                  tileFirstOnPressed: (() async {
                                    if ((tasks[listIndex].taskStatus !=
                                            "Pending") &&
                                        (taskSavedDate
                                                .difference(date)
                                                .inMinutes >
                                            0)) {
                                      http.Response unDoneResponse =
                                          await http.post(
                                        Uri.parse(
                                            "${Keys.apiTasksBaseUrl}/unDoneTask"),
                                        headers: {
                                          "content-Type": "application/json",
                                          "authorization": "Bearer $token",
                                        },
                                        body: jsonEncode(
                                          {
                                            Keys.uid: uid,
                                            Keys.notificationID:
                                                tasks[listIndex].notificationId,
                                          },
                                        ),
                                      );

                                      Map<String, dynamic> unDoneResponseJson =
                                          jsonDecode(unDoneResponse.body);

                                      if (unDoneResponse.statusCode == 200) {
                                        if (unDoneResponseJson["success"]) {
                                          DateTime date = DateTime.now();

                                          if (taskSavedDate
                                                  .difference(date)
                                                  .inMinutes >
                                              0) {
                                            log("unDoneResponseJson=${unDoneResponseJson[Keys.data].toString()}");
                                            NotificationServices()
                                                .cancelTaskScheduledNotification(
                                              id: tasks[listIndex]
                                                  .notificationId,
                                            );
                                            NotificationServices()
                                                .createScheduledTaskNotification(
                                                  title:
                                                      tasks[listIndex].taskName,
                                                  body:
                                                      "${tasks[listIndex].taskName}\n${tasks[listIndex].taskDes}",
                                                  id: tasks[listIndex]
                                                      .notificationId,
                                                  payload: "",
                                                  dateTime: taskSavedDate,
                                                )
                                                .then((value) {});
                                          }

                                          NotificationServices()
                                              .createScheduledTaskNotification(
                                            title: tasks[listIndex].taskName,
                                            body:
                                                "${tasks[listIndex].taskName}\n${tasks[listIndex].taskDes}",
                                            id: tasks[listIndex].notificationId,
                                            payload: tasks[listIndex].taskName,
                                            dateTime: taskSavedDate,
                                          )
                                              .then((value) {
                                            showDialog(
                                              context: listContext,
                                              builder:
                                                  (BuildContext unDoneContext) {
                                                Future.delayed(
                                                  const Duration(
                                                    seconds: 2,
                                                  ),
                                                  (() {
                                                    Navigator.pop(
                                                        unDoneContext);
                                                  }),
                                                );
                                                return const TaskUnDoneDialogChild();
                                              },
                                            ).then((value) async {
                                              // await widget.refresh;
                                              refresh();
                                            });
                                          });
                                        } else {
                                          AppSnackbar().customizedAppSnackbar(
                                            message:
                                                unDoneResponseJson["message"],
                                            context: listContext,
                                          );
                                        }
                                      } else {
                                        AppSnackbar().customizedAppSnackbar(
                                          message: unDoneResponse.statusCode
                                              .toString(),
                                          context: listContext,
                                        );
                                      }

                                      // updateTasks(
                                      //   taskDocID: "taskDocID",
                                      //   status: snapshotList[listIndex][Keys.taskStatus],
                                      //   firestoreEmail: widget.firestoreEmail,
                                      //   taskSavedDay: taskSavedDay,
                                      //   taskSavedHour: taskSavedHour,
                                      //   taskSavedMinute: taskSavedMinute,
                                      //   taskSavedMonth: taskSavedMonth,
                                      //   taskSavedYear: taskSavedYear,
                                      // );

                                      // Navigator.push(
                                      //   streamContext,
                                      //   MaterialPageRoute(
                                      //     builder: (nextPageContext) => TempScreen(),
                                      //   ),
                                      // );
                                    } else if (tasks[listIndex].taskStatus ==
                                        "Pending") {
                                      http.Response doneResponse =
                                          await http.post(
                                        Uri.parse(
                                            "${Keys.apiTasksBaseUrl}/doneTask"),
                                        headers: {
                                          "content-Type": "application/json",
                                          "authorization": "Bearer $token",
                                        },
                                        body: jsonEncode(
                                          {
                                            Keys.uid: uid,
                                            Keys.notificationID:
                                                tasks[listIndex].notificationId,
                                          },
                                        ),
                                      );

                                      if (doneResponse.statusCode == 200) {
                                        Map<String, dynamic> doneResponseJson =
                                            jsonDecode(doneResponse.body);
                                        if (doneResponseJson["success"]) {
                                          DateTime date = DateTime.now();

                                          if (taskSavedDate
                                                  .difference(date)
                                                  .inMinutes >
                                              0) {
                                            NotificationServices()
                                                .cancelTaskScheduledNotification(
                                              id: tasks[listIndex]
                                                  .notificationId,
                                            )
                                                .then((value) {
                                              showDialog(
                                                context: listContext,
                                                builder:
                                                    (BuildContext doneContext) {
                                                  Future.delayed(
                                                    const Duration(
                                                      seconds: 2,
                                                    ),
                                                    (() {
                                                      Navigator.pop(
                                                          doneContext);
                                                      // widget.refresh;
                                                    }),
                                                  );
                                                  return TaskDialog(
                                                    animation:
                                                        "assets/success-done-animation.json",
                                                    headMessage:
                                                        "Congratulations",
                                                    subMessage:
                                                        "You completed your task",
                                                    subMessageBottomDivision: 5,
                                                  );
                                                },
                                              ).then((value) async {
                                                // await widget.refresh;
                                                refresh();
                                              });
                                            });
                                          }
                                        } else {
                                          AppSnackbar().customizedAppSnackbar(
                                            message:
                                                doneResponseJson["message"],
                                            context: listContext,
                                          );
                                        }
                                      } else {
                                        AppSnackbar().customizedAppSnackbar(
                                          message: doneResponse.statusCode
                                              .toString(),
                                          context: listContext,
                                        );
                                      }

                                      // updateTasks(
                                      //   taskDocID: "taskDocID",
                                      //   status: snapshotList[listIndex][Keys.taskStatus],
                                      //   firestoreEmail: widget.firestoreEmail,
                                      //   taskSavedDay: taskSavedDay,
                                      //   taskSavedHour: taskSavedHour,
                                      //   taskSavedMinute: taskSavedMinute,
                                      //   taskSavedMonth: taskSavedMonth,
                                      //   taskSavedYear: taskSavedYear,
                                      // );

                                      // Navigator.push(
                                      //   streamContext,
                                      //   MaterialPageRoute(
                                      //     builder: (nextPageContext) => TempScreen(),
                                      //   ),
                                      // );
                                    } else {
                                      ScaffoldMessenger.of(listContext)
                                          .showSnackBar(
                                        AppTaskSnackBar()
                                            .customizedSnackbarForTasks(
                                          listIndex: listIndex,
                                          firestoreEmail: email,
                                          streamContext: listContext,
                                          onPressed: (() {
                                            // String taskDocID =
                                            //     snapshotList[listIndex].reference.id;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (nextPageContext) =>
                                                    NewTaskScreen(
                                                  taskName:
                                                      tasks[listIndex].taskName,
                                                  taskDes:
                                                      tasks[listIndex].taskDes,
                                                  taskNoti: tasks[listIndex]
                                                      .taskNotification,
                                                  taskTime:
                                                      tasks[listIndex].taskTime,
                                                  taskType:
                                                      tasks[listIndex].taskType,
                                                  // taskDoc: "taskDocID",
                                                  userEmail: email,
                                                  taskDate:
                                                      tasks[listIndex].taskDate,
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      );
                                    }
                                  }),
                                  tileSecondOnPressed: (() {
                                    // String taskDocID = snapshotList[listIndex].reference.id;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (nextPageContext) =>
                                            NewTaskScreen(
                                          taskName: tasks[listIndex].taskName,
                                          taskDes: tasks[listIndex].taskDes,
                                          taskNoti:
                                              tasks[listIndex].taskNotification,
                                          taskTime: tasks[listIndex].taskTime,
                                          taskType: tasks[listIndex].taskType,
                                          // taskDoc: "taskDocID",
                                          notificationID:
                                              tasks[listIndex].notificationId,
                                          userEmail: email,
                                          taskDate: tasks[listIndex].taskDate,
                                        ),
                                      ),
                                    );
                                  }),
                                  tileThirdOnPressed: (() async {
                                    // String taskDocID = snapshotList[listIndex].reference.id;
                                    // log(snapshotList[listIndex][Keys.taskStatus]);

                                    // if (snapshotList[listIndex][Keys.taskStatus] !=
                                    //     Keys.deleteStatus) {
                                    //   // deleteTasks(
                                    //   //   taskSavedDay: taskSavedDay,
                                    //   //   taskSavedYear: taskSavedYear,
                                    //   //   taskSavedMonth: taskSavedMonth,
                                    //   //   taskSavedMinute: taskSavedMinute,
                                    //   //   taskSavedHour: taskSavedHour,
                                    //   //   taskDocID: taskDocID,
                                    //   //   status: snapshotList[listIndex][Keys.taskStatus],
                                    //   //   firestoreEmail: widget.firestoreEmail,
                                    //   // );
                                    //
                                    //   http.Response deleteTaskResponse = await http.post(
                                    //     Uri.parse("${Keys.apiTasksBaseUrl}/deleteTask"),
                                    //     headers: {
                                    //       "content-Type": "application/json",
                                    //       "authorization": "Bearer ${widget.token}",
                                    //     },
                                    //     body: jsonEncode(
                                    //       {
                                    //         Keys.uid: widget.uid,
                                    //         Keys.notificationID: snapshotList[listIndex]
                                    //             [Keys.notificationID],
                                    //       },
                                    //     ),
                                    //   );
                                    //
                                    //   Map<String, dynamic> deleteTaskResponseJson =
                                    //       jsonDecode(deleteTaskResponse.body);
                                    //
                                    //   if (deleteTaskResponse.statusCode == 200) {
                                    //     if (deleteTaskResponseJson["success"]) {
                                    //       NotificationServices()
                                    //           .cancelTaskScheduledNotification(
                                    //         id: snapshotList[listIndex]
                                    //             [Keys.notificationID],
                                    //       );
                                    //
                                    //       showDialog(
                                    //         context: streamContext,
                                    //         builder: (BuildContext deleteContext) {
                                    //           Future.delayed(
                                    //             const Duration(
                                    //               seconds: 2,
                                    //             ),
                                    //             (() {
                                    //               Navigator.pop(deleteContext);
                                    //             }),
                                    //           );
                                    //           return TaskDialog(
                                    //             animation: "assets/deleted-animation.json",
                                    //             headMessage: "Deleted!",
                                    //             subMessage: "Your this task is deleted",
                                    //             subMessageBottomDivision: 5,
                                    //           );
                                    //         },
                                    //       );
                                    //     } else {
                                    //       AppSnackbar().customizedAppSnackbar(
                                    //         message: deleteTaskResponseJson["message"],
                                    //         context: streamContext,
                                    //       );
                                    //     }
                                    //   } else {
                                    //     AppSnackbar().customizedAppSnackbar(
                                    //       message: deleteTaskResponse.statusCode.toString(),
                                    //       context: streamContext,
                                    //     );
                                    //   }
                                    // }

                                    if (tasks[listIndex].taskStatus ==
                                        Keys.deleteStatus) {
                                      if (taskSavedDate
                                              .difference(date)
                                              .inMinutes >
                                          0) {
                                        http.Response undoResponse =
                                            await http.post(
                                          Uri.parse(
                                              "${Keys.apiTasksBaseUrl}/undoTask"),
                                          headers: {
                                            "content-Type": "application/json",
                                            "authorization": "Bearer $token",
                                          },
                                          body: jsonEncode(
                                            {
                                              Keys.uid: uid,
                                              Keys.notificationID:
                                                  tasks[listIndex]
                                                      .notificationId,
                                            },
                                          ),
                                        );

                                        if (undoResponse.statusCode == 200) {
                                          Map<String, dynamic>
                                              undoResponseJson =
                                              jsonDecode(undoResponse.body);
                                          // log(undoResponseJson.toString());
                                          if (undoResponseJson["success"]) {
                                            // log(snapshotList[listIndex]
                                            //         [Keys.notificationID]
                                            //     .toString());
                                            await NotificationServices()
                                                .createScheduledTaskNotification(
                                              id: tasks[listIndex]
                                                  .notificationId,
                                              title: tasks[listIndex].taskName,
                                              body: tasks[listIndex].taskDes,
                                              payload: tasks[listIndex].taskDes,
                                              dateTime: taskSavedDate,
                                            )
                                                .then((value) {
                                              return showDialog(
                                                context: listContext,
                                                builder:
                                                    (BuildContext undoContext) {
                                                  Future.delayed(
                                                    const Duration(
                                                      seconds: 2,
                                                    ),
                                                    (() {
                                                      Navigator.pop(
                                                          undoContext);
                                                      // widget.refresh;
                                                    }),
                                                  );
                                                  return TaskDialog(
                                                    animation:
                                                        "assets/success-done-animation.json",
                                                    headMessage: "Woohooo...!",
                                                    subMessage:
                                                        "Your this message is brought back as pending",
                                                    subMessageBottomDivision: 6,
                                                  );
                                                },
                                              );
                                            });
                                          } else {
                                            AppSnackbar().customizedAppSnackbar(
                                              message:
                                                  undoResponseJson["message"],
                                              context: listContext,
                                            );
                                          }
                                        } else {
                                          AppSnackbar().customizedAppSnackbar(
                                            message: undoResponse.statusCode
                                                .toString(),
                                            context: listContext,
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(listContext)
                                            .showSnackBar(
                                          AppTaskSnackBar()
                                              .customizedSnackbarForTasks(
                                            listIndex: listIndex,
                                            firestoreEmail: email,
                                            streamContext: listContext,
                                            onPressed: (() {
                                              // String taskDocID =
                                              //     snapshotList[listIndex].reference.id;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (nextPageContext) =>
                                                      NewTaskScreen(
                                                    taskName: tasks[listIndex]
                                                        .taskName,
                                                    taskDes: tasks[listIndex]
                                                        .taskDes,
                                                    taskNoti: tasks[listIndex]
                                                        .taskNotification,
                                                    taskTime: tasks[listIndex]
                                                        .taskTime,
                                                    taskType: tasks[listIndex]
                                                        .taskType,
                                                    // taskDoc: taskDocID,
                                                    userEmail: email,
                                                    taskDate: tasks[listIndex]
                                                        .taskDate,
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        );
                                      }
                                    } else {
                                      // deleteTasks(
                                      //   taskSavedDay: taskSavedDay,
                                      //   taskSavedYear: taskSavedYear,
                                      //   taskSavedMonth: taskSavedMonth,
                                      //   taskSavedMinute: taskSavedMinute,
                                      //   taskSavedHour: taskSavedHour,
                                      //   taskDocID: taskDocID,
                                      //   status: snapshotList[listIndex][Keys.taskStatus],
                                      //   firestoreEmail: widget.firestoreEmail,
                                      // );

                                      // log(snapshotList[listIndex]
                                      //         [Keys.notificationID]
                                      //     .toString());

                                      http.Response deleteTaskResponse =
                                          await http.post(
                                        Uri.parse(
                                            "${Keys.apiTasksBaseUrl}/deleteTask"),
                                        headers: {
                                          "content-Type": "application/json",
                                          "authorization": "Bearer $token",
                                        },
                                        body: jsonEncode(
                                          {
                                            Keys.uid: uid,
                                            Keys.notificationID:
                                                tasks[listIndex].notificationId,
                                          },
                                        ),
                                      );

                                      if (deleteTaskResponse.statusCode ==
                                          200) {
                                        Map<String, dynamic>
                                            deleteTaskResponseJson =
                                            jsonDecode(deleteTaskResponse.body);
                                        log(deleteTaskResponseJson.toString());
                                        if (deleteTaskResponseJson["success"]) {
                                          NotificationServices()
                                              .cancelTaskScheduledNotification(
                                            id: tasks[listIndex].notificationId,
                                          )
                                              .then((value) {
                                            return showDialog(
                                              context: listContext,
                                              builder:
                                                  (BuildContext deleteContext) {
                                                Future.delayed(
                                                  const Duration(
                                                    seconds: 2,
                                                  ),
                                                  (() {
                                                    Navigator.pop(
                                                        deleteContext);
                                                  }),
                                                );
                                                return TaskDialog(
                                                  animation:
                                                      "assets/deleted-animation.json",
                                                  headMessage: "Deleted!",
                                                  subMessage:
                                                      "Your this task is deleted",
                                                  subMessageBottomDivision: 5,
                                                );
                                              },
                                            ).then((value) {
                                              // widget.refresh;
                                            });
                                          });
                                        } else {
                                          AppSnackbar().customizedAppSnackbar(
                                            message: deleteTaskResponseJson[
                                                "message"],
                                            context: listContext,
                                          );
                                        }
                                      } else {
                                        AppSnackbar().customizedAppSnackbar(
                                          message: deleteTaskResponse.statusCode
                                              .toString(),
                                          context: listContext,
                                        );
                                      }
                                    }
                                  }),
                                ),
                              );
                            },
                          ),
                        ),
                      if (isLoading)
                        const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.backgroundColour,
                            ),
                          ),
                        ),
                      if (tasks.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Lottie.asset("assets/empty_animation.json"),
                          ),
                        ),
                    ],
                  ),
                  // SingleChildScrollView(
                  //   physics: const AlwaysScrollableScrollPhysics(),
                  //   child: CustomHomeScreenContainerWithConnectivityWidget(
                  //     taskType: taskType,
                  //     tabController: tabController,
                  //     pendingStatus: pendingStatus,
                  //     email: email,
                  //     widget: widget,
                  //     scrollController: _scrollController,
                  //     date: date,
                  //     completedStatus: completedStatus,
                  //     inboxStatus: inboxStatus,
                  //     userPoints: userPoints,
                  //     taskDone: taskDone,
                  //     taskCount: taskCount,
                  //     taskDelete: taskDelete,
                  //     taskPending: taskPending,
                  //     taskBusiness: taskBusiness,
                  //     taskPersonal: taskPersonal,
                  //     token: token,
                  //     uid: uid,
                  //     // refresh: refresh(),
                  //   ),
                  // ),

                  Stack(
                    children: [
                      Positioned(
                        top: 45,
                        right: expandVal ? -51 : 15,
                        child: badges.Badge(
                          position: badges.BadgePosition.topEnd(
                            end: -6,
                          ),
                          showBadge: (notificationCount != 0) ? true : false,
                          badgeContent: Center(
                            child: Text(
                              notificationCount.toString(),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          badgeAnimation: const badges.BadgeAnimation.slide(),
                          child: CustomGlassIconButton(
                            key: _notificationBtnKey,
                            onPressed: (() {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (notificationContext) =>
                              //         const NotificationScreen(),
                              //   ),
                              // );

                              // session.setActive(false);

                              _opacityAnimationController.forward();
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
                                  expandFrom:
                                      _notificationBtnKey.currentContext!,
                                  curve: Curves.ease,
                                  reverseCurve: Curves.fastOutSlowIn.flipped,
                                  opacity: nextScreenOpacity,
                                  transitionDuration:
                                      const Duration(milliseconds: 600),
                                  builder: ((_) => const NotificationScreen()),
                                ), // CustomPageTransitionAnimation(
                              ).then((value) {
                                refresh();
                                // setState(() {});
                              });
                            }),
                            icon: Icons.notifications,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 45,
                        left: expandVal ? -51 : 15,
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
                        left: expandVal ? 15 : 61,
                        right: expandVal ? 15 : 61,
                        // width: size.width,
                        child: Consumer<AllAppProviders>(
                          builder: (allAppContext, allAppProviderParent,
                              allAppChild) {
                            // log(expanded.toString());
                            return Consumer<SongPlayingProvider>(
                              builder: (songPlayingContext, songPlayingProvider,
                                  songPlayingChild) {
                                // log(expanded.toString());
                                return Consumer<NowPlayingTrack>(
                                  builder:
                                      (nowPlayingContext, nowPlayingTrack, _) {
                                    if (nowPlayingTrack.isPaused) {
                                      isPlaying = true;
                                      songName = nowPlayingTrack.title!;
                                      songArtist = nowPlayingTrack.artist!;
                                      Future.delayed(
                                        Duration.zero,
                                        (() {
                                          songPlayingProvider
                                              .isSongPlayingFunc(isPlaying);
                                          songPlayingProvider
                                              .songNameFunc(songName);
                                          songPlayingProvider
                                              .songArtistFunc(songArtist);
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
                                            linearGradient: AppColors
                                                .customGlassIconButtonGradient,
                                            border: 2,
                                            blur: 4,
                                            borderGradient: AppColors
                                                .customGlassIconButtonBorderGradient,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 5,
                                              ),
                                              child:
                                                  (nowPlayingTrack.image !=
                                                              null &&
                                                          nowPlayingTrack
                                                                  .title !=
                                                              null &&
                                                          nowPlayingTrack
                                                                  .artist !=
                                                              null &&
                                                          nowPlayingTrack
                                                                  .source !=
                                                              null)
                                                      ? HomeAppBarTitleRow(
                                                          isPaused:
                                                              nowPlayingTrack
                                                                  .isPaused,
                                                          size: size,
                                                          hasImage:
                                                              nowPlayingTrack
                                                                  .hasImage,
                                                          image: nowPlayingTrack
                                                              .image!,
                                                          title: nowPlayingTrack
                                                              .title!,
                                                          artist:
                                                              nowPlayingTrack
                                                                  .artist!,
                                                          source:
                                                              nowPlayingTrack
                                                                  .source!,
                                                        )
                                                      : const Center(
                                                          child: Text(
                                                            "Loading...",
                                                            style: AppColors
                                                                .headingTextStyle,
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
                                          songPlayingProvider
                                              .isSongPlayingFunc(isPlaying);
                                        }),
                                      );
                                      return CustomHomeScreenAppBarTitle(
                                        date: date,
                                        expandable: ((val) {}),
                                        expandedNotifier: expandedNotifier,
                                      );
                                    }

                                    if (nowPlayingTrack.isPlaying) {
                                      if (nowPlayingTrack.image != null &&
                                          nowPlayingTrack.title != null &&
                                          nowPlayingTrack.artist != null &&
                                          nowPlayingTrack.source != null) {
                                        // log(nowPlayingTrack.duration
                                        //     .toString());
                                        isPlaying = true;
                                        songName = nowPlayingTrack.title!;
                                        songArtist = nowPlayingTrack.artist!;
                                        Future.delayed(
                                          Duration.zero,
                                          (() {
                                            songPlayingProvider
                                                .isSongPlayingFunc(isPlaying);
                                            songPlayingProvider
                                                .songNameFunc(songName);
                                            songPlayingProvider
                                                .songArtistFunc(songArtist);
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
                                      return PlayingAppBarTitleWidget(
                                        size: size,
                                        nowPlayingTrack: nowPlayingTrack,
                                        expandedNotifier: expandedNotifier,
                                      );
                                    }
                                    return CustomHomeScreenAppBarTitle(
                                      date: date,
                                      expandable: ((expandStatus) {}),
                                      expandedNotifier: expandedNotifier,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  )

                  // ListView(),
                  // if (pageLoading)
                  //   Positioned(
                  //     child: Container(
                  //       width: MediaQuery.of(context).size.width,
                  //       height: MediaQuery.of(context).size.height,
                  //       decoration: const BoxDecoration(
                  //         color: AppColors.mainColor,
                  //       ),
                  //       child: const Center(
                  //         child: CircularProgressIndicator(
                  //           strokeWidth: 2,
                  //           color: AppColors.white,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class PlayingAppBarTitleWidget extends StatefulWidget {
  const PlayingAppBarTitleWidget({
    super.key,
    required this.size,
    required this.nowPlayingTrack,
    required this.expandedNotifier,
  });

  final Size size;
  final NowPlayingTrack nowPlayingTrack;
  final ValueNotifier<bool> expandedNotifier;

  @override
  State<PlayingAppBarTitleWidget> createState() =>
      _PlayingAppBarTitleWidgetState();
}

class _PlayingAppBarTitleWidgetState extends State<PlayingAppBarTitleWidget> {
  bool expanded = false;

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    String formattedDuration = (hours > 0)
        ? "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}"
        : "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    return formattedDuration;
  }

  final MethodChannel controlMusicStateChannel =
      MethodChannel('control_music_state');

  @override
  Widget build(BuildContext context) {
    // log(widget.nowPlayingTrack.duration.toString());
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < 0) {
            setState(() {
              expanded = false;
            });
            widget.expandedNotifier.value = expanded;
          }
          if (details.delta.dy > 0) {
            setState(() {
              expanded = true;
            });
            widget.expandedNotifier.value = expanded;
          }
        },
        onLongPress: (() {
          HapticFeedback.lightImpact();
          // _animationController.forward();
          setState(() {
            expanded = true;
          });
          widget.expandedNotifier.value = expanded;
        }),
        child: AnimatedContainer(
          width: MediaQuery.of(context).size.width,
          height: expanded ? 140 : 41,
          curve: !expanded ? Curves.elasticOut : Curves.elasticOut,
          decoration: BoxDecoration(
            gradient: AppColors.customGlassIconButtonGradient,
            borderRadius: BorderRadius.circular(expanded ? 31 : 40),
            border: Border.all(
              width: expanded ? 1 : 2,
              color: AppColors.white.withOpacity(0.4),
            ),
          ),
          duration: Duration(milliseconds: expanded ? 700 : 900),
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              AnimatedContainer(
                                height: 65,
                                width: 65,
                                duration: Duration(
                                  milliseconds: 400,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: widget.nowPlayingTrack.image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // if (title.trim().split(" ").length < 2)
                                  // Text(
                                  //   title,
                                  //   style: AppColors.headingTextStyle,
                                  // ),
                                  // if (title.trim().split(" ").length > 1)
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2.3,
                                    height: 20,
                                    child: Marquee(
                                      textStyle: AppColors.headingTextStyle,
                                      str: widget.nowPlayingTrack.title!,
                                      containerWidth:
                                          MediaQuery.of(context).size.width,
                                      baseMilliseconds: 6000,
                                    ),
                                  ),
                                  // if (artist.trim().split(" ").length < 3)
                                  //   Text(
                                  //     artist,
                                  //     style: AppColors.subHeadingTextStyle,
                                  //   ),
                                  // if (artist.trim().split(" ").length > 2)
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2.3,
                                    height: 15,
                                    child: Marquee(
                                      textStyle: AppColors.subHeadingTextStyle,
                                      str: widget.nowPlayingTrack.artist!,
                                      containerWidth:
                                          MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            margin: const EdgeInsets.only(right: 5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            height: (widget.nowPlayingTrack.source! ==
                                    "com.spotify.music")
                                ? 35
                                : 40,
                            width: (widget.nowPlayingTrack.source! ==
                                    "com.spotify.music")
                                ? 35
                                : 40,
                            child: (widget.nowPlayingTrack.source! ==
                                    "com.spotify.music")
                                ? Lottie.network(
                                    "https://assets6.lottiefiles.com/packages/lf20_7fdtc2jOL0.json",
                                  )
                                : Lottie.network(
                                    "https://assets9.lottiefiles.com/packages/lf20_SxMfIUiQaT.json",
                                  ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDuration(widget.nowPlayingTrack.progress),
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          SimpleAnimationProgressBar(
                            height: 5,
                            width: MediaQuery.of(context).size.width - 150,
                            backgroundColor:
                                AppColors.mainColor.withOpacity(0.5),
                            foregrondColor: AppColors.white,
                            ratio: widget.nowPlayingTrack.progress.inSeconds
                                    .toDouble() /
                                widget.nowPlayingTrack.duration.inSeconds
                                    .toDouble(),
                            direction: Axis.horizontal,
                            curve: Curves.fastLinearToSlowEaseIn,
                            duration: const Duration(seconds: 1),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.backgroundColour,
                                offset: const Offset(
                                  5.0,
                                  5.0,
                                ),
                                blurRadius: 10.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Text(
                            formatDuration(widget.nowPlayingTrack.duration),
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(
                    left: 3,
                  ),
                  child: (widget.nowPlayingTrack.image != null &&
                          widget.nowPlayingTrack.title != null &&
                          widget.nowPlayingTrack.artist != null &&
                          widget.nowPlayingTrack.source != null)
                      ? HomeAppBarTitleRow(
                          isPaused: widget.nowPlayingTrack.isPaused,
                          size: widget.size,
                          hasImage: widget.nowPlayingTrack.hasImage,
                          image: widget.nowPlayingTrack.image!,
                          title: widget.nowPlayingTrack.title!,
                          artist: widget.nowPlayingTrack.artist!,
                          source: widget.nowPlayingTrack.source!,
                        )
                      : Container(),
                ),
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
  final ImageProvider<Object> image;
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

  final ImageProvider<Object> image;

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // if (title.trim().split(" ").length < 2)
        // Text(
        //   title,
        //   style: AppColors.headingTextStyle,
        // ),
        // if (title.trim().split(" ").length > 1)
        Marquee(
          textStyle: AppColors.headingTextStyle,
          str: title,
          containerWidth: MediaQuery.of(context).size.width / 2,
        ),
        // if (artist.trim().split(" ").length < 3)
        //   Text(
        //     artist,
        //     style: AppColors.subHeadingTextStyle,
        //   ),
        // if (artist.trim().split(" ").length > 2)
        Marquee(
          textStyle: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 12,
          ),
          str: artist,
          containerWidth: MediaQuery.of(context).size.width / 2,
        ),
      ],
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
      // height: (source == "com.spotify.music") ? 33 : 40,
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
