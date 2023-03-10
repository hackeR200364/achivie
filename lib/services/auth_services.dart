import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:task_app/screens/main_screen.dart';

import '../Utils/snackbar_utils.dart';
import '../styles.dart';
import 'keys.dart';
import 'shared_preferences.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  Future googleLogin() async {
    googleSignIn.signOut();
    // print(googleSignIn.isSignedIn());
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

    StorageServices.setSignInType("Google");

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
    required String firstName,
    required String lastName,
    required String email,
    required String pass,
    required String uid,
    required BuildContext context,
  }) async {
    // await FirebaseAuth.instance.createUserWithEmailAndPassword(
    //   email: email,
    //   password: pass,
    // );
    //
    // final user = FirebaseAuth.instance.currentUser;
    //
    // await user!.sendEmailVerification();
    //
    // FirebaseFirestore.instance.collection("users").doc(user.email).set(
    //   {
    //     Keys.userName: name,
    //     Keys.userEmail: email,
    //     Keys.userPassword: pass,
    //     Keys.uid: user.uid,
    //     Keys.taskDone: 0,
    //     Keys.taskPending: 0,
    //     Keys.taskPersonal: 0,
    //     Keys.taskBusiness: 0,
    //     Keys.taskCount: 0,
    //     Keys.taskDelete: 0,
    //   },
    // );

    http.Response response = await http.post(
      Uri.parse("${Keys.apiUsersBaseUrl}/create"),
      headers: {
        "content-type": "application/json",
      },
      body: jsonEncode({
        "usrFirstName": firstName.toString(),
        "usrLastName": lastName.toString(),
        "usrPassword": pass.toString(),
        "usrEmail": email.toString(),
        "uid": uid.toString(),
      }),
    );

    if (response.statusCode == 200) {
      log(response.body.toString());

      Map<String, dynamic> responseJson = jsonDecode(response.body);

      if (responseJson["success"]) {
        StorageServices.setSignInType(Keys.email);
        StorageServices.setUserName(
            "${responseJson[Keys.data][Keys.usrFirstName]}${responseJson[Keys.data][Keys.usrLastName]}");
        StorageServices.setUID(responseJson[Keys.data][Keys.uid]);
        StorageServices.setUserEmail(responseJson[Keys.data][Keys.usrEmail]);
        StorageServices.setUsrToken(responseJson[Keys.token]);

        AppSnackbar().customizedAppSnackbar(
          message: responseJson[Keys.message],
          context: context,
        );
      } else {
        AppSnackbar().customizedAppSnackbar(
          message: responseJson[Keys.message],
          context: context,
        );
      }
    } else {
      AppSnackbar().customizedAppSnackbar(
        message: "Something went wrong",
        context: context,
      );
    }
  }

  Future emailPassSignIn({
    required String email,
    required String pass,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      StorageServices.setSignStatus(true);
      StorageServices.setUserEmail(email);
      StorageServices.setUID(pass);
      try {
        StorageServices.setSignInType("Email");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (nextPageContext) => const MainScreen(),
          ),
        );
      } on FirebaseException catch (e) {
        Dialogs.bottomMaterialDialog(
          context: context,
          color: AppColors.white,
          title: "Warning",
          msg: e.message,
          msgStyle: const TextStyle(
            color: AppColors.mainColor,
            fontWeight: FontWeight.w600,
          ),
          titleStyle: const TextStyle(
            color: AppColors.backgroundColour,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    } on FirebaseException catch (e) {
      // print(e.message);
      Dialogs.bottomMaterialDialog(
        context: context,
        color: AppColors.white,
        title: "Warning",
        msg: e.message,
        msgStyle: const TextStyle(
          color: AppColors.mainColor,
          fontWeight: FontWeight.w600,
        ),
        titleStyle: const TextStyle(
          color: AppColors.backgroundColour,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  Future forgotPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Dialogs.bottomMaterialDialog(
        context: context,
        color: AppColors.white,
        title: "Success",
        msg: "Password reset email sent. Please check your email app",
        msgStyle: const TextStyle(
          color: AppColors.mainColor,
          fontWeight: FontWeight.w600,
        ),
        titleStyle: const TextStyle(
          color: AppColors.backgroundColour,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        lottieBuilder: Lottie.asset("assets/success-done-animation.json"),
        actions: [
          InkWell(
            onTap: (() async {
              var result = await OpenMailApp.openMailApp();
              if (!result.didOpen && !result.canOpen) {
              } else if (!result.didOpen && result.canOpen) {
                showDialog(
                  context: context,
                  builder: (_) {
                    return MailAppPickerDialog(
                      mailApps: result.options,
                    );
                  },
                );
              }
            }),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.mainColor,
              ),
              child: const Center(
                child: Text(
                  "Open",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } on FirebaseException catch (e) {
      Dialogs.bottomMaterialDialog(
        context: context,
        color: AppColors.white,
        title: "Failed",
        msg: e.message,
        msgStyle: const TextStyle(
          color: AppColors.mainColor,
          fontWeight: FontWeight.w600,
        ),
        titleStyle: const TextStyle(
          color: AppColors.backgroundColour,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        lottieBuilder: Lottie.asset("assets/success-done-animation.json"),
      );
    }
  }

  Future emailPassLogout({
    required BuildContext context,
  }) async {
    await FirebaseAuth.instance.signOut();
    StorageServices.setSignStatus(false);
  }
}
