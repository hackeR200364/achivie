import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_app/notification_services.dart';
import 'package:task_app/shared_preferences.dart';
import 'package:task_app/styles.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../providers/app_providers.dart';

class NewTaskScreen extends StatefulWidget {
  NewTaskScreen({
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

class _NewTaskScreenState extends State<NewTaskScreen> {
  late TextEditingController _taskNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _notificationController;
  DateTime date = DateTime.now();
  DateTime scheduleDateTIme = DateTime.now();
  String taskTime = "", taskDate = "", taskID = "dsds", inputDateTime = "";
  bool taskNameTapped = false, desTapped = false, loading = false;
  String selected = "Personal";
  List<String> taskType = ["Business", "Personal"];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool editOrNew = false;
  int taskCount = 0,
      taskPending = 0,
      taskBusiness = 0,
      taskPersonal = 0,
      taskDone = 0;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    _taskNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _notificationController = TextEditingController();
    taskDetails();
    tz.initializeTimeZones();
    super.initState();
    NotificationServices().init();
    listenNotification();
    // notificationServices.initialiseNotification();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _notificationController.dispose();
    super.dispose();
  }

  void listenNotification() =>
      NotificationServices().onNotifications.stream.listen((event) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewTaskScreen(),
          ),
        );
      });

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
    print(userDoc.exists);

    taskCount = userDoc[Keys.taskCount];
    taskPending = userDoc[Keys.taskPending];
    taskBusiness = userDoc[Keys.taskBusiness];
    taskPersonal = userDoc[Keys.taskPersonal];
    taskID = "TID${(taskCount + 1).toString()}";

    await NotificationServices().scheduleNotification(
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

    // String updateAnotherTaskType =
    //     (taskType == "Business") ? Keys.taskPersonal : Keys.taskBusiness;
    // users.doc(email).update(
    //   {
    //     updateAnotherTaskType: (updateAnotherTaskType == Keys.taskPersonal)
    //         ? taskBusiness
    //         : taskPersonal,
    //   },
    // );

    await users.doc(email).update(
      {
        Keys.taskDone: userDoc[Keys.taskDone],
      },
    ).whenComplete(
      () => AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: "Hurray",
        desc: "Your next goal is stored successfully",
      ).show(),
    );
  }

  void pickDateTime(BuildContext context) async {}

  void taskDetails() {
    if (widget.taskName != null &&
        widget.taskDes != null &&
        widget.taskNoti != null &&
        widget.taskTime != null &&
        widget.taskDate != null) {
      _taskNameController.text = widget.taskName!;
      _descriptionController.text = widget.taskDes!;
      _notificationController.text = widget.taskNoti!;
      int prevHour = int.parse("${widget.taskTime![0]}${widget.taskTime![1]}");
      int prevMinute =
          int.parse("${widget.taskTime![3]}${widget.taskTime![4]}");
      // if (int.parse(DateFormat.H().format(date)) >= prevHour ||
      //     int.parse(DateFormat.m().format(date)) > prevMinute) {
      //   inputDateTime =
      //       "${DateFormat.Hm().format(date.add(Duration(minutes: 5)))} on ${DateFormat("dd/MM/yyyy").format(date)}";
      // }
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
        appBar: AppBar(
          leading: Align(
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: const Text(
            "Add new task",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: AppColors.transparent,
          elevation: 0,
        ),
        backgroundColor: AppColors.backgroundColour,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.grey,
                      ),
                    ),
                    child: const Icon(
                      Icons.work,
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    child: Consumer<AllAppProviders>(
                      builder: (AllAppProvidersContext, AllAppProvidersProvider,
                          AllAppProvidersChild) {
                        return DropdownButton<String>(
                          hint: Text(
                            (widget.taskType != null)
                                ? widget.taskType!
                                : AllAppProvidersProvider.selectedType,
                            style: const TextStyle(
                              color: AppColors.white,
                            ),
                          ),
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
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: TextFormField(
                      controller: _taskNameController,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        color: AppColors.white,
                      ),
                      decoration: InputDecoration(
                        suffixIconColor: AppColors.white,
                        labelText: "Task Name",
                        labelStyle: TextStyle(
                          color: AppColors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      controller: _descriptionController,
                      style: const TextStyle(
                        color: AppColors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: "Description",
                        labelStyle: TextStyle(
                          color: AppColors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  Consumer<AllAppProviders>(
                    builder: (AllAppProvidersContext, AllAppProvidersProvider,
                        AllAppProvidersChild) {
                      return InkWell(
                        onTap: (() async {
                          String initialYear = '';
                          String initialMonth = '';
                          String initialDay = '';
                          String initialHour = '';
                          String initialMinute = '';

                          if (widget.taskDate != null &&
                              widget.taskTime != null) {
                            int dateStringLen = widget.taskDate!.length;
                            initialYear =
                                "${widget.taskDate![dateStringLen - 4]}${widget.taskDate![dateStringLen - 3]}${widget.taskDate![dateStringLen - 2]}${widget.taskDate![dateStringLen - 1]}";
                            initialDay =
                                "${widget.taskDate![0]}${widget.taskDate![1]}";
                            initialMonth =
                                "${widget.taskDate![3]}${widget.taskDate![4]}";

                            initialHour =
                                "${widget.taskTime![0]}${widget.taskTime![1]}";
                            initialMinute =
                                "${widget.taskTime![3]}${widget.taskTime![4]}";
                          }

                          final newDate = await showDatePicker(
                            context: context,
                            initialDate: (widget.taskDate != null)
                                ? DateTime(
                                    int.parse(initialYear),
                                    int.parse(initialMonth),
                                    int.parse(initialDay),
                                  )
                                : date,
                            firstDate: date,
                            lastDate: DateTime(date.year + 2),
                          );

                          final newTime = await showIntervalTimePicker(
                            interval: 15,
                            visibleStep: VisibleStep.fifteenths,
                            context: context,
                            initialTime: (widget.taskTime != null)
                                ? TimeOfDay(
                                    hour: int.parse(initialHour),
                                    minute: int.parse(initialMinute),
                                  )
                                : TimeOfDay(
                                    hour:
                                        (initialMinuteSelection(date.minute) ==
                                                    0 ||
                                                initialMinuteSelection(
                                                        date.minute) ==
                                                    45)
                                            ? date.add(Duration(hours: 1)).hour
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

                          // print(DateFormat.m().format(scheduleDateTIme));

                          // setState(() {
                          //   _dateAndTimeController.text =
                          //       AllAppProvidersProvider.dateText;
                          //   // "${newTime?.hour}:${newTime?.minute} on ${newDate?.day}/${newDate?.month}/${newDate?.year}"
                          // });

                          String formatedTime = DateFormat.Hm().format(
                            DateTime(
                              newDate.year,
                              newDate.month,
                              newDate.day,
                              newTime.hour,
                              newTime.minute,
                            ),
                          );

                          String formatedDate =
                              DateFormat("dd/MM/yyyy").format(newDate);

                          AllAppProvidersProvider.dateTextFunc(formatedDate);
                          AllAppProvidersProvider.timeTextFunc(formatedTime);

                          print(DateFormat.Hm().format(date));

                          if (scheduleDateTIme.difference(date).inSeconds > 0) {
                            inputDateTime =
                                "${AllAppProvidersProvider.timeText} on ${AllAppProvidersProvider.dateText}";
                          } else {
                            ScaffoldMessenger.of(AllAppProvidersContext)
                                .showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.white,
                                content: Text(
                                  "Please select a date of future",
                                  style: TextStyle(
                                    color: AppColors.backgroundColour,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(
                            left: 20,
                            right: 20,
                          ),
                          padding: const EdgeInsets.only(
                            top: 20,
                            bottom: 15,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          child: Text(
                            (inputDateTime.isNotEmpty)
                                ? inputDateTime
                                : "Time & Date",
                            style: TextStyle(
                              color: (inputDateTime.isNotEmpty ||
                                      (widget.taskDate != null &&
                                          widget.taskTime != null))
                                  ? AppColors.white
                                  : AppColors.white.withOpacity(0.6),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                    // child: ,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _notificationController,
                      style: const TextStyle(
                        color: AppColors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: "Notification",
                        labelStyle: TextStyle(
                          color: AppColors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  Consumer<AllAppProviders>(
                    builder: ((AllAppProvidersContext, AllAppProvidersProvider,
                        AllAppProvidersChild) {
                      return GestureDetector(
                        onTap: (AllAppProvidersProvider.newTaskUploadLoading)
                            ? null
                            : (() async {
                                if (_taskNameController.text.isNotEmpty &&
                                    _notificationController.text.isNotEmpty &&
                                    inputDateTime.isNotEmpty &&
                                    _descriptionController.text.isNotEmpty) {
                                  AllAppProvidersProvider
                                      .newTaskUploadLoadingFunc(true);

                                  print(taskCount);

                                  if (!editOrNew) {
                                    await addTask(
                                      type:
                                          AllAppProvidersProvider.selectedType,
                                      name: _taskNameController.text.trim(),
                                      date: AllAppProvidersProvider.dateText,
                                      des: _descriptionController.text.trim(),
                                      notify:
                                          _notificationController.text.trim(),
                                      time: AllAppProvidersProvider.timeText,
                                    );
                                    await updateUserDetails(
                                      updateTaskCount: taskCount,
                                      taskType:
                                          AllAppProvidersProvider.selectedType,
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

                                    if (inputDateTime !=
                                        "${widget.taskTime!} on ${widget.taskDate}") {
                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskDate:
                                              AllAppProvidersProvider.dateText,
                                        },
                                      );
                                    }
                                    if (inputDateTime !=
                                        "${widget.taskTime!} on ${widget.taskDate}") {
                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskTime:
                                              AllAppProvidersProvider.timeText,
                                        },
                                      );
                                    }
                                    if (_descriptionController.text !=
                                        widget.taskDes) {
                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskDes: _descriptionController
                                              .text
                                              .trim(),
                                        },
                                      );
                                    }
                                    if (_taskNameController.text !=
                                        widget.taskName) {
                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskName:
                                              _taskNameController.text.trim(),
                                        },
                                      );
                                    }
                                    if (_notificationController.text !=
                                        widget.taskNoti) {
                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskNotification:
                                              _notificationController.text
                                                  .trim(),
                                        },
                                      );
                                    }
                                    if (AllAppProvidersProvider.selectedType !=
                                        widget.taskType) {
                                      taskDocRefUpdate.update(
                                        {
                                          Keys.taskType: AllAppProvidersProvider
                                              .selectedType,
                                        },
                                      );
                                    }

                                    NotificationServices()
                                        .cancelScheduledNotification(
                                      id: taskDoc[Keys.notificationID],
                                    );

                                    print(scheduleDateTIme);

                                    NotificationServices().scheduleNotification(
                                      id: taskDoc[Keys.notificationID],
                                      title:
                                          _notificationController.text.trim(),
                                      body:
                                          "${_taskNameController.text.trim()}\n${_descriptionController.text.trim()}",
                                      payload: scheduleDateTIme.toString(),
                                      dateTime: scheduleDateTIme,
                                    );
                                  }

                                  print(scheduleDateTIme);

                                  AllAppProvidersProvider
                                      .newTaskUploadLoadingFunc(false);
                                  Navigator.pop(context);
                                } else {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    title: "Uummm...",
                                    desc:
                                        "Looks like you didn't fill all the fields!",
                                  ).show();
                                }
                              }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 30,
                            horizontal: 20,
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 75,
                            // margin: EdgeInsets.symmetric(
                            //   vertical: 30,
                            //   horizontal: 20,
                            // ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                            ),
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
                              child:
                                  (AllAppProvidersProvider.newTaskUploadLoading)
                                      ? const CircularProgressIndicator(
                                          color: AppColors.backgroundColour,
                                        )
                                      : const Text(
                                          "ADD YOUR TASK",
                                          style: TextStyle(
                                              color: AppColors.backgroundColour,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                        ),
                            ),
                          ),
                        ),
                      );
                    }),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
