import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../Utils/custom_text_field_utils.dart';
import '../Utils/snackbar_utils.dart';
import '../providers/app_providers.dart';
import '../services/keys.dart';
import '../services/notification_services.dart';
import '../services/shared_preferences.dart';
import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({
    super.key,
    this.taskType,
    this.taskTime,
    this.taskDate,
    this.taskDes,
    this.taskName,
    this.taskNoti,
    // this.taskDoc,
    this.userEmail,
    this.notificationID,
  });

  final String? taskType;
  final String? taskName;
  final String? taskDes;
  final String? taskTime;
  final String? taskDate;
  final String? taskNoti;
  // final String? taskDoc;
  final String? userEmail;
  final int? notificationID;
  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen>
    with TickerProviderStateMixin {
  late TextEditingController _taskNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _notificationController;
  DateTime date = DateTime.now();
  DateTime scheduleDateTIme = DateTime.now();
  String taskTime = "", taskDate = "", taskID = "taskID", inputDateTime = "";
  bool taskNameTapped = false, desTapped = false, loading = false;
  String selected = "Personal";
  List<String> taskType = ["Personal", "Business"];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool updateTask = false, backPressed = false;
  int taskCount = 0,
      taskPending = 0,
      taskBusiness = 0,
      taskPersonal = 0,
      taskDone = 0;
  NotificationServices notificationServices = NotificationServices();
  BannerAd? bannerAd;
  // RewardedAd? rewardedAd, rewardedAd2;
  FocusNode? nameFocusNode;
  FocusNode? desFocusNode;
  FocusNode? notiFocusNode;
  // CollectionReference users = FirebaseFirestore.instance.collection("users");
  String token = "", uid = "";

  // late AnimationController controllerToIncreaseCurve;
  // late AnimationController controllerToDecreaseCurve;
  // late Animation<double> animationToIncreasingCurve;
  // late Animation<double> animationToDecreasingCurve;

  @override
  void initState() {
    _taskNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _notificationController = TextEditingController();
    nameFocusNode = FocusNode();
    desFocusNode = FocusNode();
    notiFocusNode = FocusNode();
    taskDetails();

    if (widget.taskName != null &&
        widget.taskDes != null &&
        widget.taskNoti != null &&
        widget.taskTime != null &&
        widget.taskDate != null) {
      // SystemChrome.setSystemUIOverlayStyle(
      //   const SystemUiOverlayStyle(
      //     statusBarColor:
      //         AppColors.mainColor, // Change this color to your desired color
      //   ),
      // );
    }

    // controllerToIncreaseCurve = AnimationController(
    //   vsync: this,
    //   duration: Duration(
    //     seconds: 2,
    //   ),
    // );
    //
    // controllerToDecreaseCurve = AnimationController(
    //   vsync: this,
    //   duration: Duration(
    //     seconds: 1,
    //   ),
    // );
    //
    // animationToIncreasingCurve = Tween<double>(begin: 500, end: 0).animate(
    //   CurvedAnimation(
    //     parent: controllerToIncreaseCurve,
    //     curve: Curves.fastLinearToSlowEaseIn,
    //   ),
    // )..addListener(
    //     () {
    //       setState(() {});
    //     },
    //   );
    // animationToDecreasingCurve = Tween<double>(begin: 0, end: 1000).animate(
    //   CurvedAnimation(
    //     parent: controllerToDecreaseCurve,
    //     curve: Curves.fastLinearToSlowEaseIn,
    //   ),
    // )..addListener(
    //     () {
    //       setState(() {});
    //     },
    //   );
    //
    // controllerToIncreaseCurve.forward();

    // UnityAds.load(
    //   placementId: "Banner_Android",
    //   onComplete: ((placementID) =>
    //       print('Initialization Complete $placementID')),
    //   onFailed: (placementID, error, message) =>
    //       print('Initialization Failed: $placementID $error $message'),
    // );

    bannerAd = BannerAd(
      size: (widget.taskName != null &&
              widget.taskDes != null &&
              widget.taskNoti != null &&
              widget.taskTime != null &&
              widget.taskDate != null)
          ? AdSize.largeBanner
          : AdSize.banner,
      adUnitId: "ca-app-pub-7050103229809241/9110329950",
      listener: BannerAdListener(
        onAdLoaded: ((ad) {
          // print("Banner ad loaded ${ad.adUnitId}");
        }),
      ),
      request: const AdRequest(),
    );
    bannerAd!.load();

    // RewardedAd.load(
    //   adUnitId: "ca-app-pub-7050103229809241/9285784264",
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
    // RewardedAd.load(
    //   adUnitId: "ca-app-pub-7050103229809241/8622630782",
    //   request: const AdRequest(),
    //   rewardedAdLoadCallback: RewardedAdLoadCallback(
    //     onAdLoaded: ((onAdLoaded) {
    //       rewardedAd2 = onAdLoaded;
    //     }),
    //     onAdFailedToLoad: ((onAdFailedToLoad) {
    //       // print("Failed: ${onAdFailedToLoad.message}");
    //     }),
    //   ),
    // );
    super.initState();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _notificationController.dispose();

    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: AppColors
    //         .backgroundColour, // Change this color to your desired color
    //   ),
    // );

    // controllerToIncreaseCurve.dispose();
    // controllerToDecreaseCurve.dispose();
    super.dispose();
  }

  void taskDetails() {
    if (widget.taskName != null &&
        widget.taskDes != null &&
        widget.taskNoti != null &&
        widget.taskTime != null &&
        widget.taskDate != null) {
      _taskNameController.text = widget.taskName!;
      _descriptionController.text = widget.taskDes!;
      _notificationController.text = widget.taskNoti!;
      log(widget.taskType!);
      updateTask = true;
    }
  }

  int initialMinuteSelection(int minute) {
    if (minute > 0 && minute <= 15) {
      return 15;
    } else if (minute > 15 && minute <= 30) {
      return 30;
    } else if (minute > 30 && minute <= 45) {
      return 45;
    } else if (minute > 45) {
      return 0;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<AllAppProviders>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.transparent,
          // secondary: AppColors.backgroundColour.withOpacity(0.4),
        ),
      ),
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.mainColor,
        // appBar: AppBar(
        //   leading: Align(
        //     alignment: Alignment.centerRight,
        //     child: CustomGlassIconButton(
        //       onPressed: (() {
        //         Navigator.pop(context);
        //         // Navigator.pop(context);
        //       }),
        //       icon: Icons.arrow_back_ios_new,
        //     ),
        //   ),
        //   title: Align(
        //     alignment: Alignment.center,
        //     child: GlassmorphicContainer(
        //       width: double.infinity,
        //       height: 41,
        //       borderRadius: 40,
        //       linearGradient: LinearGradient(
        //         colors: [
        //           AppColors.white.withOpacity(0.1),
        //           AppColors.white.withOpacity(0.3),
        //         ],
        //       ),
        //       border: 2,
        //       blur: 4,
        //       borderGradient: LinearGradient(
        //         colors: [
        //           AppColors.white.withOpacity(0.3),
        //           AppColors.white.withOpacity(0.5),
        //         ],
        //       ),
        //       child: const Center(
        //         child: SingleChildScrollView(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.center,
        //             children: [
        //               Text(
        //                 "Add new task",
        //                 style: TextStyle(
        //                   overflow: TextOverflow.fade,
        //                   fontSize: 17,
        //                   fontWeight: FontWeight.bold,
        //                   letterSpacing: 3,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        //   backgroundColor: AppColors.backgroundColour,
        //   elevation: 0,
        // ),
        bottomNavigationBar: bannerAd != null
            ? SizedBox(
                width: MediaQuery.of(context).size.width,
                height: bannerAd!.size.height.toDouble(),
                child: AdWidget(
                  ad: bannerAd!,
                ),
              )
            : null,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: (!updateTask)
                      ? AppColors.backgroundColour
                      : AppColors.mainColor,
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomAppBarLeading(
                        icon: CupertinoIcons.back,
                        onPressed: (() {
                          Navigator.pop(context);
                        }),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: GlassmorphicContainer(
                          width: (!updateTask)
                              ? MediaQuery.of(context).size.width - 180
                              : MediaQuery.of(context).size.width - 170,
                          height: 41,
                          borderRadius: 40,
                          linearGradient:
                              AppColors.customGlassIconButtonGradient,
                          border: 2,
                          blur: 4,
                          borderGradient:
                              AppColors.customGlassIconButtonBorderGradient,
                          child: CustomApBarTitleChildText(
                            heading: (!updateTask) ? "NEW TASK" : "UPDATE TASK",
                          ),
                        ),
                      ),
                      Consumer<AllAppProviders>(
                        builder: ((
                          allAppProvidersContext,
                          allAppProvidersProvider,
                          allAppProvidersChild,
                        ) {
                          return GestureDetector(
                            onTap: (allAppProvidersProvider
                                    .newTaskUploadLoading)
                                ? null
                                : (() async {
                                    // log(widget.notificationID.toString());

                                    HapticFeedback.mediumImpact();

                                    nameFocusNode!.unfocus();
                                    desFocusNode!.unfocus();
                                    notiFocusNode!.unfocus();
                                    if (_taskNameController.text.isNotEmpty &&
                                        _notificationController
                                            .text.isNotEmpty &&
                                        inputDateTime.isNotEmpty &&
                                        _descriptionController
                                            .text.isNotEmpty) {
                                      allAppProvidersProvider
                                          .newTaskUploadLoadingFunc(true);
                                      token =
                                          await StorageServices.getUsrToken();
                                      uid = await StorageServices.getUID();

                                      if (!updateTask) {
                                        http.Response response =
                                            await http.post(
                                          Uri.parse(
                                              "${Keys.apiTasksBaseUrl}/createTask"),
                                          headers: {
                                            HttpHeaders.contentTypeHeader:
                                                "application/json",
                                            HttpHeaders.authorizationHeader:
                                                'Bearer $token',
                                          },
                                          body: jsonEncode({
                                            "uid": uid,
                                            "taskDes": _descriptionController
                                                .text
                                                .trim(),
                                            "taskDate": allAppProvidersProvider
                                                .dateText,
                                            "taskName":
                                                _taskNameController.text.trim(),
                                            "taskNotification":
                                                _notificationController.text
                                                    .trim(),
                                            "taskTime": allAppProvidersProvider
                                                .timeText,
                                            "taskType": allAppProvidersProvider
                                                .selectedType,
                                            "taskPoints": 10,
                                          }),
                                        );

                                        Map<String, dynamic> responseJson =
                                            jsonDecode(response.body);
                                        log(responseJson.toString());

                                        if (response.statusCode == 200) {
                                          if (responseJson["success"]) {
                                            await NotificationServices()
                                                .createScheduledTaskNotification(
                                              id: responseJson[
                                                  Keys.notificationID],
                                              title: _notificationController
                                                  .text
                                                  .trim(),
                                              body: _descriptionController.text
                                                  .trim(),
                                              dateTime: scheduleDateTIme,
                                              payload:
                                                  scheduleDateTIme.toString(),
                                            )
                                                .then((value) {
                                              allAppProvidersProvider
                                                  .selectedTypeFunc("Personal");
                                              allAppProvidersProvider
                                                  .newTaskUploadLoadingFunc(
                                                      false);
                                              Navigator.pop(context);
                                              return ScaffoldMessenger.of(
                                                      allAppProvidersContext)
                                                  .showSnackBar(
                                                AppSnackbar()
                                                    .customizedAppSnackbar(
                                                  message:
                                                      responseJson["message"],
                                                  context:
                                                      allAppProvidersContext,
                                                ),
                                              );
                                            });

                                            // await rewardedAd?.show(
                                            //   onUserEarnedReward:
                                            //       ((ad, point) {}),
                                            // );

                                            // rewardedAd
                                            //         ?.fullScreenContentCallback =
                                            //     FullScreenContentCallback(
                                            //   onAdClicked: ((ad) {}),
                                            //   onAdDismissedFullScreenContent:
                                            //       ((ad) {
                                            //     // print("ad dismissed");
                                            //   }),
                                            //   onAdFailedToShowFullScreenContent:
                                            //       ((ad, err) {
                                            //     ad.dispose();
                                            //     // print("ad error $err");
                                            //   }),
                                            //   onAdImpression: ((ad) {}),
                                            //   onAdShowedFullScreenContent: ((ad) {
                                            //     // print("ad shown ${ad.responseInfo}");
                                            //   }),
                                            //   onAdWillDismissFullScreenContent:
                                            //       ((ad) {}),
                                            // );
                                          } else {
                                            allAppProvidersProvider
                                                .newTaskUploadLoadingFunc(
                                                    false);
                                            AppSnackbar().customizedAppSnackbar(
                                              message: responseJson["message"],
                                              context: allAppProvidersContext,
                                            );
                                          }
                                        } else {
                                          allAppProvidersProvider
                                              .newTaskUploadLoadingFunc(false);
                                          AppSnackbar().customizedAppSnackbar(
                                            message:
                                                response.statusCode.toString(),
                                            context: allAppProvidersContext,
                                          );
                                        }

                                        allAppProvidersProvider
                                            .newTaskUploadLoadingFunc(false);
                                      } else {
                                        // log(widget.taskType!);
                                        http.Response response =
                                            await http.post(
                                          Uri.parse(
                                              "${Keys.apiTasksBaseUrl}/updateTask"),
                                          headers: {
                                            "content-type": "application/json",
                                            'authorization': 'Bearer $token',
                                          },
                                          body: jsonEncode({
                                            Keys.taskName:
                                                _taskNameController.text.trim(),
                                            Keys.taskDes: _descriptionController
                                                .text
                                                .trim(),
                                            Keys.taskDate:
                                                allAppProvidersProvider.dateText
                                                    .trim(),
                                            Keys.taskTime:
                                                allAppProvidersProvider.timeText
                                                    .trim(),
                                            Keys.taskNotification:
                                                _notificationController.text
                                                    .trim(),
                                            Keys.taskType: widget.taskType,
                                            Keys.notificationID:
                                                widget.notificationID,
                                            Keys.uid: uid,
                                          }),
                                        );

                                        log(response.statusCode.toString());

                                        if (response.statusCode == 200) {
                                          Map<String, dynamic> responseJson =
                                              jsonDecode(response.body);
                                          log(responseJson.toString());
                                          if (responseJson["success"]) {
                                            log("message");

                                            // await rewardedAd2?.show(
                                            //   onUserEarnedReward:
                                            //       ((ad, point) {}),
                                            // );
                                            // rewardedAd2
                                            //         ?.fullScreenContentCallback =
                                            //     FullScreenContentCallback(
                                            //   onAdClicked: ((ad) {}),
                                            //   onAdDismissedFullScreenContent:
                                            //       ((ad) async {
                                            //     // print("ad dismissed");
                                            //   }),
                                            //   onAdFailedToShowFullScreenContent:
                                            //       ((ad, err) {
                                            //     ad.dispose();
                                            //     // print("ad error $err");
                                            //   }),
                                            //   onAdImpression: ((ad) {}),
                                            //   onAdShowedFullScreenContent: ((ad) {
                                            //     // print("ad shown ${ad.responseInfo}");
                                            //   }),
                                            //   onAdWillDismissFullScreenContent:
                                            //       ((ad) {}),
                                            // );

                                            await NotificationServices()
                                                .cancelTaskScheduledNotification(
                                                    id: widget.notificationID!);

                                            await NotificationServices()
                                                .createScheduledTaskNotification(
                                              id: widget.notificationID!,
                                              title: _notificationController
                                                  .text
                                                  .trim(),
                                              body: _descriptionController.text
                                                  .trim(),
                                              payload: _taskNameController.text
                                                  .trim(),
                                              dateTime: scheduleDateTIme,
                                            )
                                                .then((value) {
                                              ScaffoldMessenger.of(
                                                      allAppProvidersContext)
                                                  .showSnackBar(
                                                AppSnackbar()
                                                    .customizedAppSnackbar(
                                                  message:
                                                      responseJson["message"],
                                                  context:
                                                      allAppProvidersContext,
                                                ),
                                              );
                                              allAppProvidersProvider
                                                  .newTaskUploadLoadingFunc(
                                                      false);

                                              Navigator.pop(context);
                                            });

                                            // ScaffoldMessenger.of(
                                            //         allAppProvidersContext)
                                            //     .showSnackBar(
                                            //   AppSnackbar()
                                            //       .customizedAppSnackbar(
                                            //     message:
                                            //         responseJson["message"],
                                            //     context: allAppProvidersContext,
                                            //   ),
                                            // );
                                            // allAppProvidersProvider
                                            //     .newTaskUploadLoadingFunc(
                                            //         false);
                                            //
                                            // Navigator.pop(context);
                                          } else {
                                            allAppProvidersProvider
                                                .newTaskUploadLoadingFunc(
                                                    false);
                                            ScaffoldMessenger.of(
                                                    allAppProvidersContext)
                                                .showSnackBar(
                                              AppSnackbar()
                                                  .customizedAppSnackbar(
                                                message:
                                                    responseJson["message"],
                                                context: allAppProvidersContext,
                                              ),
                                            );
                                          }
                                        } else {
                                          allAppProvidersProvider
                                              .newTaskUploadLoadingFunc(false);
                                          ScaffoldMessenger.of(
                                                  allAppProvidersContext)
                                              .showSnackBar(
                                            AppSnackbar().customizedAppSnackbar(
                                              message: response.statusCode
                                                  .toString(),
                                              context: allAppProvidersContext,
                                            ),
                                          );
                                        }
                                        allAppProvidersProvider
                                            .newTaskUploadLoadingFunc(false);
                                      }

                                      allAppProvidersProvider
                                          .newTaskUploadLoadingFunc(false);
                                    } else {
                                      allAppProvidersProvider
                                          .newTaskUploadLoadingFunc(false);
                                      ScaffoldMessenger.of(
                                              allAppProvidersContext)
                                          .showSnackBar(
                                        AppSnackbar().customizedAppSnackbar(
                                          message:
                                              "Looks like you didn't fill all the fields!",
                                          context: allAppProvidersContext,
                                        ),
                                      );
                                    }
                                    allAppProvidersProvider
                                        .newTaskUploadLoadingFunc(false);
                                  }),
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                              ),
                              height: 41,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.blackLow.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                  ),
                                ],
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: (allAppProvidersProvider
                                      .newTaskUploadLoading)
                                  ? Center(
                                      child: Lottie.asset(
                                        "assets/loading-animation.json",
                                        // width: MediaQuery.of(context)
                                        //         .size
                                        //         .width /
                                        //     2,
                                        // height: 50,
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        (!updateTask) ? "ADD TASK" : "UPDATE",
                                        style: const TextStyle(
                                          color: AppColors.backgroundColour,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Visibility(
                  visible: !updateTask,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColour,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(
                          MediaQuery.of(context).size.width / 3,
                        ),
                      ),
                    ),
                    child: Center(
                      child: GlassmorphicContainer(
                        margin: const EdgeInsets.only(
                          top: 20,
                          bottom: 30,
                        ),
                        width: 100,
                        height: 100,
                        borderRadius: 50,
                        linearGradient: AppColors.customGlassIconButtonGradient,
                        border: 2,
                        blur: 4,
                        borderGradient:
                            AppColors.customGlassIconButtonBorderGradient,
                        child: const Center(
                          child: Icon(
                            Icons.work,
                            color: AppColors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                    left: 5,
                    right: 5,
                    bottom: 20,
                  ),
                  child: Column(
                    children: [
                      if (!updateTask)
                        Container(
                          margin: const EdgeInsets.only(
                            top: 20,
                            bottom: 5,
                            left: 15,
                            right: 15,
                          ),
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          // color: AppColors.sky,
                          decoration: BoxDecoration(
                            // color: AppColors.sky,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Consumer<AllAppProviders>(
                            builder: (allAppProvidersCtx,
                                allAppProvidersProvider, allAppProvidersChild) {
                              List<Text> taskTypeTextList = [];

                              for (String type in taskType) {
                                taskTypeTextList.add(
                                  Text(
                                    type,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }

                              return Container(
                                // padding: const EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundColour,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: CupertinoPicker(
                                  magnification: 1.1,
                                  diameterRatio: 1.5,
                                  backgroundColor: AppColors.transparent,
                                  itemExtent: 23,
                                  onSelectedItemChanged: (value) {
                                    allAppProvidersProvider
                                        .selectedTypeFunc(taskType[value]);
                                    HapticFeedback.heavyImpact();
                                    // print(AllAppProvidersProvider.selectedType);
                                    // print(taskType[value]);
                                  },
                                  children: taskTypeTextList,
                                ),
                              );
                            },
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: CustomTextField(
                          focusNode: nameFocusNode,
                          controller: _taskNameController,
                          hintText: "Enter your task name",
                          keyboard: TextInputType.name,
                          isPassField: false,
                          isEmailField: false,
                          isPassConfirmField: false,
                          icon: Icons.drive_file_rename_outline_rounded,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: CustomTextField(
                          focusNode: desFocusNode,
                          controller: _descriptionController,
                          hintText: "Enter your task description",
                          keyboard: TextInputType.multiline,
                          isPassField: false,
                          isEmailField: false,
                          isPassConfirmField: false,
                          icon: Icons.description,
                          minLen: 1,
                          maxLen: 5,
                        ),
                      ),
                      Consumer<AllAppProviders>(
                        builder: (allAppProvidersContext,
                            allAppProvidersProvider, allAppProvidersChild) {
                          return GestureDetector(
                            onTap: (() async {
                              // String initialYear = '';
                              // String initialMonth = '';
                              // String initialDay = '';
                              // String initialHour = '';
                              // String initialMinute = '';
                              //
                              // if (widget.taskDate != null &&
                              //     widget.taskTime != null) {
                              //   int dateStringLen = widget.taskDate!.length;
                              //   initialYear =
                              //       "${widget.taskDate![dateStringLen - 4]}${widget.taskDate![dateStringLen - 3]}${widget.taskDate![dateStringLen - 2]}${widget.taskDate![dateStringLen - 1]}";
                              //   initialDay =
                              //       "${widget.taskDate![0]}${widget.taskDate![1]}";
                              //   initialMonth =
                              //       "${widget.taskDate![3]}${widget.taskDate![4]}";
                              //
                              //   initialHour =
                              //       "${widget.taskTime![0]}${widget.taskTime![1]}";
                              //   initialMinute =
                              //       "${widget.taskTime![3]}${widget.taskTime![4]}";
                              // }

                              final newDate = await showDatePicker(
                                context: context,
                                initialDate: date,
                                firstDate: date,
                                lastDate: DateTime(date.year + 2),
                              );

                              final newTime = await showIntervalTimePicker(
                                interval: 5,
                                visibleStep: VisibleStep.fifths,
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: (initialMinuteSelection(date.minute) ==
                                              0 ||
                                          initialMinuteSelection(date.minute) ==
                                              45)
                                      ? date.add(const Duration(hours: 1)).hour
                                      : date.hour,
                                  minute: initialMinuteSelection(
                                      DateTime.now().minute),
                                ),
                              );

                              if (newDate == null || newTime == null) {
                                return;
                              }
                              scheduleDateTIme = DateTime(
                                newDate.year,
                                newDate.month,
                                newDate.day,
                                newTime.hour,
                                newTime.minute,
                              );

                              String formattedTime = DateFormat.Hm().format(
                                DateTime(
                                  newDate.year,
                                  newDate.month,
                                  newDate.day,
                                  newTime.hour,
                                  newTime.minute,
                                ),
                              );

                              String formattedDate =
                                  DateFormat("dd/MM/yyyy").format(newDate);

                              allAppProvidersProvider
                                  .dateTextFunc(formattedDate);
                              allAppProvidersProvider
                                  .timeTextFunc(formattedTime);

                              if (scheduleDateTIme.difference(date).inSeconds >
                                  0) {
                                inputDateTime =
                                    "${allAppProvidersProvider.timeText} on ${allAppProvidersProvider.dateText}";
                              } else {
                                ScaffoldMessenger.of(allAppProvidersContext)
                                    .showSnackBar(
                                  AppSnackbar().customizedAppSnackbar(
                                    message: "Please select a date of future",
                                    context: allAppProvidersContext,
                                  ),
                                );
                              }
                            }),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 20,
                                bottom: 10,
                              ),
                              padding: const EdgeInsets.only(
                                top: 11,
                                bottom: 11,
                                left: 13,
                                right: 13,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  width: 1,
                                  color: AppColors.white,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_filled_rounded,
                                    color: AppColors.white,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    (inputDateTime.isNotEmpty)
                                        ? inputDateTime
                                        : "Time & Date",
                                    style: TextStyle(
                                      color: (inputDateTime.isNotEmpty ||
                                              (widget.taskDate != null &&
                                                  widget.taskTime != null))
                                          ? AppColors.white
                                          : AppColors.white.withOpacity(0.5),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        // child: ,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: CustomTextField(
                          focusNode: notiFocusNode,
                          controller: _notificationController,
                          hintText: "Enter your notification message",
                          keyboard: TextInputType.name,
                          isPassField: false,
                          isEmailField: false,
                          isPassConfirmField: false,
                          icon: Icons.drive_file_rename_outline_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // SliverToBoxAdapter(
              //   child: Visibility(
              //     visible: !updateTask,
              //     child: Container(
              //       width: MediaQuery.of(context).size.width,
              //       decoration: BoxDecoration(
              //         color: AppColors.backgroundColour,
              //         borderRadius: BorderRadius.only(
              //           topLeft: Radius.circular(
              //             MediaQuery.of(context).size.width / 3,
              //           ),
              //         ),
              //       ),
              //       child: Padding(
              //         padding: EdgeInsets.only(
              //           left: MediaQuery.of(context).size.width / 6,
              //           right: MediaQuery.of(context).size.width / 6,
              //         ),
              //         child: Consumer<AllAppProviders>(
              //           builder: ((
              //             allAppProvidersContext,
              //             allAppProvidersProvider,
              //             allAppProvidersChild,
              //           ) {
              //             return GestureDetector(
              //               onTap: (allAppProvidersProvider
              //                       .newTaskUploadLoading)
              //                   ? null
              //                   : (() async {
              //                       HapticFeedback.mediumImpact();
              //
              //                       nameFocusNode!.unfocus();
              //                       desFocusNode!.unfocus();
              //                       notiFocusNode!.unfocus();
              //                       if (_taskNameController.text.isNotEmpty &&
              //                           _notificationController
              //                               .text.isNotEmpty &&
              //                           inputDateTime.isNotEmpty &&
              //                           _descriptionController
              //                               .text.isNotEmpty) {
              //                         allAppProvidersProvider
              //                             .newTaskUploadLoadingFunc(true);
              //                         token =
              //                             await StorageServices.getUsrToken();
              //                         uid = await StorageServices.getUID();
              //
              //                         log(token);
              //
              //                         if (!updateTask) {
              //                           http.Response response =
              //                               await http.post(
              //                             Uri.parse(
              //                                 "${Keys.apiTasksBaseUrl}/createTask"),
              //                             headers: {
              //                               HttpHeaders.contentTypeHeader:
              //                                   "application/json",
              //                               HttpHeaders.authorizationHeader:
              //                                   'Bearer $token',
              //                             },
              //                             body: jsonEncode({
              //                               "uid": uid,
              //                               "taskDes": _descriptionController
              //                                   .text
              //                                   .trim(),
              //                               "taskDate": allAppProvidersProvider
              //                                   .dateText,
              //                               "taskName":
              //                                   _taskNameController.text.trim(),
              //                               "taskNotification":
              //                                   _notificationController.text
              //                                       .trim(),
              //                               "taskTime": allAppProvidersProvider
              //                                   .timeText,
              //                               "taskType": allAppProvidersProvider
              //                                   .selectedType,
              //                               "taskPoints": 10,
              //                             }),
              //                           );
              //
              //                           Map<String, dynamic> responseJson =
              //                               jsonDecode(response.body);
              //                           log(responseJson.toString());
              //
              //                           if (response.statusCode == 200) {
              //                             if (responseJson["success"]) {
              //                               await NotificationServices()
              //                                   .createScheduledTaskNotification(
              //                                 id: responseJson[
              //                                     Keys.notificationID],
              //                                 title: _notificationController
              //                                     .text
              //                                     .trim(),
              //                                 body: _descriptionController.text
              //                                     .trim(),
              //                                 dateTime: scheduleDateTIme,
              //                                 payload:
              //                                     scheduleDateTIme.toString(),
              //                               )
              //                                   .then((value) {
              //                                 allAppProvidersProvider
              //                                     .selectedTypeFunc("Personal");
              //                                 allAppProvidersProvider
              //                                     .newTaskUploadLoadingFunc(
              //                                         false);
              //                                 Navigator.pop(context);
              //                                 return ScaffoldMessenger.of(
              //                                         allAppProvidersContext)
              //                                     .showSnackBar(
              //                                   AppSnackbar()
              //                                       .customizedAppSnackbar(
              //                                     message:
              //                                         responseJson["message"],
              //                                     context:
              //                                         allAppProvidersContext,
              //                                   ),
              //                                 );
              //                               });
              //
              //                               // await rewardedAd?.show(
              //                               //   onUserEarnedReward:
              //                               //       ((ad, point) {}),
              //                               // );
              //
              //                               // rewardedAd
              //                               //         ?.fullScreenContentCallback =
              //                               //     FullScreenContentCallback(
              //                               //   onAdClicked: ((ad) {}),
              //                               //   onAdDismissedFullScreenContent:
              //                               //       ((ad) {
              //                               //     // print("ad dismissed");
              //                               //   }),
              //                               //   onAdFailedToShowFullScreenContent:
              //                               //       ((ad, err) {
              //                               //     ad.dispose();
              //                               //     // print("ad error $err");
              //                               //   }),
              //                               //   onAdImpression: ((ad) {}),
              //                               //   onAdShowedFullScreenContent: ((ad) {
              //                               //     // print("ad shown ${ad.responseInfo}");
              //                               //   }),
              //                               //   onAdWillDismissFullScreenContent:
              //                               //       ((ad) {}),
              //                               // );
              //                             } else {
              //                               allAppProvidersProvider
              //                                   .newTaskUploadLoadingFunc(
              //                                       false);
              //                               AppSnackbar().customizedAppSnackbar(
              //                                 message: responseJson["message"],
              //                                 context: allAppProvidersContext,
              //                               );
              //                             }
              //                           } else {
              //                             allAppProvidersProvider
              //                                 .newTaskUploadLoadingFunc(false);
              //                             AppSnackbar().customizedAppSnackbar(
              //                               message:
              //                                   response.statusCode.toString(),
              //                               context: allAppProvidersContext,
              //                             );
              //                           }
              //
              //                           allAppProvidersProvider
              //                               .newTaskUploadLoadingFunc(false);
              //                         }
              //
              //                         allAppProvidersProvider
              //                             .newTaskUploadLoadingFunc(false);
              //                       } else {
              //                         allAppProvidersProvider
              //                             .newTaskUploadLoadingFunc(false);
              //                         ScaffoldMessenger.of(
              //                                 allAppProvidersContext)
              //                             .showSnackBar(
              //                           AppSnackbar().customizedAppSnackbar(
              //                             message:
              //                                 "Looks like you didn't fill all the fields!",
              //                             context: allAppProvidersContext,
              //                           ),
              //                         );
              //                       }
              //                       allAppProvidersProvider
              //                           .newTaskUploadLoadingFunc(false);
              //                     }),
              //               child: Padding(
              //                 padding: const EdgeInsets.symmetric(
              //                   vertical: 30,
              //                   horizontal: 20,
              //                 ),
              //                 child: Container(
              //                   width: MediaQuery.of(context).size.width / 1.7,
              //                   height: 50,
              //                   decoration: BoxDecoration(
              //                     boxShadow: [
              //                       BoxShadow(
              //                         color:
              //                             AppColors.blackLow.withOpacity(0.3),
              //                         spreadRadius: 2,
              //                         blurRadius: 10,
              //                       ),
              //                     ],
              //                     color: AppColors.white,
              //                     borderRadius: BorderRadius.circular(15),
              //                   ),
              //                   child: Center(
              //                     child: (allAppProvidersProvider
              //                             .newTaskUploadLoading)
              //                         ? Center(
              //                             child: Lottie.asset(
              //                               "assets/loading-animation.json",
              //                               width: MediaQuery.of(context)
              //                                       .size
              //                                       .width /
              //                                   2,
              //                               height: 50,
              //                             ),
              //                           )
              //                         : Text(
              //                             (!updateTask)
              //                                 ? "ADD YOUR TASK"
              //                                 : "UPDATE YOUR TASK",
              //                             style: const TextStyle(
              //                               color: AppColors.backgroundColour,
              //                               fontWeight: FontWeight.bold,
              //                               fontSize: 17,
              //                             ),
              //                           ),
              //                   ),
              //                 ),
              //               ),
              //             );
              //           }),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        // SingleChildScrollView(
        //   child: Align(
        //     alignment: Alignment.bottomCenter,
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.stretch,
        //       children: [
        //         Container(
        //           width: MediaQuery.of(context).size.width,
        //           decoration: BoxDecoration(
        //             color: AppColors.backgroundColour,
        //             borderRadius: BorderRadius.only(
        //               bottomLeft: Radius.circular(
        //                 MediaQuery.of(context).size.width / 3,
        //               ),
        //             ),
        //           ),
        //           child: Center(
        //             child: GlassmorphicContainer(
        //               margin: const EdgeInsets.only(
        //                 top: 20,
        //                 bottom: 30,
        //               ),
        //               width: 100,
        //               height: 100,
        //               borderRadius: 50,
        //               linearGradient: AppColors.customGlassIconButtonGradient,
        //               border: 2,
        //               blur: 4,
        //               borderGradient:
        //                   AppColors.customGlassIconButtonBorderGradient,
        //               child: const Center(
        //                 child: Icon(
        //                   Icons.work,
        //                   color: AppColors.white,
        //                   size: 30,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.only(
        //             top: 5,
        //             left: 5,
        //             right: 5,
        //             bottom: 20,
        //           ),
        //           child: Column(
        //             children: [
        //               if (!updateTask)
        //                 Container(
        //                   margin: const EdgeInsets.only(
        //                     top: 30,
        //                     bottom: 15,
        //                     left: 15,
        //                     right: 15,
        //                   ),
        //                   padding: const EdgeInsets.only(left: 5, right: 5),
        //                   height: 40,
        //                   width: MediaQuery.of(context).size.width,
        //                   // color: AppColors.sky,
        //                   decoration: BoxDecoration(
        //                     // color: AppColors.sky,
        //                     borderRadius: BorderRadius.circular(15),
        //                   ),
        //                   child: Consumer<AllAppProviders>(
        //                     builder: (allAppProvidersCtx,
        //                         allAppProvidersProvider, allAppProvidersChild) {
        //                       List<Text> taskTypeTextList = [];
        //
        //                       for (String type in taskType) {
        //                         taskTypeTextList.add(
        //                           Text(
        //                             type,
        //                             style: const TextStyle(
        //                               color: AppColors.white,
        //                               fontSize: 15,
        //                               fontWeight: FontWeight.w500,
        //                             ),
        //                           ),
        //                         );
        //                       }
        //
        //                       return Container(
        //                         // padding: const EdgeInsets.only(top: 5),
        //                         decoration: BoxDecoration(
        //                           color: AppColors.backgroundColour,
        //                           borderRadius: BorderRadius.circular(20),
        //                         ),
        //                         child: CupertinoPicker(
        //                           magnification: 1.1,
        //                           diameterRatio: 1.5,
        //                           backgroundColor: AppColors.transparent,
        //                           itemExtent: 23,
        //                           onSelectedItemChanged: (value) {
        //                             allAppProvidersProvider
        //                                 .selectedTypeFunc(taskType[value]);
        //                             HapticFeedback.heavyImpact();
        //                             // print(AllAppProvidersProvider.selectedType);
        //                             // print(taskType[value]);
        //                           },
        //                           children: taskTypeTextList,
        //                         ),
        //                       );
        //                     },
        //                   ),
        //                 ),
        //
        //               Container(
        //                 padding: const EdgeInsets.symmetric(
        //                   horizontal: 5,
        //                 ),
        //                 child: CustomTextField(
        //                   focusNode: nameFocusNode,
        //                   controller: _taskNameController,
        //                   hintText: "Enter your task name",
        //                   keyboard: TextInputType.name,
        //                   isPassField: false,
        //                   isEmailField: false,
        //                   isPassConfirmField: false,
        //                   icon: Icons.drive_file_rename_outline_rounded,
        //                 ),
        //               ),
        //               Container(
        //                 padding: const EdgeInsets.symmetric(
        //                   horizontal: 5,
        //                 ),
        //                 child: CustomTextField(
        //                   focusNode: desFocusNode,
        //                   controller: _descriptionController,
        //                   hintText: "Enter your task description",
        //                   keyboard: TextInputType.multiline,
        //                   isPassField: false,
        //                   isEmailField: false,
        //                   isPassConfirmField: false,
        //                   icon: Icons.description,
        //                   minLen: 1,
        //                   maxLen: 5,
        //                 ),
        //               ),
        //               Consumer<AllAppProviders>(
        //                 builder: (allAppProvidersContext,
        //                     allAppProvidersProvider, allAppProvidersChild) {
        //                   return GestureDetector(
        //                     onTap: (() async {
        //                       // String initialYear = '';
        //                       // String initialMonth = '';
        //                       // String initialDay = '';
        //                       // String initialHour = '';
        //                       // String initialMinute = '';
        //                       //
        //                       // if (widget.taskDate != null &&
        //                       //     widget.taskTime != null) {
        //                       //   int dateStringLen = widget.taskDate!.length;
        //                       //   initialYear =
        //                       //       "${widget.taskDate![dateStringLen - 4]}${widget.taskDate![dateStringLen - 3]}${widget.taskDate![dateStringLen - 2]}${widget.taskDate![dateStringLen - 1]}";
        //                       //   initialDay =
        //                       //       "${widget.taskDate![0]}${widget.taskDate![1]}";
        //                       //   initialMonth =
        //                       //       "${widget.taskDate![3]}${widget.taskDate![4]}";
        //                       //
        //                       //   initialHour =
        //                       //       "${widget.taskTime![0]}${widget.taskTime![1]}";
        //                       //   initialMinute =
        //                       //       "${widget.taskTime![3]}${widget.taskTime![4]}";
        //                       // }
        //
        //                       final newDate = await showDatePicker(
        //                         context: context,
        //                         initialDate: date,
        //                         firstDate: date,
        //                         lastDate: DateTime(date.year + 2),
        //                       );
        //
        //                       final newTime = await showIntervalTimePicker(
        //                         interval: 5,
        //                         visibleStep: VisibleStep.fifths,
        //                         context: context,
        //                         initialTime: TimeOfDay(
        //                           hour: (initialMinuteSelection(date.minute) ==
        //                                       0 ||
        //                                   initialMinuteSelection(date.minute) ==
        //                                       45)
        //                               ? date.add(const Duration(hours: 1)).hour
        //                               : date.hour,
        //                           minute: initialMinuteSelection(
        //                               DateTime.now().minute),
        //                         ),
        //                       );
        //
        //                       if (newDate == null || newTime == null) {
        //                         return;
        //                       }
        //                       scheduleDateTIme = DateTime(
        //                         newDate.year,
        //                         newDate.month,
        //                         newDate.day,
        //                         newTime.hour,
        //                         newTime.minute,
        //                       );
        //
        //                       String formattedTime = DateFormat.Hm().format(
        //                         DateTime(
        //                           newDate.year,
        //                           newDate.month,
        //                           newDate.day,
        //                           newTime.hour,
        //                           newTime.minute,
        //                         ),
        //                       );
        //
        //                       String formattedDate =
        //                           DateFormat("dd/MM/yyyy").format(newDate);
        //
        //                       allAppProvidersProvider
        //                           .dateTextFunc(formattedDate);
        //                       allAppProvidersProvider
        //                           .timeTextFunc(formattedTime);
        //
        //                       if (scheduleDateTIme.difference(date).inSeconds >
        //                           0) {
        //                         inputDateTime =
        //                             "${allAppProvidersProvider.timeText} on ${allAppProvidersProvider.dateText}";
        //                       } else {
        //                         ScaffoldMessenger.of(allAppProvidersContext)
        //                             .showSnackBar(
        //                           AppSnackbar().customizedAppSnackbar(
        //                             message: "Please select a date of future",
        //                             context: allAppProvidersContext,
        //                           ),
        //                         );
        //                       }
        //                     }),
        //                     child: Container(
        //                       alignment: Alignment.centerLeft,
        //                       margin: const EdgeInsets.only(
        //                         left: 20,
        //                         right: 20,
        //                         top: 20,
        //                         bottom: 10,
        //                       ),
        //                       padding: const EdgeInsets.only(
        //                         top: 11,
        //                         bottom: 11,
        //                         left: 13,
        //                         right: 13,
        //                       ),
        //                       decoration: BoxDecoration(
        //                         borderRadius: BorderRadius.circular(15),
        //                         border: Border.all(
        //                           width: 1,
        //                           color: AppColors.white,
        //                         ),
        //                       ),
        //                       child: Row(
        //                         children: [
        //                           const Icon(
        //                             Icons.access_time_filled_rounded,
        //                             color: AppColors.white,
        //                           ),
        //                           const SizedBox(
        //                             width: 10,
        //                           ),
        //                           Text(
        //                             (inputDateTime.isNotEmpty)
        //                                 ? inputDateTime
        //                                 : "Time & Date",
        //                             style: TextStyle(
        //                               color: (inputDateTime.isNotEmpty ||
        //                                       (widget.taskDate != null &&
        //                                           widget.taskTime != null))
        //                                   ? AppColors.white
        //                                   : AppColors.white.withOpacity(0.5),
        //                               fontSize: 15,
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                   );
        //                 },
        //                 // child: ,
        //               ),
        //               Container(
        //                 padding: const EdgeInsets.symmetric(
        //                   horizontal: 5,
        //                 ),
        //                 child: CustomTextField(
        //                   focusNode: notiFocusNode,
        //                   controller: _notificationController,
        //                   hintText: "Enter your notification message",
        //                   keyboard: TextInputType.name,
        //                   isPassField: false,
        //                   isEmailField: false,
        //                   isPassConfirmField: false,
        //                   icon: Icons.drive_file_rename_outline_rounded,
        //                 ),
        //               ),
        //               // UnityBannerAd(
        //               //   placementId: "Banner_Android",
        //               //   onLoad: (placementID) =>
        //               //       print("Banner loaded $placementID"),
        //               //   onClick: (placementID) =>
        //               //       print("Banner clicked $placementID"),
        //               //   onFailed: (placementID, error, message) => print(
        //               //     "Banner failed $placementID Banner loaded $message",
        //               //   ),
        //               // )
        //             ],
        //           ),
        //         ),
        //         Container(
        //           width: MediaQuery.of(context).size.width,
        //           decoration: BoxDecoration(
        //             color: AppColors.backgroundColour,
        //             borderRadius: BorderRadius.only(
        //               topLeft: Radius.circular(
        //                 MediaQuery.of(context).size.width / 3,
        //               ),
        //             ),
        //           ),
        //           child: Padding(
        //             padding: EdgeInsets.only(
        //               left: MediaQuery.of(context).size.width / 6,
        //               right: MediaQuery.of(context).size.width / 6,
        //             ),
        //             child: Consumer<AllAppProviders>(
        //               builder: ((
        //                 allAppProvidersContext,
        //                 allAppProvidersProvider,
        //                 allAppProvidersChild,
        //               ) {
        //                 return GestureDetector(
        //                   onTap: (allAppProvidersProvider.newTaskUploadLoading)
        //                       ? null
        //                       : (() async {
        //                           HapticFeedback.mediumImpact();
        //
        //                           nameFocusNode!.unfocus();
        //                           desFocusNode!.unfocus();
        //                           notiFocusNode!.unfocus();
        //                           if (_taskNameController.text.isNotEmpty &&
        //                               _notificationController.text.isNotEmpty &&
        //                               inputDateTime.isNotEmpty &&
        //                               _descriptionController.text.isNotEmpty) {
        //                             allAppProvidersProvider
        //                                 .newTaskUploadLoadingFunc(true);
        //                             token = await StorageServices.getUsrToken();
        //                             uid = await StorageServices.getUID();
        //
        //                             log(token);
        //
        //                             if (!updateTask) {
        //                               http.Response response = await http.post(
        //                                 Uri.parse(
        //                                     "${Keys.apiTasksBaseUrl}/createTask"),
        //                                 headers: {
        //                                   HttpHeaders.contentTypeHeader:
        //                                       "application/json",
        //                                   HttpHeaders.authorizationHeader:
        //                                       'Bearer $token',
        //                                 },
        //                                 body: jsonEncode({
        //                                   "uid": uid,
        //                                   "taskDes": _descriptionController.text
        //                                       .trim(),
        //                                   "taskDate":
        //                                       allAppProvidersProvider.dateText,
        //                                   "taskName":
        //                                       _taskNameController.text.trim(),
        //                                   "taskNotification":
        //                                       _notificationController.text
        //                                           .trim(),
        //                                   "taskTime":
        //                                       allAppProvidersProvider.timeText,
        //                                   "taskType": allAppProvidersProvider
        //                                       .selectedType,
        //                                   "taskPoints": 10,
        //                                 }),
        //                               );
        //
        //                               Map<String, dynamic> responseJson =
        //                                   jsonDecode(response.body);
        //                               log(responseJson.toString());
        //
        //                               if (response.statusCode == 200) {
        //                                 if (responseJson["success"]) {
        //                                   await NotificationServices()
        //                                       .createScheduledTaskNotification(
        //                                     id: responseJson[
        //                                         Keys.notificationID],
        //                                     title: _notificationController.text
        //                                         .trim(),
        //                                     body: _descriptionController.text
        //                                         .trim(),
        //                                     dateTime: scheduleDateTIme,
        //                                     payload:
        //                                         scheduleDateTIme.toString(),
        //                                   );
        //
        //                                   // await rewardedAd?.show(
        //                                   //   onUserEarnedReward:
        //                                   //       ((ad, point) {}),
        //                                   // );
        //
        //                                   // rewardedAd
        //                                   //         ?.fullScreenContentCallback =
        //                                   //     FullScreenContentCallback(
        //                                   //   onAdClicked: ((ad) {}),
        //                                   //   onAdDismissedFullScreenContent:
        //                                   //       ((ad) {
        //                                   //     // print("ad dismissed");
        //                                   //   }),
        //                                   //   onAdFailedToShowFullScreenContent:
        //                                   //       ((ad, err) {
        //                                   //     ad.dispose();
        //                                   //     // print("ad error $err");
        //                                   //   }),
        //                                   //   onAdImpression: ((ad) {}),
        //                                   //   onAdShowedFullScreenContent: ((ad) {
        //                                   //     // print("ad shown ${ad.responseInfo}");
        //                                   //   }),
        //                                   //   onAdWillDismissFullScreenContent:
        //                                   //       ((ad) {}),
        //                                   // );
        //
        //                                   AppSnackbar().customizedAppSnackbar(
        //                                     message: responseJson["message"],
        //                                     context: allAppProvidersContext,
        //                                   );
        //                                   allAppProvidersProvider
        //                                       .selectedTypeFunc("Personal");
        //                                   allAppProvidersProvider
        //                                       .newTaskUploadLoadingFunc(false);
        //                                   Navigator.pop(context);
        //                                 } else {
        //                                   allAppProvidersProvider
        //                                       .newTaskUploadLoadingFunc(false);
        //                                   AppSnackbar().customizedAppSnackbar(
        //                                     message: responseJson["message"],
        //                                     context: allAppProvidersContext,
        //                                   );
        //                                 }
        //                               } else {
        //                                 allAppProvidersProvider
        //                                     .newTaskUploadLoadingFunc(false);
        //                                 AppSnackbar().customizedAppSnackbar(
        //                                   message:
        //                                       response.statusCode.toString(),
        //                                   context: allAppProvidersContext,
        //                                 );
        //                               }
        //
        //                               allAppProvidersProvider
        //                                   .newTaskUploadLoadingFunc(false);
        //                             } else {
        //                               log(widget.taskType!);
        //                               http.Response response = await http.post(
        //                                 Uri.parse(
        //                                     "${Keys.apiTasksBaseUrl}/updateTask"),
        //                                 headers: {
        //                                   "content-type": "application/json",
        //                                   'authorization': 'Bearer $token',
        //                                 },
        //                                 body: jsonEncode({
        //                                   Keys.taskName:
        //                                       _taskNameController.text.trim(),
        //                                   Keys.taskDes: _descriptionController
        //                                       .text
        //                                       .trim(),
        //                                   Keys.taskDate: allAppProvidersProvider
        //                                       .dateText
        //                                       .trim(),
        //                                   Keys.taskTime: allAppProvidersProvider
        //                                       .timeText
        //                                       .trim(),
        //                                   Keys.taskNotification:
        //                                       _notificationController.text
        //                                           .trim(),
        //                                   Keys.taskType: widget.taskType,
        //                                   Keys.notificationID:
        //                                       widget.notificationID,
        //                                   Keys.uid: uid,
        //                                 }),
        //                               );
        //
        //                               log(response.statusCode.toString());
        //
        //                               if (response.statusCode == 200) {
        //                                 Map<String, dynamic> responseJson =
        //                                     jsonDecode(response.body);
        //                                 log(responseJson.toString());
        //                                 if (responseJson["success"]) {
        //                                   log("message");
        //
        //                                   // await rewardedAd2?.show(
        //                                   //   onUserEarnedReward:
        //                                   //       ((ad, point) {}),
        //                                   // );
        //                                   // rewardedAd2
        //                                   //         ?.fullScreenContentCallback =
        //                                   //     FullScreenContentCallback(
        //                                   //   onAdClicked: ((ad) {}),
        //                                   //   onAdDismissedFullScreenContent:
        //                                   //       ((ad) async {
        //                                   //     // print("ad dismissed");
        //                                   //   }),
        //                                   //   onAdFailedToShowFullScreenContent:
        //                                   //       ((ad, err) {
        //                                   //     ad.dispose();
        //                                   //     // print("ad error $err");
        //                                   //   }),
        //                                   //   onAdImpression: ((ad) {}),
        //                                   //   onAdShowedFullScreenContent: ((ad) {
        //                                   //     // print("ad shown ${ad.responseInfo}");
        //                                   //   }),
        //                                   //   onAdWillDismissFullScreenContent:
        //                                   //       ((ad) {}),
        //                                   // );
        //
        //                                   await NotificationServices()
        //                                       .cancelTaskScheduledNotification(
        //                                           id: widget.notificationID!);
        //
        //                                   await NotificationServices()
        //                                       .createScheduledTaskNotification(
        //                                     id: widget.notificationID!,
        //                                     title: _notificationController.text
        //                                         .trim(),
        //                                     body: _descriptionController.text
        //                                         .trim(),
        //                                     payload:
        //                                         _taskNameController.text.trim(),
        //                                     dateTime: scheduleDateTIme,
        //                                   );
        //
        //                                   ScaffoldMessenger.of(
        //                                           allAppProvidersContext)
        //                                       .showSnackBar(
        //                                     AppSnackbar().customizedAppSnackbar(
        //                                       message: responseJson["message"],
        //                                       context: allAppProvidersContext,
        //                                     ),
        //                                   );
        //                                   allAppProvidersProvider
        //                                       .newTaskUploadLoadingFunc(false);
        //
        //                                   Navigator.pop(context);
        //                                 } else {
        //                                   allAppProvidersProvider
        //                                       .newTaskUploadLoadingFunc(false);
        //                                   ScaffoldMessenger.of(
        //                                           allAppProvidersContext)
        //                                       .showSnackBar(
        //                                     AppSnackbar().customizedAppSnackbar(
        //                                       message: responseJson["message"],
        //                                       context: allAppProvidersContext,
        //                                     ),
        //                                   );
        //                                 }
        //                               } else {
        //                                 allAppProvidersProvider
        //                                     .newTaskUploadLoadingFunc(false);
        //                                 ScaffoldMessenger.of(
        //                                         allAppProvidersContext)
        //                                     .showSnackBar(
        //                                   AppSnackbar().customizedAppSnackbar(
        //                                     message:
        //                                         response.statusCode.toString(),
        //                                     context: allAppProvidersContext,
        //                                   ),
        //                                 );
        //                               }
        //                               allAppProvidersProvider
        //                                   .newTaskUploadLoadingFunc(false);
        //                             }
        //
        //                             allAppProvidersProvider
        //                                 .newTaskUploadLoadingFunc(false);
        //                           } else {
        //                             allAppProvidersProvider
        //                                 .newTaskUploadLoadingFunc(false);
        //                             ScaffoldMessenger.of(allAppProvidersContext)
        //                                 .showSnackBar(
        //                               AppSnackbar().customizedAppSnackbar(
        //                                 message:
        //                                     "Looks like you didn't fill all the fields!",
        //                                 context: allAppProvidersContext,
        //                               ),
        //                             );
        //                           }
        //                           allAppProvidersProvider
        //                               .newTaskUploadLoadingFunc(false);
        //                         }),
        //                   child: Padding(
        //                     padding: const EdgeInsets.symmetric(
        //                       vertical: 30,
        //                       horizontal: 20,
        //                     ),
        //                     child: Container(
        //                       width: MediaQuery.of(context).size.width / 1.7,
        //                       height: 50,
        //                       // margin: EdgeInsets.symmetric(
        //                       //   vertical: 30,
        //                       //   horizontal: 20,
        //                       // ),
        //
        //                       decoration: BoxDecoration(
        //                         boxShadow: [
        //                           BoxShadow(
        //                             color: AppColors.blackLow.withOpacity(0.3),
        //                             spreadRadius: 2,
        //                             blurRadius: 10,
        //                           ),
        //                         ],
        //                         color: AppColors.white,
        //                         borderRadius: BorderRadius.circular(15),
        //                       ),
        //                       child: Center(
        //                         child: (allAppProvidersProvider
        //                                 .newTaskUploadLoading)
        //                             ? Center(
        //                                 child: Lottie.asset(
        //                                   "assets/loading-animation.json",
        //                                   width: MediaQuery.of(context)
        //                                           .size
        //                                           .width /
        //                                       2,
        //                                   height: 50,
        //                                 ),
        //                               )
        //                             : Text(
        //                                 (!updateTask)
        //                                     ? "ADD YOUR TASK"
        //                                     : "UPDATE YOUR TASK",
        //                                 style: const TextStyle(
        //                                   color: AppColors.backgroundColour,
        //                                   fontWeight: FontWeight.bold,
        //                                   fontSize: 17,
        //                                 ),
        //                               ),
        //                       ),
        //                     ),
        //                   ),
        //                 );
        //               }),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // )
      ),
    );
  }
}
