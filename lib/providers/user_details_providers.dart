import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../services/shared_preferences.dart';

class UserDetailsProvider extends ChangeNotifier {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  String userName = "";
  void userNameFunc() async {
    DocumentSnapshot userDoc = await users.doc(user!.email).get();
    userName = userDoc[Keys.userName];
    StorageServices.setUserName(userName);
    notifyListeners();
  }

  int userPoints = 0;
  void userPointsFunc() async {
    DocumentSnapshot userDoc = await users.doc(user!.email).get();

    if (!userDoc.data().toString().contains(Keys.userPoints)) {
      await users.doc(user!.email).set(
        {
          Keys.userPoints: userPoints,
        },
        SetOptions(
          merge: true,
        ),
      );
    }
    userPoints = await userDoc[Keys.userPoints];
    notifyListeners();
  }

  String uid = "";
  void uidFunc() async {
    DocumentSnapshot userDoc = await users.doc(user!.email).get();
    uid = userDoc[Keys.uid];
    StorageServices.setUID(uid);
    notifyListeners();
  }

  String userEmail = "";
  void userEmailFunc() async {
    DocumentSnapshot userDoc = await users.doc(user!.email).get();
    userEmail = userDoc[Keys.userEmail];
    StorageServices.setUserEmail(userEmail);
    notifyListeners();
  }

  String? userProfileImage =
      "https://www.allthetests.com/quiz22/picture/pic_1171831236_1.png";
  void userProfileImageFunc() async {
    userProfileImage = user!.photoURL;
    StorageServices.setUserPhotoURL(userProfileImage ??
        "https://www.allthetests.com/quiz22/picture/pic_1171831236_1.png");
    notifyListeners();
  }
}
