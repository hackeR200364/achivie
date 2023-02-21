import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:task_app/notification_services.dart';
import 'package:task_app/providers/auth_services.dart';
import 'package:task_app/screens/new_task_screen.dart';
import 'package:task_app/shared_preferences.dart';
import 'package:task_app/styles.dart';

import '../providers/app_providers.dart';
import '../providers/task_details_provider.dart';
import '../providers/user_details_providers.dart';

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
  List<String> taskType = ["Business", "Personal"];
  String email = 'email';
  String inboxStatus = "INBOX",
      completedStatus = "Completed",
      pendingStatus = "Pending",
      deleteStatus = "Deleted";
  BannerAd? bannerAd;

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();

    tabController = TabController(
      length: 4,
      vsync: this,
    );

    getEmail();
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      listener: BannerAdListener(
        onAdLoaded: ((ad) {
          print("Banner ad loaded ${ad.adUnitId}");
        }),
      ),
      request: AdRequest(),
    );
    bannerAd!.load();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void getEmail() async {
    email = await StorageServices.getUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.mainColor,
        appBar: AppBar(
          leading: Consumer<UserDetailsProvider>(
            builder:
                (_, userDetailsProviderProvider, userDetailsProviderChild) {
              Future.delayed(
                Duration.zero,
                (() {
                  userDetailsProviderProvider.userProfileImageFunc();
                }),
              );
              return Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 5,
                ),
                child: (userDetailsProviderProvider.userProfileImage != null)
                    ? CircleAvatar(
                        minRadius: 20,
                        maxRadius: 30,
                        backgroundImage: CachedNetworkImageProvider(
                          userDetailsProviderProvider.userProfileImage!,
                        ),
                      )
                    : CircularProgressIndicator(
                        color: AppColors.white,
                      ),
              );
            },
          ),
          title: Consumer<UserDetailsProvider>(
            builder:
                (_, userDetailsProviderProvider, userDetailsProviderChild) {
              Future.delayed(
                Duration.zero,
                (() {
                  userDetailsProviderProvider.userNameFunc();
                }),
              );
              return Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userDetailsProviderProvider.userName!,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      "${DateFormat.MMMM().format(date)[0]}${DateFormat.MMMM().format(date)[1]}${DateFormat.MMMM().format(date)[2]} ${date.day.toString()}, ${date.year}",
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          actions: [
            Consumer<GoogleSignInProvider>(builder:
                (googleSignInContext, googleSignInProvider, googleSignInChild) {
              return Consumer<AllAppProviders>(
                  builder: (allAppProviderContext, allAppProvider, _) {
                return IconButton(
                  onPressed: (() async {
                    allAppProvider.isLoadingFunc(false);
                    const CircularProgressIndicator(
                      color: AppColors.backgroundColour,
                    );
                    await googleSignInProvider.logOut();
                    await NotificationServices().cancelTasksNotification();

                    SystemNavigator.pop();
                  }),
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.white,
                    size: 25,
                  ),
                );
              });
            }),
          ],
          elevation: 0,
          backgroundColor: AppColors.backgroundColour,
        ),
        floatingActionButton: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.floatingButton,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.add,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewTaskScreen(),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: bannerAd!.size.height.toDouble(),
          width: MediaQuery.of(context).size.width,
          child: AdWidget(
            ad: bannerAd!,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: AppColors.scrollPhysics,
            child: ConnectivityWidget(
              offlineBanner: Container(
                height: 25,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundColour,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Please check your connection",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              builder: (connectivityContext, isConnect) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 20,
                        bottom: MediaQuery.of(context).size.height / 30,
                        left: 15,
                        right: 15,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3.5,
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundColour,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                      child: Consumer<TaskDetailsProvider>(builder:
                          (taskDetailsContext, taskDetailsProvider,
                              taskDetailChild) {
                        taskDetailsProvider.taskCountFunc();
                        taskDetailsProvider.taskDoneFunc();
                        taskDetailsProvider.taskDeleteFunc();
                        taskDetailsProvider.taskPendingFunc();
                        taskDetailsProvider.taskBusinessFunc();
                        taskDetailsProvider.taskPersonalFunc();
                        return AspectRatio(
                          aspectRatio: 2,
                          child: _BarChart(
                            done: taskDetailsProvider.taskDone,
                            deleted: taskDetailsProvider.taskDelete,
                            personal: taskDetailsProvider.taskPersonal,
                            pending: taskDetailsProvider.taskPending,
                            business: taskDetailsProvider.taskBusiness,
                            count: taskDetailsProvider.taskCount,
                          ),
                        );
                      }),
                    ),

                    Container(
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.only(left: 10),
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
                          return DropdownButton<String>(
                            dropdownColor: AppColors.backgroundColour,
                            hint: Text(
                              allAppProvidersProvider.selectedType,
                              style: const TextStyle(
                                color: AppColors.white,
                              ),
                            ),
                            items: taskType.map(
                              (String task) {
                                return DropdownMenuItem<String>(
                                  value: task,
                                  child: Text(
                                    task,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              allAppProvidersProvider.selectedTypeFunc(value!);
                              // print(AllAppProvidersProvider.selectedType);
                            },
                          );
                        },
                      ),
                    ),
                    TabBar(
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
                      tabs: [
                        tabBarContainer(
                          label: "PENDING",
                        ),
                        tabBarContainer(
                          label: "COMPLETED",
                        ),
                        tabBarContainer(
                          label: "DELETED",
                        ),
                        tabBarContainer(
                          label: "INBOX",
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 2.1,
                      width: MediaQuery.of(context).size.width,
                      child: Consumer<AllAppProviders>(
                        builder: (allAppProvidersCtx, allAppProvidersProviders,
                            allAppProvidersChild) {
                          return TabBarView(
                            physics: AppColors.scrollPhysics,
                            controller: tabController,
                            children: [
                              bottomTiles(
                                type: allAppProvidersProviders.selectedType,
                                status: pendingStatus,
                                firestoreEmail: email,
                              ),
                              bottomTiles(
                                type: allAppProvidersProviders.selectedType,
                                status: completedStatus,
                                firestoreEmail: email,
                              ),
                              bottomTiles(
                                type: allAppProvidersProviders.selectedType,
                                status: Keys.deleteStatus,
                                firestoreEmail: email,
                              ),
                              bottomTiles(
                                type: allAppProvidersProviders.selectedType,
                                status: inboxStatus,
                                firestoreEmail: email,
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // bottomTiles(heading: "COMPLETED", value: "10"),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Container tabBarContainer({
    required String label,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width / 5,
      height: 25,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.backgroundColour,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(
          label,
        ),
      ),
    );
  }

  void deleteTasks({
    required String taskDocID,
    required String status,
    required String firestoreEmail,
    required int taskSavedYear,
    required int taskSavedDay,
    required int taskSavedHour,
    required int taskSavedMonth,
    required int taskSavedMinute,
  }) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .get();
    DocumentSnapshot taskDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID)
        .get();

    final userDocUpdate =
        FirebaseFirestore.instance.collection("users").doc(firestoreEmail);

    final taskDocUpdate = FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID);

    DateTime taskSavedDate = DateTime(
      taskSavedYear,
      taskSavedMonth,
      taskSavedDay,
      taskSavedHour,
      taskSavedMinute,
    );

    DateTime date = DateTime.now();

    if (status == "Pending") {
      userDocUpdate.update(
        {
          Keys.taskPending: userDoc[Keys.taskPending] - 1,
        },
      );

      if (taskDoc[Keys.taskType] == "Business") {
        userDocUpdate.update(
          {
            Keys.taskBusiness: userDoc[Keys.taskBusiness] - 1,
          },
        );
      } else if (taskDoc[Keys.taskType] == "Personal") {
        userDocUpdate.update(
          {
            Keys.taskPersonal: userDoc[Keys.taskPersonal] - 1,
          },
        );
      }
    } else if (status == "Completed") {
      userDocUpdate.update(
        {
          Keys.taskDone: userDoc[Keys.taskDone] - 1,
        },
      );

      if (taskDoc[Keys.taskType] == "Business") {
        userDocUpdate.update(
          {
            Keys.taskBusiness: userDoc[Keys.taskBusiness] - 1,
          },
        );
      } else if (taskDoc[Keys.taskType] == "Personal") {
        userDocUpdate.update(
          {
            Keys.taskPersonal: userDoc[Keys.taskPersonal] - 1,
          },
        );
      }

      userDocUpdate.update(
        {
          Keys.taskDelete: userDoc[Keys.taskDelete] - 1,
        },
      );
    }

    taskDocUpdate.update(
      {
        Keys.taskStatus: Keys.deleteStatus,
      },
    );

    userDocUpdate.update(
      {
        Keys.taskDelete: userDoc[Keys.taskDelete] + 1,
      },
    );

    if (taskSavedDate.difference(date).inMinutes > 0) {
      NotificationServices().cancelTaskScheduledNotification(
        id: taskDoc[Keys.notificationID],
      );
    }
  }

  void undoTasks({
    required String taskDocID,
    required String status,
    required String firestoreEmail,
    required int taskSavedYear,
    required int taskSavedDay,
    required int taskSavedHour,
    required int taskSavedMonth,
    required int taskSavedMinute,
  }) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .get();
    DocumentSnapshot taskDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID)
        .get();

    DateTime taskSavedDate = DateTime(
      taskSavedYear,
      taskSavedMonth,
      taskSavedDay,
      taskSavedHour,
      taskSavedMinute,
    );

    DateTime date = DateTime.now();

    final userDocUpdate =
        FirebaseFirestore.instance.collection("users").doc(firestoreEmail);

    final taskDocUpdate = FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID);

    userDocUpdate.update(
      {
        Keys.taskPending: userDoc[Keys.taskPending] + 1,
      },
    );
    userDocUpdate.update(
      {
        Keys.taskDelete: userDoc[Keys.taskDelete] - 1,
      },
    );

    if (taskDoc[Keys.taskType] == "Business") {
      userDocUpdate.update(
        {
          Keys.taskBusiness: userDoc[Keys.taskBusiness] + 1,
        },
      );
    } else if (taskDoc[Keys.taskType] == "Personal") {
      userDocUpdate.update(
        {
          Keys.taskPersonal: userDoc[Keys.taskPersonal] + 1,
        },
      );
    }

    taskDocUpdate.update(
      {
        Keys.taskStatus: "Pending",
      },
    );

    if (taskSavedDate.difference(date).inMinutes > 0) {
      NotificationServices().createScheduledTaskNotification(
        id: taskDoc[Keys.notificationID],
        title: taskDoc[Keys.taskNotification],
        body: "${taskDoc[Keys.taskName]}\n${taskDoc[Keys.taskDes]}",
        payload: taskDoc[Keys.taskDes],
        dateTime: taskSavedDate,
      );
    }
  }

  void updateTasks({
    required String taskDocID,
    required String status,
    required String firestoreEmail,
    required int taskSavedYear,
    required int taskSavedDay,
    required int taskSavedHour,
    required int taskSavedMonth,
    required int taskSavedMinute,
  }) async {
    final taskDocUpdate = FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID);

    DocumentSnapshot taskDocRef = await taskDocUpdate.get();

    DateTime taskSavedDate = DateTime(
      taskSavedYear,
      taskSavedMonth,
      taskSavedDay,
      taskSavedHour,
      taskSavedMinute,
    );

    DateTime date = DateTime.now();

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .get();

    final userDocUpdate =
        FirebaseFirestore.instance.collection("users").doc(firestoreEmail);

    if (status == "Pending") {
      taskDocUpdate.update(
        {
          Keys.taskStatus: "Completed",
        },
      );

      userDocUpdate.update(
        {
          Keys.taskDone: userDoc[Keys.taskDone] + 1,
        },
      );
      userDocUpdate.update(
        {
          Keys.taskPending: userDoc[Keys.taskPending] - 1,
        },
      );

      if (taskSavedDate.difference(date).inMinutes > 0) {
        NotificationServices().cancelTaskScheduledNotification(
          id: taskDocRef[Keys.notificationID],
        );
      }
    } else if (status == "Completed") {
      taskDocUpdate.update(
        {
          Keys.taskStatus: "Pending",
        },
      );

      userDocUpdate.update(
        {
          Keys.taskPending: userDoc[Keys.taskPending] + 1,
        },
      );
      userDocUpdate.update(
        {
          Keys.taskDone: userDoc[Keys.taskDone] - 1,
        },
      );

      if (taskSavedDate.difference(date).inMinutes > 0) {
        NotificationServices().createScheduledTaskNotification(
          title: taskDocRef[Keys.taskNotification],
          body: "${taskDocRef[Keys.taskName]}\n${taskDocRef[Keys.taskDes]}",
          id: taskDocRef[Keys.notificationID],
          payload: taskDocRef[Keys.taskName],
          dateTime: taskSavedDate,
        );
      }
    }
  }

  Padding bottomTiles({
    required String type,
    required String status,
    required String firestoreEmail,
  }) {
    final firestore = FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .where(Keys.taskType, isEqualTo: type)
        .where(Keys.taskStatus, isEqualTo: status)
        .snapshots();

    final firestoreAll = FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .where(Keys.taskType, isEqualTo: type)
        .snapshots();

    return Padding(
      padding: const EdgeInsets.only(
        right: 10,
        left: 10,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: (status != "INBOX") ? firestore : firestoreAll,
        builder: (streamContext, snapshot) {
          // print(snapshot.data!.docs.length);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.backgroundColour,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("error"),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Lottie.asset("assets/empty_animation.json"),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                // color: AppColors.sky,
                height: MediaQuery.of(context).size.height / 2.3,
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                  physics: AppColors.scrollPhysics,
                  itemCount: snapshot.data!.docs.length,
                  controller: _scrollController,
                  itemBuilder: (listContext, listIndex) {
                    final taskDocRef = snapshot.data!.docs[listIndex];

                    int taskSavedDay = int.parse(
                        "${taskDocRef[Keys.taskDate][0]}${taskDocRef[Keys.taskDate][1]}");
                    int taskSavedMonth = int.parse(
                        "${taskDocRef[Keys.taskDate][3]}${taskDocRef[Keys.taskDate][4]}");
                    int taskSavedYear = int.parse(
                        "${taskDocRef[Keys.taskDate][6]}${taskDocRef[Keys.taskDate][7]}${taskDocRef[Keys.taskDate][8]}${taskDocRef[Keys.taskDate][9]}");
                    int taskSavedHour = int.parse(
                        "${taskDocRef[Keys.taskTime][0]}${taskDocRef[Keys.taskTime][1]}");
                    int taskSavedMinute = int.parse(
                        "${taskDocRef[Keys.taskTime][3]}${taskDocRef[Keys.taskTime][4]}");

                    DateTime taskSavedDate = DateTime(
                      taskSavedYear,
                      taskSavedMonth,
                      taskSavedDay,
                      taskSavedHour,
                      taskSavedMinute,
                    );

                    return Column(
                      children: [
                        FocusedMenuHolder(
                          onPressed: (() {}),
                          menuBoxDecoration: const BoxDecoration(
                            color: AppColors.transparent,
                          ),
                          openWithTap: true,
                          menuItems: [
                            if ((snapshot.data!.docs[listIndex]
                                    [Keys.taskStatus] !=
                                "Deleted"))
                              FocusedMenuItem(
                                title: (snapshot.data!.docs[listIndex]
                                            [Keys.taskStatus] ==
                                        "Pending")
                                    ? const Text(
                                        "Done",
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Un Done",
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                trailingIcon: (snapshot.data!.docs[listIndex]
                                            [Keys.taskStatus] ==
                                        "Pending")
                                    ? Icon(
                                        Icons.done,
                                        color: AppColors.lightGreen,
                                        size: 20,
                                      )
                                    : Icon(
                                        Icons.cancel_outlined,
                                        color: AppColors.red,
                                        size: 20,
                                      ),
                                onPressed: (() async {
                                  String taskDocID = snapshot
                                      .data!.docs[listIndex].reference.id;

                                  if ((snapshot.data!.docs[listIndex]
                                              [Keys.taskStatus] !=
                                          "Pending") &&
                                      (taskSavedDate
                                              .difference(date)
                                              .inMinutes >
                                          0)) {
                                    updateTasks(
                                      taskDocID: taskDocID,
                                      status: snapshot.data!.docs[listIndex]
                                          [Keys.taskStatus],
                                      firestoreEmail: firestoreEmail,
                                      taskSavedDay: taskSavedDay,
                                      taskSavedHour: taskSavedHour,
                                      taskSavedMinute: taskSavedMinute,
                                      taskSavedMonth: taskSavedMonth,
                                      taskSavedYear: taskSavedYear,
                                    );
                                  } else if (snapshot.data!.docs[listIndex]
                                          [Keys.taskStatus] ==
                                      "Pending") {
                                    updateTasks(
                                      taskDocID: taskDocID,
                                      status: snapshot.data!.docs[listIndex]
                                          [Keys.taskStatus],
                                      firestoreEmail: firestoreEmail,
                                      taskSavedDay: taskSavedDay,
                                      taskSavedHour: taskSavedHour,
                                      taskSavedMinute: taskSavedMinute,
                                      taskSavedMonth: taskSavedMonth,
                                      taskSavedYear: taskSavedYear,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(streamContext)
                                        .showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            AppColors.backgroundColour,
                                        content: const Text(
                                          "This event is already outdated, Please",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        action: SnackBarAction(
                                          textColor: AppColors.white,
                                          label: "Edit",
                                          onPressed: (() {
                                            String taskDocID = snapshot.data!
                                                .docs[listIndex].reference.id;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (nextPageContext) =>
                                                    NewTaskScreen(
                                                  taskName: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskName],
                                                  taskDes: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskDes],
                                                  taskNoti: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskNotification],
                                                  taskTime: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskTime],
                                                  taskType: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskType],
                                                  taskDoc: taskDocID,
                                                  userEmail: firestoreEmail,
                                                  taskDate: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskDate],
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    );
                                  }
                                }),
                                backgroundColor: AppColors.backgroundColour,
                              ),
                            FocusedMenuItem(
                              title: const Text(
                                "Edit",
                                style: TextStyle(
                                  color: AppColors.white,
                                ),
                              ),
                              onPressed: (() {
                                String taskDocID =
                                    snapshot.data!.docs[listIndex].reference.id;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (nextPageContext) => NewTaskScreen(
                                      taskName: snapshot.data!.docs[listIndex]
                                          [Keys.taskName],
                                      taskDes: snapshot.data!.docs[listIndex]
                                          [Keys.taskDes],
                                      taskNoti: snapshot.data!.docs[listIndex]
                                          [Keys.taskNotification],
                                      taskTime: snapshot.data!.docs[listIndex]
                                          [Keys.taskTime],
                                      taskType: snapshot.data!.docs[listIndex]
                                          [Keys.taskType],
                                      taskDoc: taskDocID,
                                      userEmail: firestoreEmail,
                                      taskDate: snapshot.data!.docs[listIndex]
                                          [Keys.taskDate],
                                    ),
                                  ),
                                );
                              }),
                              backgroundColor: AppColors.backgroundColour,
                            ),
                            FocusedMenuItem(
                              title: ((snapshot.data!.docs[listIndex]
                                          [Keys.taskStatus] ==
                                      Keys.deleteStatus))
                                  ? const Text(
                                      "Undo",
                                      style: TextStyle(
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Delete",
                                      style: TextStyle(
                                        color: AppColors.white,
                                      ),
                                    ),
                              onPressed: (() {
                                String taskDocID =
                                    snapshot.data!.docs[listIndex].reference.id;

                                if (snapshot.data!.docs[listIndex]
                                        [Keys.taskStatus] !=
                                    Keys.deleteStatus) {
                                  deleteTasks(
                                    taskSavedDay: taskSavedDay,
                                    taskSavedYear: taskSavedYear,
                                    taskSavedMonth: taskSavedMonth,
                                    taskSavedMinute: taskSavedMinute,
                                    taskSavedHour: taskSavedHour,
                                    taskDocID: taskDocID,
                                    status: snapshot.data!.docs[listIndex]
                                        [Keys.taskStatus],
                                    firestoreEmail: firestoreEmail,
                                  );
                                }

                                // (taskSavedDate.difference(date).inMinutes >
                                //     0)

                                if ((snapshot.data!.docs[listIndex]
                                        [Keys.taskStatus] ==
                                    Keys.deleteStatus)) {
                                  if (taskSavedDate.difference(date).inMinutes >
                                      0) {
                                    undoTasks(
                                      taskSavedDay: taskSavedDay,
                                      taskSavedYear: taskSavedYear,
                                      taskSavedMonth: taskSavedMonth,
                                      taskSavedMinute: taskSavedMinute,
                                      taskSavedHour: taskSavedHour,
                                      taskDocID: taskDocID,
                                      status: snapshot.data!.docs[listIndex]
                                          [Keys.taskStatus],
                                      firestoreEmail: firestoreEmail,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(streamContext)
                                        .showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            AppColors.backgroundColour,
                                        content: const Text(
                                          "This event is already outdated, Please",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        action: SnackBarAction(
                                          textColor: AppColors.white,
                                          label: "Edit",
                                          onPressed: (() {
                                            String taskDocID = snapshot.data!
                                                .docs[listIndex].reference.id;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (nextPageContext) =>
                                                    NewTaskScreen(
                                                  taskName: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskName],
                                                  taskDes: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskDes],
                                                  taskNoti: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskNotification],
                                                  taskTime: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskTime],
                                                  taskType: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskType],
                                                  taskDoc: taskDocID,
                                                  userEmail: firestoreEmail,
                                                  taskDate: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskDate],
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }),
                              backgroundColor: AppColors.backgroundColour,
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.backgroundColour,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: (snapshot.data!.docs[listIndex]
                                                  [Keys.taskStatus] ==
                                              "Deleted")
                                          ? Image.asset(
                                              "assets/cancel-task.png",
                                              width: 35,
                                              height: 35,
                                            )
                                          : Icon(
                                              shadows: [
                                                Shadow(
                                                  color: (snapshot.data!.docs[
                                                                  listIndex][
                                                              Keys.taskStatus] ==
                                                          "Pending")
                                                      ? AppColors.red!
                                                      : AppColors.lightGreen!,
                                                  blurRadius: 10,
                                                )
                                              ],
                                              Icons.work_outline,
                                              color: (snapshot.data!
                                                              .docs[listIndex]
                                                          [Keys.taskStatus] ==
                                                      "Pending")
                                                  ? AppColors.red
                                                  : AppColors.lightGreen,
                                              size: 35,
                                            ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: Text(
                                            snapshot.data!.docs[listIndex]
                                                [Keys.taskName],
                                            // overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: Text(
                                            snapshot.data!.docs[listIndex]
                                                [Keys.taskDes],
                                            // overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: AppColors.white
                                                  .withOpacity(0.5),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${snapshot.data!.docs[listIndex][Keys.taskTime]}\n${snapshot.data!.docs[listIndex][Keys.taskDate]}",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        color: AppColors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        if ((snapshot.data!.docs[listIndex]
                                                [Keys.taskStatus] !=
                                            "Deleted"))
                                          Container(
                                            height: 5,
                                            width: 5,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: (snapshot.data!
                                                              .docs[listIndex]
                                                          [Keys.taskStatus] ==
                                                      "Pending")
                                                  ? AppColors.red
                                                  : AppColors.lightGreen,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (snapshot.data!.docs[
                                                                  listIndex][
                                                              Keys.taskStatus] ==
                                                          "Pending")
                                                      ? AppColors.red!
                                                      : AppColors.lightGreen!,
                                                  blurRadius: 5,
                                                  spreadRadius: 3,
                                                )
                                              ],
                                            ),
                                          ),
                                        if ((snapshot.data!.docs[listIndex]
                                                [Keys.taskStatus] ==
                                            "Deleted"))
                                          Text(
                                            snapshot.data!.docs[listIndex]
                                                [Keys.taskStatus],
                                            style: TextStyle(
                                                color: AppColors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        if ((snapshot.data!.docs[listIndex]
                                                [Keys.taskStatus] !=
                                            "Deleted"))
                                          const SizedBox(
                                            width: 10,
                                          ),
                                        if ((snapshot.data!.docs[listIndex]
                                                [Keys.taskStatus] ==
                                            "Deleted"))
                                          Container(
                                            margin: const EdgeInsets.all(5),
                                            height: 4,
                                            width: 4,
                                            decoration: BoxDecoration(
                                              color: AppColors.white
                                                  .withOpacity(0.5),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        Text(
                                          snapshot.data!.docs[listIndex]
                                              [Keys.taskType],
                                          style: TextStyle(
                                            color: AppColors.white
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder:
                      (BuildContext separatorContext, int separatorIndex) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      height: 2,
                      color: AppColors.grey.withOpacity(0.1),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Container tasksBrief({
    required String value,
    required String head,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              head,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  _BarChart({
    required this.done,
    required this.personal,
    required this.pending,
    required this.business,
    required this.deleted,
    required this.count,
  });

  int deleted = 0;
  int done = 0;
  int pending = 0;
  int business = 0;
  int personal = 0;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: buildTitleDate(),
        borderData: borderData,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: done.toDouble(),
                gradient: _barsGradient,
              )
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: deleted.toDouble(),
                gradient: _barsGradient,
              )
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: pending.toDouble(),
                gradient: _barsGradient,
              )
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: business.toDouble(),
                gradient: _barsGradient,
              )
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(
                toY: personal.toDouble(),
                gradient: _barsGradient,
              )
            ],
            showingTooltipIndicators: [0],
          ),
        ],
        gridData: FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: count.toDouble(),
      ),
    );
  }

  buildTitleDate() => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (double val, TitleMeta meta) {
              const textStyle = TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              );
              switch (val.toInt()) {
                case 0:
                  return const Text(
                    "\nDone",
                    style: textStyle,
                  );
                case 1:
                  return const Text(
                    "\nDeleted",
                    style: textStyle,
                  );
                case 2:
                  return const Text(
                    "\nPending",
                    style: textStyle,
                  );
                case 3:
                  return const Text(
                    "\nBusiness",
                    style: textStyle,
                  );
                case 4:
                  return const Text(
                    "\nPersonal",
                    style: textStyle,
                  );
              }
              return const Text("");
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            );
          },
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          AppColors.orange!,
          AppColors.yellow!,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> get barGroups => [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 8,
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
      ];
}
