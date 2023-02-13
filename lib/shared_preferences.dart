import 'package:shared_preferences/shared_preferences.dart';

class Keys {
  static const String userSignStatus = "signStatus";
  static const String isNewUser = "isNewUser";
  static const String userName = "userName";
  static const String uid = "uid";
  static const String userEmail = "userEmail";
  static const String userPhoto = "userPhoto";
  static const String taskName = "taskName";
  static const String taskDes = "taskDes";
  static const String taskNotification = "taskNotification";
  static const String taskID = "taskID";
  static const String taskType = "taskType";
  static const String taskDate = "taskDate";
  static const String taskTime = "taskTime";
  static const String taskCount = "taskCount";
  static const String taskDone = "taskDone";
  static const String taskPending = "taskPending";
  static const String taskPersonal = "taskPersonal";
  static const String taskBusiness = "taskBusiness";
  static const String taskStatus = "taskStatus";
  static const String taskDelete = "taskDelete";
  static const String deleteStatus = "Deleted";
  static const String notDeleteStatus = "Deleted";
  static const String notificationID = "notificationID";
  static const String tasksInstantChannelKey = "tasks_instant_channel";
  static const String tasksInstantChannelName = "Tasks_Instant";
  static const String tasksInstantChannelDes = "Instant Tasks Notifications";
  static const String tasksScheduledChannelKey = "Tasks_Scheduled";
  static const String tasksScheduledChannelName = "Tasks_Instant";
  static const String tasksScheduledChannelDes =
      "Scheduled Tasks Notifications";
}

class StorageServices {
  static void setSignStatus(bool signStatus) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(Keys.userSignStatus, signStatus);
  }

  static void setUserName(String userName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.userName, userName);
  }

  static void setUID(String uid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.uid, uid);
  }

  static void setUserEmail(String email) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.userEmail, email);
  }

  static void setIsNewUser(bool isNewUser) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(Keys.isNewUser, isNewUser);
  }

  static void setUserPhotoURL(String url) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.userPhoto, url);
  }

  static Future<String> getUserPhotoURL() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? photoURL = pref.getString(Keys.userPhoto) ?? "";
    return photoURL;
  }

  static Future<bool> getIsNewUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? isNewUser = pref.getBool(Keys.isNewUser) ?? false;
    return isNewUser;
  }

  static Future<String> getUserEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userEmail = pref.getString(Keys.userEmail) ?? "";
    return userEmail;
  }

  static Future<String> getUserName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userName = pref.getString(Keys.userName) ?? "";
    return userName;
  }

  static Future<String> getUID() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? uid = pref.getString(Keys.uid) ?? "";
    return uid;
  }

  static Future<bool> getSignStatus() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? signStatus = pref.getBool(Keys.userSignStatus) ?? false;
    return signStatus;
  }
}
