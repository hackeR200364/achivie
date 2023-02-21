import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_app/Utils/snackbar_utils.dart';

import '../shared_preferences.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  Future googleLogin() async {
    googleSignIn.signOut();
    print(googleSignIn.isSignedIn());
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    GoogleSignInAccount? user = googleUser;

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
        .doc(user.email)
        .get();

    if (document.exists) {
    } else {
      FirebaseFirestore.instance.collection("users").doc(user.email).set(
        {
          Keys.userName: user.displayName,
          Keys.userEmail: user.email,
          Keys.uid: user.id,
          Keys.taskDone: 0,
          Keys.taskPending: 0,
          Keys.taskPersonal: 0,
          Keys.taskBusiness: 0,
          Keys.taskCount: 0,
          Keys.taskDelete: 0,
        },
      );
    }

    notifyListeners();
  }

  Future logOut() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    StorageServices.setSignStatus(false);
    notifyListeners();
  }
}

// class FaceBookSignInServices {
//   Future signInWithFacebook() async {
//     // Trigger the sign-in flow
//     final LoginResult loginResult = await FacebookAuth.instance.login();
//
//     // Create a credential from the access token
//     final OAuthCredential facebookAuthCredential =
//         FacebookAuthProvider.credential(loginResult.accessToken!.token);
//
//     // Once signed in, return the UserCredential
//     UserCredential credential = await FirebaseAuth.instance
//         .signInWithCredential(facebookAuthCredential);
//
//     // StorageServices.setSignStatus(true);
//     // if (facebookAuthCredential..isNewUser) {
//     //   StorageServices.setIsNewUser(true);
//     // } else {
//     //   StorageServices.setIsNewUser(false);
//     // }
//
//     DocumentSnapshot<Map<String, dynamic>> document = await FirebaseFirestore
//         .instance
//         .collection("users")
//         .doc(credential.user!.email)
//         .get();
//
//     if (document.exists) {
//     } else {
//       FirebaseFirestore.instance
//           .collection("users")
//           .doc(credential.user!.email)
//           .set(
//         {
//           Keys.userName: credential.user!.displayName,
//           Keys.userEmail: credential.user!.email,
//           Keys.uid: credential.user!.uid,
//           Keys.taskDone: 0,
//           Keys.taskPending: 0,
//           Keys.taskPersonal: 0,
//           Keys.taskBusiness: 0,
//           Keys.taskCount: 0,
//           Keys.taskDelete: 0,
//         },
//       );
//     }
//   }
// }

class EmailPassAuthServices {
  Future emailPassSignUp({
    required String email,
    required String pass,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final user = FirebaseAuth.instance.currentUser;

      FirebaseFirestore.instance.collection("users").doc(user!.email).set(
        {
          Keys.userName: user.displayName,
          Keys.userEmail: user.email,
          Keys.uid: user.uid,
          Keys.taskDone: 0,
          Keys.taskPending: 0,
          Keys.taskPersonal: 0,
          Keys.taskBusiness: 0,
          Keys.taskCount: 0,
          Keys.taskDelete: 0,
        },
      );
    } on FirebaseException catch (e) {
      SnackBarUtils.showSnackBar(e.message!);
      print(e.message);
    }
  }
}
