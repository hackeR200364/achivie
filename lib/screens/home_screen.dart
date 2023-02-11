import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:task_app/notification_services.dart';
import 'package:task_app/providers/app_providers.dart';
import 'package:task_app/providers/user_details_providers.dart';
import 'package:task_app/screens/new_task_screen.dart';
import 'package:task_app/shared_preferences.dart';
import 'package:task_app/styles.dart';

import '../providers/task_details_provider.dart';

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

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();

    tabController = TabController(
      length: 4,
      vsync: this,
    );

    getEmail();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void getEmail() async {
    email = await StorageServices.getUserEmail();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    // final provider = Provider.of<AllAppProviders>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // backgroundColor: AppColors.backgroundColour,
        floatingActionButton: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.backgroundColour,
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
        body: SafeArea(
          child: SingleChildScrollView(
            physics: AppColors.scrollPhysics,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  // padding: EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.9,

                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          "assets/bg.png",
                        )),
                    // color: AppColors.backgroundColour,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          top: MediaQuery.of(context).size.height / 10,
                          bottom: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<UserDetailsProvider>(
                                builder: (userContext, userProvider, child) {
                              Future.delayed(Duration.zero, () {
                                userProvider.userNameFunc();
                              });

                              String newUserName = userProvider.userName!
                                  .replaceAll(RegExp('\\s+'), '\n');
                              return Text(
                                newUserName,
                                softWrap: true,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2,
                                ),
                              );
                            }),
                            Text(
                              "${DateFormat.MMMM().format(date)[0]}${DateFormat.MMMM().format(date)[1]}${DateFormat.MMMM().format(date)[2]} ${date.day.toString()}, ${date.year}",
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.7),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          right: 10,
                          top: 30,
                          bottom: 20,
                        ),
                        width: MediaQuery.of(context).size.width / 2.5,
                        color: AppColors.blackLow.withOpacity(0.4),
                        child: GridView(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          children: [
                            Consumer<TaskDetailsProvider>(
                              builder: (taskDoneContext, taskDoneProvider,
                                  taskDoneChild) {
                                taskDoneProvider.taskDoneFunc();
                                return tasksBrief(
                                  value: taskDoneProvider.taskDone.toString(),
                                  head: "Done",
                                );
                              },
                            ),
                            Consumer<TaskDetailsProvider>(
                              builder: (taskPersonalContext,
                                  taskPersonalProvider, taskPersonalChild) {
                                taskPersonalProvider.taskPersonalFunc();
                                return tasksBrief(
                                  value: taskPersonalProvider.taskPersonal
                                      .toString(),
                                  head: "Personal",
                                );
                              },
                            ),
                            Consumer<TaskDetailsProvider>(
                              builder: (taskPendingContext, taskPendingProvider,
                                  taskPendingChild) {
                                taskPendingProvider.taskPendingFunc();
                                return tasksBrief(
                                  value: taskPendingProvider.taskPending
                                      .toString(),
                                  head: "Pending",
                                );
                              },
                            ),
                            Consumer<TaskDetailsProvider>(
                              builder: (taskBusinessContext,
                                  taskBusinessProvider, taskBusinessChild) {
                                taskBusinessProvider.taskBusinessFunc();
                                return tasksBrief(
                                  value: taskBusinessProvider.taskBusiness
                                      .toString(),
                                  head: "Business",
                                );
                              },
                            ),
                            Consumer<TaskDetailsProvider>(
                              builder: (taskDeleteContext, taskDeleteProvider,
                                  taskDeleteChild) {
                                taskDeleteProvider.taskDeleteFunc();
                                return tasksBrief(
                                  value:
                                      taskDeleteProvider.taskDelete.toString(),
                                  head: "Deleted",
                                );
                              },
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Consumer<TaskDetailsProvider>(
                                builder: (taskDoneContext, taskDoneProvider,
                                    taskDoneChild) {
                                  taskDoneProvider.taskDoneFunc();
                                  taskDoneProvider.taskCountFunc();

                                  if (taskDoneProvider.taskCount != 0) {
                                    int newTaskCount =
                                        (taskDoneProvider.taskDelete <
                                                taskDoneProvider.taskCount)
                                            ? (taskDoneProvider.taskCount -
                                                taskDoneProvider.taskDelete)
                                            : (taskDoneProvider.taskDelete -
                                                taskDoneProvider.taskCount);

                                    if (newTaskCount != 0) {
                                      percent = (taskDoneProvider.taskDone /
                                          newTaskCount);
                                      newPercent = (percent * 100).round();
                                    } else {
                                      percent = 0;
                                    }
                                  } else {
                                    percent = 0;
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CircularPercentIndicator(
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        animation: true,
                                        percent: percent,
                                        radius: 13,
                                        lineWidth: 3,
                                        progressColor: (newPercent <= 25)
                                            ? AppColors.red
                                            : ((newPercent > 25) &&
                                                    (newPercent <= 50))
                                                ? AppColors.orange
                                                : ((newPercent > 50) &&
                                                        (newPercent <= 75))
                                                    ? AppColors.yellow
                                                    : AppColors.lightGreen,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "$newPercent% done",
                                        style: TextStyle(
                                          color:
                                              AppColors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 3,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    AppColors.sky!,
                    AppColors.backgroundColour,
                    AppColors.white,
                  ])),
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
                    builder: (AllAppProvidersCtx, AllAppProvidersProvider,
                        AllAppProvidersChild) {
                      return DropdownButton<String>(
                        hint: Text(AllAppProvidersProvider.selectedType),
                        items: taskType.map(
                          (String task) {
                            return DropdownMenuItem<String>(
                              value: task,
                              child: Text(task),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          AllAppProvidersProvider.selectedTypeFunc(value!);
                          // print(AllAppProvidersProvider.selectedType);
                        },
                      );
                    },
                  ),
                ),
                TabBar(
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
                    TabBarContainer(
                      label: "INBOX",
                    ),
                    TabBarContainer(
                      label: "DONE",
                    ),
                    TabBarContainer(
                      label: "PENDING",
                    ),
                    TabBarContainer(
                      label: "DELETED",
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2.1,
                  width: MediaQuery.of(context).size.width,
                  child: Consumer<AllAppProviders>(
                    builder: (AllAppProvidersCtx, AllAppProvidersProviders,
                        AllAppProvidersChild) {
                      return TabBarView(
                        controller: tabController,
                        children: [
                          bottomTiles(
                            type: AllAppProvidersProviders.selectedType,
                            status: inboxStatus,
                            firestoreEmail: email,
                          ),
                          bottomTiles(
                            type: AllAppProvidersProviders.selectedType,
                            status: completedStatus,
                            firestoreEmail: email,
                          ),
                          bottomTiles(
                            type: AllAppProvidersProviders.selectedType,
                            status: pendingStatus,
                            firestoreEmail: email,
                          ),
                          bottomTiles(
                            type: AllAppProvidersProviders.selectedType,
                            status: Keys.deleteStatus,
                            firestoreEmail: email,
                          ),
                        ],
                      );
                    },
                  ),
                )
                // bottomTiles(heading: "COMPLETED", value: "10"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container TabBarContainer({
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.backgroundColour,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
      ),
    );
  }

  void deleteTasks({
    required String taskDocID,
    required String status,
    required String firestoreEmail,
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

    if (status == "Pending") {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(firestoreEmail)
          .update(
        {
          Keys.taskPending: userDoc[Keys.taskPending] - 1,
        },
      );

      if (taskDoc[Keys.taskType] == "Business") {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(firestoreEmail)
            .update(
          {
            Keys.taskBusiness: userDoc[Keys.taskBusiness] - 1,
          },
        );
      } else if (taskDoc[Keys.taskType] == "Personal") {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(firestoreEmail)
            .update(
          {
            Keys.taskPersonal: userDoc[Keys.taskPersonal] - 1,
          },
        );
      }
    } else if (status == "Completed") {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(firestoreEmail)
          .update(
        {
          Keys.taskDone: userDoc[Keys.taskDone] - 1,
        },
      );

      if (taskDoc[Keys.taskType] == "Business") {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(firestoreEmail)
            .update(
          {
            Keys.taskBusiness: userDoc[Keys.taskBusiness] - 1,
          },
        );
      } else if (taskDoc[Keys.taskType] == "Personal") {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(firestoreEmail)
            .update(
          {
            Keys.taskPersonal: userDoc[Keys.taskPersonal] - 1,
          },
        );
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(firestoreEmail)
          .update(
        {
          Keys.taskDelete: userDoc[Keys.taskDelete] - 1,
        },
      );
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID)
        .update(
      {
        Keys.taskStatus: Keys.deleteStatus,
      },
    );

    await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .update(
      {
        Keys.taskDelete: userDoc[Keys.taskDelete] + 1,
      },
    );
  }

  void undoTasks({
    required String taskDocID,
    required String status,
    required String firestoreEmail,
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

    await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .update(
      {
        Keys.taskPending: userDoc[Keys.taskPending] + 1,
      },
    );
    await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .update(
      {
        Keys.taskDelete: userDoc[Keys.taskDelete] - 1,
      },
    );

    if (taskDoc[Keys.taskType] == "Business") {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(firestoreEmail)
          .update(
        {
          Keys.taskBusiness: userDoc[Keys.taskBusiness] + 1,
        },
      );
    } else if (taskDoc[Keys.taskType] == "Personal") {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(firestoreEmail)
          .update(
        {
          Keys.taskPersonal: userDoc[Keys.taskPersonal] + 1,
        },
      );
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID)
        .update(
      {
        Keys.taskStatus: "Pending",
      },
    );
  }

  void updateTasks({
    required String taskDocID,
    required String status,
    required String firestoreEmail,
  }) async {
    final taskDocUpdate = FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID);

    DocumentSnapshot taskDocRef = await taskDocUpdate.get();

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

    DateTime date = DateTime.now();

    if (status == "Pending") {
      taskDocUpdate.update(
        {
          Keys.taskStatus: "Completed",
        },
      );
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(firestoreEmail)
          .get();

      FirebaseFirestore.instance.collection("users").doc(firestoreEmail).update(
        {
          Keys.taskDone: userDoc[Keys.taskDone] + 1,
        },
      );
      FirebaseFirestore.instance.collection("users").doc(firestoreEmail).update(
        {
          Keys.taskPending: userDoc[Keys.taskPending] - 1,
        },
      );

      if (taskSavedDate.difference(date).inMinutes > 0) {
        NotificationServices().cancelScheduledNotification(
          id: taskDocRef[Keys.notificationID],
        );
      }
    } else if (status == "Completed") {
      FirebaseFirestore.instance
          .collection("users")
          .doc(firestoreEmail)
          .collection("tasks")
          .doc(taskDocID)
          .update(
        {
          Keys.taskStatus: "Pending",
        },
      );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(firestoreEmail)
          .get();

      FirebaseFirestore.instance.collection("users").doc(firestoreEmail).update(
        {
          Keys.taskPending: userDoc[Keys.taskPending] + 1,
        },
      );
      FirebaseFirestore.instance.collection("users").doc(firestoreEmail).update(
        {
          Keys.taskDone: userDoc[Keys.taskDone] - 1,
        },
      );

      if (taskSavedDate.difference(date).inMinutes > 0) {
        NotificationServices().scheduleNotification(
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
        builder: (context, snapshot) {
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
            return const Center(
              child: Text("Not Tasks"),
            );
          }

          print(snapshot.data!.docs.length);

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
                    return Column(
                      children: [
                        FocusedMenuHolder(
                          onPressed: (() {}),
                          openWithTap: true,
                          menuItems: [
                            if ((snapshot.data!.docs[listIndex]
                                    [Keys.taskStatus] !=
                                "Deleted"))
                              FocusedMenuItem(
                                title: (snapshot.data!.docs[listIndex]
                                            [Keys.taskStatus] ==
                                        "Pending")
                                    ? const Text("Done")
                                    : const Text("Un Done"),
                                trailingIcon: (snapshot.data!.docs[listIndex]
                                            [Keys.taskStatus] ==
                                        "Pending")
                                    ? Icon(
                                        Icons.done,
                                        color: AppColors.green,
                                        size: 20,
                                      )
                                    : Icon(
                                        Icons.cancel_outlined,
                                        color: AppColors.red,
                                        size: 20,
                                      ),
                                onPressed: (() {
                                  String taskDocID = snapshot
                                      .data!.docs[listIndex].reference.id;

                                  updateTasks(
                                    taskDocID: taskDocID,
                                    status: snapshot.data!.docs[listIndex]
                                        [Keys.taskStatus],
                                    firestoreEmail: firestoreEmail,
                                  );
                                }),
                              ),
                            if ((snapshot.data!.docs[listIndex]
                                    [Keys.taskStatus] !=
                                "Deleted"))
                              FocusedMenuItem(
                                title: const Text("Edit"),
                                onPressed: (() {
                                  String taskDocID = snapshot
                                      .data!.docs[listIndex].reference.id;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (nextPageContext) =>
                                          NewTaskScreen(
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
                              ),
                            FocusedMenuItem(
                              title: (snapshot.data!.docs[listIndex]
                                          [Keys.taskStatus] !=
                                      Keys.deleteStatus)
                                  ? Text("Delete")
                                  : Text("Undo"),
                              onPressed: (() {
                                String taskDocID =
                                    snapshot.data!.docs[listIndex].reference.id;

                                if ((snapshot.data!.docs[listIndex]
                                        [Keys.taskStatus] !=
                                    Keys.deleteStatus)) {
                                  deleteTasks(
                                    taskDocID: taskDocID,
                                    status: snapshot.data!.docs[listIndex]
                                        [Keys.taskStatus],
                                    firestoreEmail: firestoreEmail,
                                  );
                                }

                                if ((snapshot.data!.docs[listIndex]
                                        [Keys.taskStatus] ==
                                    Keys.deleteStatus)) {
                                  undoTasks(
                                    taskDocID: taskDocID,
                                    status: snapshot.data!.docs[listIndex]
                                        [Keys.taskStatus],
                                    firestoreEmail: firestoreEmail,
                                  );
                                }
                              }),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
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
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.grey,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.work,
                                        color: AppColors.backgroundColour,
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
                                            style: const TextStyle(
                                              color: AppColors.grey,
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
                                      style: const TextStyle(
                                        color: AppColors.grey,
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
                                                  : AppColors.green,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (snapshot.data!.docs[
                                                                  listIndex][
                                                              Keys.taskStatus] ==
                                                          "Pending")
                                                      ? AppColors.red!
                                                      : AppColors.green!,
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
                                          SizedBox(
                                            width: 10,
                                          ),
                                        if ((snapshot.data!.docs[listIndex]
                                                [Keys.taskStatus] ==
                                            "Deleted"))
                                          Container(
                                            margin: EdgeInsets.all(5),
                                            height: 4,
                                            width: 4,
                                            decoration: BoxDecoration(
                                              color: AppColors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        Text(
                                          snapshot.data!.docs[listIndex]
                                              [Keys.taskType],
                                          style: const TextStyle(
                                            color: AppColors.grey,
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
                      color: AppColors.grey.withOpacity(0.3),
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

  Column tasksBrief({
    required String value,
    required String head,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
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
    );
  }
}
