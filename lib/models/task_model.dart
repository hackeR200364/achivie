// To parse this JSON data, do
//
//     final tasks = tasksFromJson(jsonString);

import 'dart:convert';

Tasks tasksFromJson(String str) => Tasks.fromJson(json.decode(str));

String tasksToJson(Tasks data) => json.encode(data.toJson());

class Tasks {
  bool success;
  String message;
  List<Task> data;

  Tasks({
    required this.success,
    required this.message,
    required this.data,
  });

  factory Tasks.fromJson(Map<String, dynamic> json) => Tasks(
        success: json["success"],
        message: json["message"],
        data: List<Task>.from(json["data"].map((x) => Task.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Task {
  int notificationId;
  String taskDate;
  String taskDes;
  String taskName;
  String taskNotification;
  String taskStatus;
  String taskTime;
  String taskType;
  String uid;

  Task({
    required this.notificationId,
    required this.taskDate,
    required this.taskDes,
    required this.taskName,
    required this.taskNotification,
    required this.taskStatus,
    required this.taskTime,
    required this.taskType,
    required this.uid,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        notificationId: json["notificationID"],
        taskDate: json["taskDate"],
        taskDes: json["taskDes"],
        taskName: json["taskName"],
        taskNotification: json["taskNotification"],
        taskStatus: json["taskStatus"],
        taskTime: json["taskTime"],
        taskType: json["taskType"],
        uid: json["uid"],
      );

  Map<String, dynamic> toJson() => {
        "notificationID": notificationId,
        "taskDate": taskDate,
        "taskDes": taskDes,
        "taskName": taskName,
        "taskNotification": taskNotification,
        "taskStatus": taskStatus,
        "taskTime": taskTime,
        "taskType": taskType,
        "uid": uid,
      };
}
