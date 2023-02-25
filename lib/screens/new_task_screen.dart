import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Utils/custom_glass_icon.dart';
import 'package:task_app/Utils/custom_text_field_utils.dart';
import 'package:task_app/Utils/snackbar_utils.dart';
import 'package:task_app/services/notification_services.dart';
import 'package:task_app/services/shared_preferences.dart';
import 'package:task_app/styles.dart';

import '../providers/app_providers.dart';

class NewTaskScreen extends StatefulWidget {
  NewTaskScreen({
    super.key,
    this.taskType,
    this.taskTime,
    this.taskDate,
    this.taskDes,
    this.taskName,
    this.taskNoti,
    this.taskDoc,
    this.userEmail,
  });

  String? taskType;
  String? taskName;
  String? taskDes;
  String? taskTime;
  String? taskDate;
  String? taskNoti;
  String? taskDoc;
  String? userEmail;
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
  List<String> taskType = ["Business", "Personal"];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool editOrNew = false, backPressed = false;
  int taskCount = 0,
      taskPending = 0,
      taskBusiness = 0,
      taskPersonal = 0,
      taskDone = 0;
  NotificationServices notificationServices = NotificationServices();
  BannerAd? bannerAd;
  RewardedAd? rewardedAd;
  FocusNode? nameFocusNode;
  FocusNode? desFocusNode;
  FocusNode? notiFocusNode;
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  late AnimationController controllerToIncreaseCurve;
  late AnimationController controllerToDecreaseCurve;
  late Animation<double> animationToIncreasingCurve;
  late Animation<double> animationToDecreasingCurve;

  @override
  void initState() {
    _taskNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _notificationController = TextEditingController();
    nameFocusNode = FocusNode();
    desFocusNode = FocusNode();
    notiFocusNode = FocusNode();
    taskDetails();

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
      size: AdSize.banner,
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      listener: BannerAdListener(
        onAdLoaded: ((ad) {
          // print("Banner ad loaded ${ad.adUnitId}");
        }),
      ),
      request: AdRequest(),
    );
    bannerAd!.load();

    RewardedAd.load(
      adUnitId: "ca-app-pub-3940256099942544/5224354917",
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: ((onAdLoaded) {
          rewardedAd = onAdLoaded;
        }),
        onAdFailedToLoad: ((onAdFailedToLoad) {
          print("Failed: ${onAdFailedToLoad.message}");
        }),
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _notificationController.dispose();
    // controllerToIncreaseCurve.dispose();
    // controllerToDecreaseCurve.dispose();
    super.dispose();
  }

  Future<void> updatePoints({required int points}) async {
    String email = await StorageServices.getUserEmail();

    DocumentSnapshot userDoc = await users.doc(email).get();

    if (!userDoc.data().toString().contains(Keys.userPoints)) {
      await users.doc(email).set(
        {
          Keys.userPoints: 0,
        },
        SetOptions(
          merge: true,
        ),
      );
    }
    await users.doc(email).update(
      {
        Keys.userPoints: await userDoc[Keys.userPoints] + points,
      },
    );
  }

  Future<void> addTask({
    required String type,
    required String name,
    required String date,
    required String des,
    required String notify,
    required String time,
  }) async {
    CollectionReference users = firestore.collection("users");
    String email = await StorageServices.getUserEmail();
    // bool isNewUser = await StorageServices.getIsNewUser();

    DocumentSnapshot userDoc = await users.doc(email).get();

    taskCount = userDoc[Keys.taskCount];
    taskPending = userDoc[Keys.taskPending];
    taskBusiness = userDoc[Keys.taskBusiness];
    taskPersonal = userDoc[Keys.taskPersonal];
    taskID = "TID${(taskCount + 1).toString()}";

    await NotificationServices().createScheduledTaskNotification(
      id: taskCount + 1,
      title: _notificationController.text,
      body: "${_taskNameController.text}\n${_descriptionController.text}",
      dateTime: scheduleDateTIme,
      payload: scheduleDateTIme.toString(),
    );

    users.doc(email).collection("tasks").doc(taskID).set({
      Keys.taskType: type,
      Keys.taskDate: date,
      Keys.taskDes: _descriptionController.text,
      Keys.taskName: _taskNameController.text,
      Keys.taskNotification: _notificationController.text,
      Keys.taskTime: time,
      Keys.taskStatus: "Pending",
      Keys.notificationID: taskCount + 1,
    });
  }

  Future<void> updateUserDetails({
    required AllAppProviders loadingProvider,
    required int updateTaskCount,
    required String taskType,
  }) async {
    CollectionReference users = firestore.collection("users");
    String email = await StorageServices.getUserEmail();

    DocumentSnapshot userDoc = await users.doc(email).get();

    await users.doc(email).update(
      {
        Keys.taskCount: userDoc[Keys.taskCount] + 1,
      },
    );
    await users.doc(email).update(
      {
        Keys.taskPending: userDoc[Keys.taskPending] + 1,
      },
    );

    String newTaskType =
        (taskType == "Business") ? Keys.taskBusiness : Keys.taskPersonal;
    await users.doc(email).update(
      {
        newTaskType: (newTaskType == Keys.taskBusiness)
            ? userDoc[Keys.taskBusiness] + 1
            : userDoc[Keys.taskPersonal] + 1,
      },
    );

    await users.doc(email).update(
      {
        Keys.taskDone: userDoc[Keys.taskDone],
      },
    ).whenComplete(() {
      return AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: "Hurray",
        desc: "Your next goal is stored successfully",
      ).show();
    });
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

      editOrNew = true;
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
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.mainColor,
        appBar: AppBar(
          leading: Align(
            alignment: Alignment.centerRight,
            child: CustomGlassIconButton(
              onPressed: (() {
                Navigator.pop(context);
                // Navigator.pop(context);
              }),
              icon: Icons.arrow_back_ios_new,
            ),
          ),
          title: Align(
            alignment: Alignment.center,
            child: GlassmorphicContainer(
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Add new task",
                        style: const TextStyle(
                          overflow: TextOverflow.fade,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          backgroundColor: AppColors.backgroundColour,
          elevation: 0,
        ),
        bottomNavigationBar: Container(
          color: AppColors.backgroundColour,
          width: MediaQuery.of(context).size.width,
          height: bannerAd!.size.height.toDouble(),
          child: AdWidget(
            ad: bannerAd!,
          ),
        ),
        body: SingleChildScrollView(
          physics: AppColors.scrollPhysics,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
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
                      margin: EdgeInsets.only(
                        top: 20,
                        bottom: 30,
                      ),
                      width: 100,
                      height: 100,
                      borderRadius: 50,
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
                        child: Icon(
                          Icons.work,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                    bottom: 20,
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 30,
                          bottom: 15,
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
                          builder: (allAppProvidersCtx, allAppProvidersProvider,
                              allAppProvidersChild) {
                            List<Text> taskTypeTextList = [];

                            for (String type in taskType) {
                              taskTypeTextList.add(
                                Text(
                                  type,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColour,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CupertinoPicker(
                                backgroundColor: AppColors.transparent,
                                itemExtent: 23,
                                onSelectedItemChanged: (value) {
                                  allAppProvidersProvider
                                      .selectedTypeFunc(taskType[value]);
                                  // print(AllAppProvidersProvider.selectedType);
                                  print(taskType[value]);
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
                                interval: 15,
                                visibleStep: VisibleStep.fifteenths,
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
                                  Icon(
                                    Icons.access_time_filled_rounded,
                                    color: AppColors.white,
                                  ),
                                  SizedBox(
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
                      // UnityBannerAd(
                      //   placementId: "Banner_Android",
                      //   onLoad: (placementID) =>
                      //       print("Banner loaded $placementID"),
                      //   onClick: (placementID) =>
                      //       print("Banner clicked $placementID"),
                      //   onFailed: (placementID, error, message) => print(
                      //     "Banner failed $placementID Banner loaded $message",
                      //   ),
                      // )
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: AppColors.backgroundColour,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          MediaQuery.of(context).size.width / 3,
                        ),
                      )),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 6,
                      right: MediaQuery.of(context).size.width / 6,
                    ),
                    child: Consumer<AllAppProviders>(
                      builder: ((
                        allAppProvidersContext,
                        allAppProvidersProvider,
                        allAppProvidersChild,
                      ) {
                        return GestureDetector(
                          onTap: (allAppProvidersProvider.newTaskUploadLoading)
                              ? null
                              : (() async {
                                  nameFocusNode!.unfocus();
                                  desFocusNode!.unfocus();
                                  notiFocusNode!.unfocus();
                                  if (_taskNameController.text.isNotEmpty &&
                                      _notificationController.text.isNotEmpty &&
                                      inputDateTime.isNotEmpty &&
                                      _descriptionController.text.isNotEmpty) {
                                    allAppProvidersProvider
                                        .newTaskUploadLoadingFunc(true);

                                    if (!editOrNew) {
                                      await addTask(
                                        type: allAppProvidersProvider
                                            .selectedType,
                                        name: _taskNameController.text.trim(),
                                        date: allAppProvidersProvider.dateText,
                                        des: _descriptionController.text.trim(),
                                        notify:
                                            _notificationController.text.trim(),
                                        time: allAppProvidersProvider.timeText,
                                      );
                                      await updateUserDetails(
                                        loadingProvider:
                                            allAppProvidersProvider,
                                        updateTaskCount: taskCount,
                                        taskType: allAppProvidersProvider
                                            .selectedType,
                                      );
                                      allAppProvidersProvider
                                          .newTaskUploadLoadingFunc(false);
                                      await rewardedAd?.show(
                                        onUserEarnedReward: ((ad, point) async {
                                          await updatePoints(
                                            points: point.amount.toInt(),
                                          );
                                          print(
                                              "Point type : ${point.type}\nPoint amount : ${point.amount.toInt()}");
                                        }),
                                      );
                                      rewardedAd?.fullScreenContentCallback =
                                          FullScreenContentCallback(
                                        onAdClicked: ((ad) {}),
                                        onAdDismissedFullScreenContent: ((ad) {
                                          print("ad dismissed");
                                        }),
                                        onAdFailedToShowFullScreenContent:
                                            ((ad, err) {
                                          ad.dispose();
                                          print("ad error $err");
                                        }),
                                        onAdImpression: ((ad) {}),
                                        onAdShowedFullScreenContent: ((ad) {
                                          print("ad shown ${ad.responseInfo}");
                                        }),
                                        onAdWillDismissFullScreenContent:
                                            ((ad) {}),
                                      );
                                    } else if (widget.userEmail != null &&
                                        widget.taskDoc != null) {
                                      DocumentSnapshot taskDoc =
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(widget.userEmail)
                                              .collection("tasks")
                                              .doc(widget.taskDoc)
                                              .get();
                                      final taskDocRefUpdate = FirebaseFirestore
                                          .instance
                                          .collection("users")
                                          .doc(widget.userEmail)
                                          .collection("tasks")
                                          .doc(widget.taskDoc);

                                      DocumentSnapshot userDoc =
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(widget.userEmail)
                                              .get();

                                      final userDocRefUpdate = FirebaseFirestore
                                          .instance
                                          .collection("users")
                                          .doc(widget.userEmail);

                                      if (taskDoc[Keys.taskStatus] !=
                                          "Pending") {
                                        if (taskDoc[Keys.taskStatus] ==
                                            "Deleted") {
                                          userDocRefUpdate.update(
                                            {
                                              Keys.taskDelete:
                                                  userDoc[Keys.taskDelete] - 1,
                                            },
                                          );

                                          if (taskDoc[Keys.taskType] ==
                                              "Business") {
                                            userDocRefUpdate.update(
                                              {
                                                Keys.taskBusiness:
                                                    userDoc[Keys.taskBusiness] +
                                                        1,
                                              },
                                            );
                                          }
                                          if (taskDoc[Keys.taskType] ==
                                              "Personal") {
                                            userDocRefUpdate.update(
                                              {
                                                Keys.taskPersonal:
                                                    userDoc[Keys.taskPersonal] +
                                                        1,
                                              },
                                            );
                                          }
                                        }
                                        if (taskDoc[Keys.taskStatus] ==
                                            "Completed") {
                                          userDocRefUpdate.update({
                                            Keys.taskDone:
                                                userDoc[Keys.taskDone] - 1,
                                          });
                                        }
                                        userDocRefUpdate.update({
                                          Keys.taskPending:
                                              userDoc[Keys.taskPending] + 1,
                                        });
                                      }

                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskDate:
                                              allAppProvidersProvider.dateText,
                                        },
                                      );
                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskTime:
                                              allAppProvidersProvider.timeText,
                                        },
                                      );
                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskDes: _descriptionController
                                              .text
                                              .trim(),
                                        },
                                      );

                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskName:
                                              _taskNameController.text.trim(),
                                        },
                                      );

                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskNotification:
                                              _notificationController.text
                                                  .trim(),
                                        },
                                      );

                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskType: allAppProvidersProvider
                                              .selectedType,
                                        },
                                      );

                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskStatus: "Pending",
                                        },
                                      );

                                      await rewardedAd?.show(
                                        onUserEarnedReward: ((ad, point) {}),
                                      );
                                      rewardedAd?.fullScreenContentCallback =
                                          FullScreenContentCallback(
                                        onAdClicked: ((ad) {}),
                                        onAdDismissedFullScreenContent:
                                            ((ad) async {
                                          print("ad dismissed");
                                        }),
                                        onAdFailedToShowFullScreenContent:
                                            ((ad, err) {
                                          ad.dispose();
                                          print("ad error $err");
                                        }),
                                        onAdImpression: ((ad) {}),
                                        onAdShowedFullScreenContent: ((ad) {
                                          print("ad shown ${ad.responseInfo}");
                                        }),
                                        onAdWillDismissFullScreenContent:
                                            ((ad) {}),
                                      );

                                      await NotificationServices()
                                          .cancelTaskScheduledNotification(
                                        id: taskDoc[Keys.notificationID],
                                      );

                                      await NotificationServices()
                                          .createScheduledTaskNotification(
                                            id: taskDoc[Keys.notificationID],
                                            title: _notificationController.text
                                                .trim(),
                                            body:
                                                "${_taskNameController.text.trim()}\n${_descriptionController.text.trim()}",
                                            payload:
                                                scheduleDateTIme.toString(),
                                            dateTime: scheduleDateTIme,
                                          )
                                          .whenComplete(
                                            () => AwesomeDialog(
                                              context: allAppProvidersContext,
                                              dialogType: DialogType.success,
                                              title: "Hurray",
                                              desc:
                                                  "Your goal is successfully updated",
                                            ).show(),
                                          );
                                    }

                                    allAppProvidersProvider
                                        .newTaskUploadLoadingFunc(false);

                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(allAppProvidersContext)
                                        .showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message:
                                            "Looks like you didn't fill all the fields!",
                                        context: allAppProvidersContext,
                                      ),
                                    );
                                  }
                                }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 30,
                              horizontal: 20,
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.7,
                              height: 50,
                              // margin: EdgeInsets.symmetric(
                              //   vertical: 30,
                              //   horizontal: 20,
                              // ),

                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.blackLow.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                  ),
                                ],
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: (allAppProvidersProvider
                                        .newTaskUploadLoading)
                                    ? Center(
                                        child: Lottie.asset(
                                          "assets/loading-animation.json",
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          height: 50,
                                        ),
                                      )
                                    : const Text(
                                        "ADD YOUR TASK",
                                        style: TextStyle(
                                          color: AppColors.backgroundColour,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
