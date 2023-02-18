import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:task_app/providers/app_providers.dart';
import 'package:task_app/providers/auth_services.dart';
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
  late TextEditingController _emailController;
  late TextEditingController _passController;
  late TextEditingController _passConfirmController;
  bool visibility = true;
  bool visibility2 = true;
  int signPage = 0;

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
  void initState() {
    _emailController = TextEditingController();
    _passController = TextEditingController();
    _passConfirmController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passConfirmController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
      ),
    );
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.backgroundColour,
          secondary: AppColors.backgroundColour.withOpacity(0.5),
        ),
      ),
      home: Scaffold(
        backgroundColor: AppColors.backgroundColour,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned(
                child: Image.asset(
                  "assets/auth-bg-pic.jpg",
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                  height:
                      (signPage == 0) ? size.height * 1.25 : size.height * 1.1,
                ),
              ),
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height:
                      (signPage == 0) ? size.height * 1.25 : size.height * 1.1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.transparent,
                        AppColors.white,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
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
                        SizedBox(
                          height: size.height / 15,
                        ),
                        Lottie.asset(
                          "assets/login-animation.json",
                          width: 200,
                          height: 200,
                        ),
                        GlassmorphicContainer(
                          width: size.width,
                          height: (signPage == 0)
                              ? size.height / 1.25
                              : size.height / 1.5,
                          borderRadius: 15,
                          linearGradient: LinearGradient(
                            colors: [
                              AppColors.white.withOpacity(0.1),
                              AppColors.white.withOpacity(0.3),
                            ],
                          ),
                          border: 2,
                          blur: 4,
                          borderGradient: LinearGradient(
                            colors: [
                              AppColors.white.withOpacity(0.3),
                              AppColors.white.withOpacity(0.5),
                            ],
                          ),
                          child: Column(
                            children: [
                              //SIGN UP
                              if (signPage == 0)
                                AuthTextField(
                                  icon: Icons.email_outlined,
                                  controller: _emailController,
                                  hintText: "example@gmail.com",
                                  keyboard: TextInputType.emailAddress,
                                  isPassField: false,
                                  isPassConfirmField: false,
                                ),
                              if (signPage == 0)
                                AuthTextField(
                                  icon: Icons.security_outlined,
                                  controller: _passController,
                                  hintText: "Password",
                                  keyboard: TextInputType.visiblePassword,
                                  isPassField: true,
                                  isPassConfirmField: false,
                                ),
                              if (signPage == 0)
                                AuthTextField(
                                  icon: Icons.shield_outlined,
                                  controller: _passConfirmController,
                                  hintText: "Confirm Password",
                                  keyboard: TextInputType.visiblePassword,
                                  isPassField: false,
                                  isPassConfirmField: true,
                                ),
                              if (signPage == 0)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                    left: 15,
                                    right: 15,
                                    bottom: 10,
                                  ),
                                  child: (allAppProvidersProvider.isLoading)
                                      ? Container(
                                          height: 50,
                                          width: size.width / 2,
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.blackLow
                                                    .withOpacity(0.5),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Lottie.asset(
                                              "assets/loading-animation.json",
                                              width: 100,
                                              height: 50,
                                            ),
                                          ),
                                        )
                                      : InkWell(
                                          onTap: (() {
                                            allAppProvidersProvider
                                                .isLoadingFunc(false);
                                          }),
                                          child: Container(
                                            height: 50,
                                            width: size.width / 2,
                                            child: Center(
                                              child: Text(
                                                "Sign Up",
                                                style: TextStyle(
                                                  color: AppColors
                                                      .backgroundColour,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.blackLow
                                                      .withOpacity(0.5),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),

                              //SIGN IN
                              if (signPage == 1)
                                AuthTextField(
                                  icon: Icons.email_outlined,
                                  controller: _emailController,
                                  hintText: "example@gmail.com",
                                  keyboard: TextInputType.emailAddress,
                                  isPassField: false,
                                  isPassConfirmField: false,
                                ),
                              if (signPage == 1)
                                AuthTextField(
                                  icon: Icons.security_outlined,
                                  controller: _passController,
                                  hintText: "Password",
                                  keyboard: TextInputType.visiblePassword,
                                  isPassField: true,
                                  isPassConfirmField: false,
                                ),
                              if (signPage == 1)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                    left: 15,
                                    right: 15,
                                    bottom: 10,
                                  ),
                                  child: (allAppProvidersProvider.isLoading)
                                      ? Container(
                                          height: 50,
                                          width: size.width / 2,
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.blackLow
                                                    .withOpacity(0.5),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Lottie.asset(
                                              "assets/loading-animation.json",
                                              width: 100,
                                              height: 50,
                                            ),
                                          ),
                                        )
                                      : InkWell(
                                          onTap: (() {
                                            allAppProvidersProvider
                                                .isLoadingFunc(false);
                                          }),
                                          child: Container(
                                            height: 50,
                                            width: size.width / 2,
                                            child: Center(
                                              child: Text(
                                                "Login",
                                                style: TextStyle(
                                                  color: AppColors
                                                      .backgroundColour,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.blackLow
                                                      .withOpacity(0.5),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              const Center(
                                child: Text(
                                  "or",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                  left: 20,
                                  right: 20,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        CompanyAuth(
                                          logo: "assets/google-logo.png",
                                          onTap: (() async {
                                            allAppProvidersProvider
                                                .isLoadingFunc(true);
                                            const CircularProgressIndicator(
                                              color: AppColors.backgroundColour,
                                            );
                                            await googleSignIn(context);
                                            allAppProvidersProvider
                                                .isLoadingFunc(false);
                                          }),
                                        ),
                                        CompanyAuth(
                                          logo: "assets/facebook-logo.png",
                                          onTap: (() async {
                                            await FaceBookSignInServices()
                                                .signInWithFacebook();
                                          }),
                                        ),
                                        CompanyAuth(
                                          logo: "assets/twitter-logo.png",
                                          onTap: (() {}),
                                        ),
                                        CompanyAuth(
                                          logo: "assets/microsoft-logo.png",
                                          onTap: (() {}),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CompanyAuth(
                                          logo: "assets/apple-logo.png",
                                          onTap: (() {}),
                                        ),
                                        SizedBox(
                                          width: size.width / 15,
                                        ),
                                        CompanyAuth(
                                          logo: "assets/yahoo-logo.png",
                                          onTap: (() {}),
                                        ),
                                        SizedBox(
                                          width: size.width / 15,
                                        ),
                                        CompanyAuth(
                                          logo: "assets/github-logo.png",
                                          onTap: (() {}),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (signPage == 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                        color:
                                            AppColors.blackLow.withOpacity(0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: (() {
                                        setState(() {
                                          signPage = 1;
                                        });
                                        _emailController.clear();
                                        _passController.clear();
                                      }),
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                          color: AppColors.backgroundColour,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (signPage == 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have any account?",
                                      style: TextStyle(
                                        color:
                                            AppColors.blackLow.withOpacity(0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: (() {
                                        setState(() {
                                          signPage = 0;
                                        });
                                        _emailController.clear();
                                        _passController.clear();
                                        _passConfirmController.clear();
                                      }),
                                      child: Text(
                                        "SignUp",
                                        style: TextStyle(
                                          color: AppColors.backgroundColour,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatefulWidget {
  AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.keyboard,
    required this.isPassField,
    required this.isPassConfirmField,
    required this.icon,
  });
  TextEditingController controller;
  String hintText;
  TextInputType keyboard;
  bool isPassField, isPassConfirmField;
  IconData icon;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool passVisibility = false;
  bool passConfirmVisibility = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
        bottom: 10,
      ),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(
            widget.icon,
            color: AppColors.white,
          ),
          prefixStyle: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.white.withOpacity(0.5),
          ),
          suffixIcon: (widget.isPassField || widget.isPassConfirmField)
              ? IconButton(
                  icon: passVisibility
                      ? Icon(
                          Icons.visibility,
                          color: AppColors.white,
                        )
                      : Icon(
                          Icons.visibility_off,
                          color: AppColors.white,
                        ),
                  onPressed: (() {
                    setState(() {
                      passVisibility = !passVisibility;
                    });
                  }),
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: AppColors.white,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: AppColors.white,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          contentPadding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
        ),
        controller: widget.controller,
        keyboardType: widget.keyboard,
        cursorColor: AppColors.white,
        obscureText: (passVisibility || passConfirmVisibility) ? true : false,
      ),
    );
  }
}
//
// Padding(
// padding: const EdgeInsets.only(
// top: 20,
// left: 15,
// right: 15,
// bottom: 10,
// ),
// child: TextFormField(
// decoration: InputDecoration(
// prefixIcon: const Icon(
// Icons.password_outlined,
// color: AppColors.white,
// ),
// prefixStyle: const TextStyle(
// color: AppColors.white,
// fontSize: 16,
// ),
// hintText: "Password",
// hintStyle: TextStyle(
// color: AppColors.white.withOpacity(0.5),
// ),
// suffixIcon: IconButton(
// icon: visibility
// ? Icon(
// Icons.visibility,
// color: AppColors.white,
// )
// : Icon(
// Icons.visibility_off,
// color: AppColors.white,
// ),
// onPressed: (() {
// setState(() {
// visibility = !visibility;
// });
// }),
// ),
// focusedBorder: OutlineInputBorder(
// borderSide: const BorderSide(
// color: Colors.white,
// width: 1.0,
// ),
// borderRadius:
// BorderRadius.circular(15.0),
// ),
// enabledBorder: OutlineInputBorder(
// borderSide: const BorderSide(
// width: 1,
// color: AppColors.white,
// ),
// borderRadius:
// BorderRadius.circular(15.0),
// ),
// border: OutlineInputBorder(
// borderSide: const BorderSide(
// width: 1,
// color: AppColors.white,
// ),
// borderRadius:
// BorderRadius.circular(15.0),
// ),
// contentPadding: const EdgeInsets.only(
// left: 15,
// right: 15,
// ),
// ),
// cursorColor: AppColors.white,
// controller: _passController,
// keyboardType: TextInputType.visiblePassword,
// obscureText: visibility ? true : false,
// ),
// ),

class CompanyAuth extends StatelessWidget {
  CompanyAuth({
    super.key,
    required this.logo,
    required this.onTap,
  });

  String logo = "";
  VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          image: DecorationImage(
            scale: 1.5,
            image: AssetImage(
              logo,
            ),
          ),
        ),
      ),
    );
  }
}
