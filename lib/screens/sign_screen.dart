import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:task_app/providers/app_providers.dart';
import 'package:task_app/providers/google_sign_in.dart';
import 'package:task_app/styles.dart';

import '../shared_preferences.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // int signStatus = 0;
  bool isLoading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> googleSignIn(BuildContext context) async {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    await provider.googleLogin();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    StorageServices.setUID(user.uid);
    StorageServices.setUserName(user.displayName!);
    StorageServices.setUserEmail(user.email!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.backgroundColour,
        body: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: Consumer<AllAppProviders>(
            builder: (allAppProvidersContext, allAppProvidersProvider,
                allAppProvidersChild) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    "assets/login-animation.json",
                    width: 300,
                    height: 300,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  (allAppProvidersProvider.isLoading)
                      ? Center(
                          child: Lottie.asset(
                            "assets/loading-animation.json",
                          ),
                        )
                      : Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.grey,
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                ),
                              ]),
                          child: InkWell(
                            onTap: (() {
                              allAppProvidersProvider.isLoadingFunc(true);
                              const CircularProgressIndicator(
                                color: AppColors.backgroundColour,
                              );
                              googleSignIn(context);
                            }),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/google.png",
                                  width: 30,
                                  height: 30,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Text(
                                  "Google Login",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
