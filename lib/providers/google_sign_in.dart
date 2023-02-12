import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../shared_preferences.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    StorageServices.setSignStatus(true);
    if (userCredential.additionalUserInfo!.isNewUser) {
      StorageServices.setIsNewUser(true);
    } else {
      StorageServices.setIsNewUser(false);
    }

    DocumentSnapshot<Map<String, dynamic>> document = await FirebaseFirestore
        .instance
        .collection("users")
        .doc(_user!.email)
        .get();

    if (document.exists) {
    } else {
      FirebaseFirestore.instance.collection("users").doc(_user!.email).set(
        {
          Keys.taskBusiness: 0,
          Keys.taskPersonal: 0,
          Keys.taskPending: 0,
          Keys.taskDone: 0,
          Keys.taskCount: 0,
          Keys.taskDelete: 0,
        },
      );
    }

    notifyListeners();
  }

  Future logOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    StorageServices.setSignStatus(false);
  }
}
