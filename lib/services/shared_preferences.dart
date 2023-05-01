import 'package:shared_preferences/shared_preferences.dart';

import 'keys.dart';

class StorageServices {
  static void setSignStatus(bool signStatus) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(Keys.usrSignStatus, signStatus);
  }

  static void setUsrName(String userName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.usrName, userName);
  }

  static void setUID(String uid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.uid, uid);
  }

  static void setUsrEmail(String email) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.usrEmail, email);
  }

  static void setIsNewUsr(bool isNewUser) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(Keys.isNewUsr, isNewUser);
  }

  static void setUsrPhotoURL(String url) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.usrPhoto, url);
  }

  static void setSignInType(String type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.usrSignInType, type);
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

  static void setUsrPoints(int usrPoints) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(Keys.usrPoints, usrPoints);
  }

  static void setUsrBlocUID(String blocUID) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.blocUID, blocUID);
  }

  static void setUsrBlocDes(String blocDes) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.blocDes, blocDes);
  }

  static void setUsrHasBloc(bool hasBloc) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(Keys.hasBloc, hasBloc);
  }

  static Future<bool> getUsrHasBloc() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? hasBloc = pref.getBool(Keys.hasBloc) ?? false;
    return hasBloc;
  }

  static Future<String> getUsrBlocDes() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? blocDes = pref.getString(Keys.blocDes) ?? "";
    return blocDes;
  }

  static Future<String> getUsrBlocUID() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? blocUID = pref.getString(Keys.blocUID) ?? "";
    return blocUID;
  }

  static Future<int> getUsrPoints() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int? usrPoints = pref.getInt(Keys.usrPoints) ?? 0;
    return usrPoints;
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

  static Future<String> getUsrSignInType() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? type = pref.getString(Keys.usrSignInType) ?? "";
    return type;
  }

  static Future<String> getUsrPhotoURL() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? photoURL = pref.getString(Keys.usrPhoto) ?? "";
    return photoURL;
  }

  static Future<bool> getIsNewUsr() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? isNewUser = pref.getBool(Keys.isNewUsr) ?? false;
    return isNewUser;
  }

  static Future<String> getUsrEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userEmail = pref.getString(Keys.usrEmail) ?? "";
    return userEmail;
  }

  static Future<String> getUsrName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userName = pref.getString(Keys.usrName) ?? "";
    return userName;
  }

  static Future<String> getUID() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? uid = pref.getString(Keys.uid) ?? "";
    return uid;
  }

  static Future<bool> getSignStatus() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? signStatus = pref.getBool(Keys.usrSignStatus) ?? false;
    return signStatus;
  }
}
