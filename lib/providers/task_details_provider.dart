import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:task_app/shared_preferences.dart';

class TaskDetailsProvider extends ChangeNotifier {
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  int taskDone = 0;
  void taskDoneFunc() async {
    String email = await StorageServices.getUserEmail();
    // bool isNewUser = await StorageServices.getIsNewUser();

    DocumentSnapshot userDoc = await users.doc(email).get();

    // if (isNewUser) {
    //   users.doc(email).set({Keys.taskDone: taskDone});
    // }
    taskDone = userDoc[Keys.taskDone] ?? 0;
    notifyListeners();
  }

  int taskCount = 0;
  void taskCountFunc() async {
    String email = await StorageServices.getUserEmail();
    bool isNewUser = await StorageServices.getIsNewUser();

    DocumentSnapshot userDoc = await users.doc(email).get();

    // if (isNewUser) {
    //   users.doc(email).set({Keys.taskDone: taskDone});
    // }
    taskCount = userDoc[Keys.taskCount] ?? 0;
    notifyListeners();
  }

  int taskDelete = 0;
  void taskDeleteFunc() async {
    String email = await StorageServices.getUserEmail();
    bool isNewUser = await StorageServices.getIsNewUser();

    DocumentSnapshot userDoc = await users.doc(email).get();

    // if (isNewUser) {
    //   users.doc(email).set({Keys.taskDone: taskDone});
    // }
    taskDelete = userDoc[Keys.taskDelete] ?? 0;
    notifyListeners();
  }

  int taskPending = 0;
  void taskPendingFunc() async {
    String email = await StorageServices.getUserEmail();
    bool isNewUser = await StorageServices.getIsNewUser();

    DocumentSnapshot userDoc = await users.doc(email).get();

    // if (isNewUser) {
    //   users.doc(email).set({Keys.taskPending: taskPending});
    // }
    taskPending = userDoc[Keys.taskPending] ?? 0;
    notifyListeners();
  }

  int taskBusiness = 0;
  void taskBusinessFunc() async {
    String email = await StorageServices.getUserEmail();
    bool isNewUser = await StorageServices.getIsNewUser();

    DocumentSnapshot userDoc = await users.doc(email).get();

    // if (isNewUser) {
    //   users.doc(email).set({Keys.taskBusiness: taskBusiness});
    // }
    taskBusiness = userDoc[Keys.taskBusiness] ?? 0;
    notifyListeners();
  }

  int taskPersonal = 0;
  void taskPersonalFunc() async {
    String email = await StorageServices.getUserEmail();
    bool isNewUser = await StorageServices.getIsNewUser();

    DocumentSnapshot userDoc = await users.doc(email).get();

    // if (isNewUser) {
    //   users.doc(email).set({Keys.taskPersonal: taskPersonal});
    // }
    taskPersonal = userDoc[Keys.taskPersonal] ?? 0;
    notifyListeners();
  }

  int taskCountWithType = 0;
  void taskCountWithTypeFunc(String type) async {
    String email = await StorageServices.getUserEmail();
    bool isNewUser = await StorageServices.getIsNewUser();

    DocumentSnapshot userDoc = await users.doc(email).get();

    String taskType =
        (type == "Personal") ? Keys.taskPersonal : Keys.taskBusiness;
    taskCountWithType = userDoc[taskType] ?? 0;
    notifyListeners();
  }
}
