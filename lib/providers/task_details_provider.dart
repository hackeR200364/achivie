import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class TaskDetailsProvider extends ChangeNotifier {
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  // int taskDone = 0;
  // void taskDoneFunc() async {
  //   // String email = await StorageServices.getUserEmail();
  //   // // bool isNewUser = await StorageServices.getIsNewUser();
  //   //
  //   // DocumentSnapshot userDoc = await users.doc(email).get();
  //   //
  //   // // if (isNewUser) {
  //   // //   users.doc(email).set({Keys.taskDone: taskDone});
  //   // // }
  //   // taskDone = userDoc[Keys.taskDone] ?? 0;
  //
  //   String uid = await StorageServices.getUID();
  //   String token = await StorageServices.getUsrToken();
  //   http.Response response = await http
  //       .get(Uri.parse("${Keys.apiTasksBaseUrl}/taskDone/$uid"), headers: {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   });
  //
  //   Map<String, dynamic> responseJson = jsonDecode(response.body);
  //
  //   if (response.statusCode == 200) {
  //     if (responseJson["success"]) {
  //       taskDone = int.parse(responseJson["taskDone"]);
  //     }
  //   }
  //
  //   notifyListeners();
  // }
  //
  // int taskCount = 0;
  // void taskCountFunc() async {
  //   // String email = await StorageServices.getUserEmail();
  //   //
  //   // DocumentSnapshot userDoc = await users.doc(email).get();
  //   //
  //   // // if (isNewUser) {
  //   // //   users.doc(email).set({Keys.taskDone: taskDone});
  //   // // }
  //   // taskCount = userDoc[Keys.taskCount] ?? 0;
  //
  //   String uid = await StorageServices.getUID();
  //   String token = await StorageServices.getUsrToken();
  //   http.Response response = await http
  //       .get(Uri.parse("${Keys.apiTasksBaseUrl}/taskCount/$uid"), headers: {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   });
  //
  //   Map<String, dynamic> responseJson = jsonDecode(response.body);
  //
  //   if (response.statusCode == 200) {
  //     if (responseJson["success"]) {
  //       taskCount = int.parse(responseJson["taskCount"]);
  //     }
  //   }
  //
  //   notifyListeners();
  // }
  //
  // int taskDelete = 0;
  // void taskDeleteFunc() async {
  //   // String email = await StorageServices.getUserEmail();
  //   //
  //   // DocumentSnapshot userDoc = await users.doc(email).get();
  //   //
  //   // // if (isNewUser) {
  //   // //   users.doc(email).set({Keys.taskDone: taskDone});
  //   // // }
  //   // taskDelete = userDoc[Keys.taskDelete] ?? 0;
  //
  //   String uid = await StorageServices.getUID();
  //   String token = await StorageServices.getUsrToken();
  //   http.Response response = await http
  //       .get(Uri.parse("${Keys.apiTasksBaseUrl}/taskDelete/$uid"), headers: {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   });
  //
  //   Map<String, dynamic> responseJson = jsonDecode(response.body);
  //
  //   if (response.statusCode == 200) {
  //     if (responseJson["success"]) {
  //       taskDelete = int.parse(responseJson["taskDelete"]);
  //     }
  //   }
  //
  //   notifyListeners();
  // }
  //
  // int taskPending = 0;
  // void taskPendingFunc() async {
  //   // String email = await StorageServices.getUserEmail();
  //   //
  //   // DocumentSnapshot userDoc = await users.doc(email).get();
  //   //
  //   // // if (isNewUser) {
  //   // //   users.doc(email).set({Keys.taskPending: taskPending});
  //   // // }
  //   // taskPending = userDoc[Keys.taskPending] ?? 0;
  //
  //   String uid = await StorageServices.getUID();
  //   String token = await StorageServices.getUsrToken();
  //   http.Response response = await http
  //       .get(Uri.parse("${Keys.apiTasksBaseUrl}/taskPending/$uid"), headers: {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   });
  //
  //   Map<String, dynamic> responseJson = jsonDecode(response.body);
  //
  //   if (response.statusCode == 200) {
  //     if (responseJson["success"]) {
  //       taskPending = int.parse(responseJson["taskPending"]);
  //     }
  //   }
  //
  //   notifyListeners();
  // }
  //
  // int taskBusiness = 0;
  // void taskBusinessFunc() async {
  //   // String email = await StorageServices.getUserEmail();
  //   //
  //   // DocumentSnapshot userDoc = await users.doc(email).get();
  //   //
  //   // // if (isNewUser) {
  //   // //   users.doc(email).set({Keys.taskBusiness: taskBusiness});
  //   // // }
  //   // taskBusiness = userDoc[Keys.taskBusiness] ?? 0;
  //
  //   String uid = await StorageServices.getUID();
  //   String token = await StorageServices.getUsrToken();
  //   http.Response response = await http
  //       .get(Uri.parse("${Keys.apiTasksBaseUrl}/taskBusiness/$uid"), headers: {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   });
  //
  //   Map<String, dynamic> responseJson = jsonDecode(response.body);
  //
  //   if (response.statusCode == 200) {
  //     if (responseJson["success"]) {
  //       taskBusiness = int.parse(responseJson["taskBusiness"]);
  //     }
  //   }
  //
  //   notifyListeners();
  // }
  //
  // int taskPersonal = 0;
  // void taskPersonalFunc() async {
  //   // String email = await StorageServices.getUserEmail();
  //   //
  //   // DocumentSnapshot userDoc = await users.doc(email).get();
  //   //
  //   // // if (isNewUser) {
  //   // //   users.doc(email).set({Keys.taskPersonal: taskPersonal});
  //   // // }
  //   // taskPersonal = userDoc[Keys.taskPersonal] ?? 0;
  //
  //   String uid = await StorageServices.getUID();
  //   String token = await StorageServices.getUsrToken();
  //   http.Response response = await http
  //       .get(Uri.parse("${Keys.apiTasksBaseUrl}/taskPersonal/$uid"), headers: {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   });
  //
  //   Map<String, dynamic> responseJson = jsonDecode(response.body);
  //
  //   if (response.statusCode == 200) {
  //     if (responseJson["success"]) {
  //       taskPersonal = int.parse(responseJson["taskPersonal"]);
  //     }
  //   }
  //
  //   notifyListeners();
  // }
  //
  // int taskCountWithType = 0;
  // void taskCountWithTypeFunc(String type) async {
  //   String email = await StorageServices.getUserEmail();
  //
  //   DocumentSnapshot userDoc = await users.doc(email).get();
  //
  //   String taskType =
  //       (type == "Personal") ? Keys.taskPersonal : Keys.taskBusiness;
  //   taskCountWithType = userDoc[taskType] ?? 0;
  //   notifyListeners();
  // }
}
