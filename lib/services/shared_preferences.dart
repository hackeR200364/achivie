import 'package:shared_preferences/shared_preferences.dart';

import 'keys.dart';

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

  static void setSignInType(String type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.userSignInType, type);
  }

  static void setUsrToken(String token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.token, token);
  }

  static void setUsrResetToken(String token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.resetToken, token);
  }

  static void setUsrDescription(String description) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.usrDescription, description);
  }

  static void setUsrProfilePic(String profilePic) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.usrProfilePic, profilePic);
  }

  static void setUsrProfession(String usrProfession) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.usrProfession, usrProfession);
  }

  static Future<String> getUsrProfession() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? usrProfession = pref.getString(Keys.usrProfession) ?? "";
    return usrProfession;
  }

  static Future<String> getUsrProfilePic() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? usrProfilePic = pref.getString(Keys.usrProfilePic) ?? "";
    return usrProfilePic;
  }

  static Future<String> getUsrDescription() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? usrDescription = pref.getString(Keys.usrDescription) ?? "";
    return usrDescription;
  }

  static Future<String> getResetToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? resetToken = pref.getString(Keys.token) ?? "";
    return resetToken;
  }

  static Future<String> getUsrToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString(Keys.token) ?? "";
    return token;
  }

  static Future<String> getUserSignInType() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? type = pref.getString(Keys.userSignInType) ?? "";
    return type;
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
