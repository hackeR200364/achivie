import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../shared_preferences.dart';

class UserDetailsProvider extends ChangeNotifier {
  final user = FirebaseAuth.instance.currentUser;

  String? userName = "";
  void userNameFunc() async {
    userName = user!.displayName;
    StorageServices.setUserName(user!.displayName!);
    notifyListeners();
  }

  String? uid = "";
  void uidFunc() async {
    uid = user!.uid;
    StorageServices.setUID(user!.uid);
    notifyListeners();
  }

  String? userEmail = "";
  void userEmailFunc() async {
    userEmail = user!.email;
    StorageServices.setUserEmail(user!.email!);
    notifyListeners();
  }

  String? userProfileImage = "";
  void userProfileImageFunc() async {
    userProfileImage = user!.photoURL;
    StorageServices.setUserPhotoURL(userProfileImage!);
    notifyListeners();
  }
}
