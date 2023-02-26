import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Utils/snackbar_utils.dart';
import 'package:task_app/providers/app_providers.dart';
import 'package:task_app/screens/main_screen.dart';
import 'package:task_app/services/auth_services.dart';
import 'package:task_app/styles.dart';

import '../services/shared_preferences.dart';

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
  late TextEditingController _nameController;
  late TextEditingController _passController;
  late TextEditingController _passConfirmController;
  bool visibility = true;
  bool visibility2 = true;
  int signPage = 0;
  PackageInfo? packageInfo;

  // final signUpFormKey = GlobalKey<FormState>();
  // final signInFormKey = GlobalKey<FormState>();

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
        builder: (context) => const MainScreen(),
      ),
    );
  }

  void getAppDetails() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passController = TextEditingController();
    _passConfirmController = TextEditingController();
    getAppDetails();

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passConfirmController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
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
                  height: (signPage == 0) ? size.height * 1.1 : size.height,
                ),
              ),
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: (signPage == 0) ? size.height * 1.1 : size.height,
                  decoration: const BoxDecoration(
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
                              ? size.height / 1.4
                              : size.height / 1.8,
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
                                    icon: Icons.badge_outlined,
                                    controller: _nameController,
                                    hintText: "Your name",
                                    keyboard: TextInputType.name,
                                    isPassField: false,
                                    isPassConfirmField: false,
                                    isEmailField: false,
                                    pageIndex: signPage
                                    // formKey: signUpFormKey,
                                    ),
                              if (signPage == 0)
                                AuthTextField(
                                    icon: Icons.email_outlined,
                                    controller: _emailController,
                                    hintText: "example@gmail.com",
                                    keyboard: TextInputType.emailAddress,
                                    isPassField: false,
                                    isPassConfirmField: false,
                                    isEmailField: true,
                                    pageIndex: signPage
                                    // formKey: signUpFormKey,
                                    ),
                              if (signPage == 0)
                                AuthTextField(
                                  icon: Icons.security_outlined,
                                  controller: _passController,
                                  hintText: "Password",
                                  keyboard: TextInputType.visiblePassword,
                                  isPassField: true,
                                  isPassConfirmField: false,
                                  isEmailField: false,
                                  pageIndex: signPage,

                                  // formKey: signUpFormKey,
                                ),
                              if (signPage == 0)
                                AuthTextField(
                                  icon: Icons.shield_outlined,
                                  controller: _passConfirmController,
                                  hintText: "Confirm Password",
                                  keyboard: TextInputType.visiblePassword,
                                  isPassField: false,
                                  isPassConfirmField: true,
                                  isEmailField: false,
                                  pageIndex: signPage,

                                  // formKey: signUpFormKey,
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
                                          onTap: (() async {
                                            // print(packageInfo!.version);

                                            if (_emailController
                                                    .text.isNotEmpty &&
                                                _passController
                                                    .text.isNotEmpty &&
                                                _passConfirmController
                                                    .text.isNotEmpty &&
                                                _nameController
                                                    .text.isNotEmpty) {
                                              if (_passController.text ==
                                                  _passConfirmController.text) {
                                                allAppProvidersProvider
                                                    .isLoadingFunc(true);
                                                EmailPassAuthServices()
                                                    .emailPassSignUp(
                                                  name: _nameController.text
                                                      .trim(),
                                                  email: _emailController.text
                                                      .trim(),
                                                  pass: _passController.text
                                                      .trim(),
                                                  context: context,
                                                );

                                                String signInType =
                                                    await StorageServices
                                                        .getUserSignInType();

                                                if (signInType == "Email") {
                                                  _emailController.clear();
                                                  _passController.clear();
                                                  _nameController.clear();
                                                  _passConfirmController
                                                      .clear();
                                                  setState(() {
                                                    signPage = 1;
                                                  });
                                                }
                                                allAppProvidersProvider
                                                    .isLoadingFunc(false);
                                              } else {
                                                ScaffoldMessenger.of(
                                                        allAppProvidersContext)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    margin: EdgeInsets.only(
                                                      bottom: 30,
                                                      left: size.width / 10,
                                                      right: size.width / 10,
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    dismissDirection:
                                                        DismissDirection
                                                            .horizontal,
                                                    backgroundColor: AppColors
                                                        .backgroundColour,
                                                    content: const Text(
                                                      "Please check the password fields",
                                                      style: TextStyle(
                                                        color: AppColors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(
                                                      allAppProvidersContext)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  margin: EdgeInsets.only(
                                                    bottom: 30,
                                                    left: 30,
                                                    right: 30,
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  dismissDirection:
                                                      DismissDirection
                                                          .horizontal,
                                                  backgroundColor: AppColors
                                                      .backgroundColour,
                                                  content: Text(
                                                    "Please fill the fields properly",
                                                    style: TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          }),
                                          child: Container(
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
                                            child: const Center(
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
                                  isEmailField: true,
                                  pageIndex: signPage,
                                  // formKey: signInFormKey,
                                ),
                              if (signPage == 1)
                                AuthTextField(
                                  icon: Icons.security_outlined,
                                  controller: _passController,
                                  hintText: "Password",
                                  keyboard: TextInputType.visiblePassword,
                                  isPassField: true,
                                  isPassConfirmField: false,
                                  isEmailField: false,
                                  pageIndex: signPage,
                                  // formKey: signInFormKey,
                                ),
                              if (signPage == 1)
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: (() {
                                        if (_emailController.text.isNotEmpty) {
                                          EmailPassAuthServices()
                                              .forgotPassword(
                                            email: _emailController.text.trim(),
                                            context: allAppProvidersContext,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                                  allAppProvidersContext)
                                              .showSnackBar(
                                            AppSnackbar().customizedAppSnackbar(
                                              message:
                                                  "Please give your registered email",
                                              context: allAppProvidersContext,
                                            ),
                                          );
                                        }
                                      }),
                                      child: const Text(
                                        "Forgot Password",
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
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
                                                .isLoadingFunc(true);
                                            const CircularProgressIndicator(
                                              backgroundColor:
                                                  AppColors.backgroundColour,
                                            );
                                            if (_emailController
                                                    .text.isNotEmpty &&
                                                _passController
                                                    .text.isNotEmpty) {
                                              EmailPassAuthServices()
                                                  .emailPassSignIn(
                                                email: _emailController.text
                                                    .trim(),
                                                pass:
                                                    _passController.text.trim(),
                                                context: allAppProvidersContext,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                      allAppProvidersContext)
                                                  .showSnackBar(
                                                AppSnackbar()
                                                    .customizedAppSnackbar(
                                                  message:
                                                      "Please fill the fields correctly",
                                                  context:
                                                      allAppProvidersContext,
                                                ),
                                              );
                                            }
                                            allAppProvidersProvider
                                                .isLoadingFunc(false);
                                          }),
                                          child: Container(
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
                                            child: const Center(
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
                                          MainAxisAlignment.center,
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
                                        SizedBox(
                                          width: size.width / 10,
                                        ),
                                        CompanyAuth(
                                          logo: "assets/apple-logo.png",
                                          onTap: (() {
                                            if (!Platform.isIOS ||
                                                !Platform.isMacOS) {
                                              ScaffoldMessenger.of(
                                                      allAppProvidersContext)
                                                  .showSnackBar(
                                                AppSnackbar()
                                                    .customizedAppSnackbar(
                                                  message:
                                                      "Your device is not a iOS or macOS device",
                                                  context:
                                                      allAppProvidersContext,
                                                ),
                                              );
                                            }
                                          }),
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
                                      child: const Text(
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
                                      child: const Text(
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
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.keyboard,
    required this.isPassField,
    required this.isEmailField,
    required this.isPassConfirmField,
    required this.icon,
    required this.pageIndex,
    // required this.formKey,
  });
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboard;
  final bool isPassField, isPassConfirmField, isEmailField;
  final IconData icon;
  final int pageIndex;
  // GlobalKey<FormState> formKey;

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
        toolbarOptions: (widget.isPassField || widget.isPassConfirmField)
            ? const ToolbarOptions(selectAll: true)
            : const ToolbarOptions(
                selectAll: true,
                copy: true,
                cut: true,
                paste: true,
              ),
        decoration: InputDecoration(
          errorStyle: const TextStyle(
            overflow: TextOverflow.clip,
          ),
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
                      ? const Icon(
                          Icons.visibility,
                          color: AppColors.white,
                        )
                      : const Icon(
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
        validator: (widget.isEmailField)
            ? (email) => (email != null && !EmailValidator.validate(email))
                ? "Enter a valid email"
                : null
            : (widget.isPassField)
                ? ((password) {
                    if (password != null) {
                      if (password.length < 8) {
                        return "Password should contain minimum 8 characters";
                      }
                      if (!RegExp(r'^(?=.*[A-Z])\w+').hasMatch(password)) {
                        return "Password should contain minimum 1 Uppercase character";
                      }
                      if (!RegExp(r'^(?=.*[a-z])\w+').hasMatch(password)) {
                        return "Password should contain minimum 1 Lowercase character";
                      }
                      if (!RegExp(r'^(?=.*[0-9])\w+').hasMatch(password)) {
                        return "Password should contain minimum 1 numeric";
                      }
                      if (!RegExp(r'^(?=.*[@#₹_&-+()/*:;!?~`|$^=.,])\w+')
                          .hasMatch(password)) {
                        return "Password should contain minimum 1 special character";
                      }
                    }
                    return null;
                  })
                : null,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: widget.controller,
        keyboardType: widget.keyboard,
        cursorColor: AppColors.white,
        style: const TextStyle(
          color: AppColors.white,
        ),
        obscureText: (passVisibility || passConfirmVisibility) ? true : false,
      ),
    );
  }
}

class CompanyAuth extends StatelessWidget {
  const CompanyAuth({
    super.key,
    required this.logo,
    required this.onTap,
  });

  final String logo;
  final VoidCallback onTap;

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
