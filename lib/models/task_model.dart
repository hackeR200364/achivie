import '../services/keys.dart';

class TaskModel {
  final String? taskName;
  final String? taskDes;
  final String? taskDate;
  final String? taskTime;
  final String? taskNotification;
  final String? taskType;
  final String? taskStatus;

  const TaskModel({
    required this.taskType,
    required this.taskDate,
    required this.taskTime,
    required this.taskDes,
    required this.taskName,
    required this.taskNotification,
    this.taskStatus,
  });

  toJson() {
    return {
      Keys.taskName: taskName,
      Keys.taskDes: taskDes,
      Keys.taskDate: taskDate,
      Keys.taskTime: taskTime,
      Keys.taskType: taskType,
      Keys.taskNotification: taskNotification,
      Keys.taskStatus: taskStatus,
    };
  }
}
