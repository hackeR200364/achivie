import 'dart:convert';
import 'dart:developer';
import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
// import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../Utils/snackbar_utils.dart';
import '../models/profession_model.dart';
import '../providers/app_providers.dart';
import '../services/keys.dart';
import '../services/shared_preferences.dart';
import '../styles.dart';
import 'main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // int signStatus = 0;
  bool isLoading = false;
  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _desController;
  late TextEditingController _lastNameController;
  late TextEditingController _passController;
  late TextEditingController _passConfirmController;
  late TextEditingController _otpController;
  late TextEditingController _othersProfessionController;
  bool visibility = true;
  bool visibility2 = true;
  bool selected = false;
  bool signUpPressed = false;
  int signPage = 0;
  // PackageInfo? packageInfo;
  String resetToken = "", uid = "";
  File? selectedImage;
  String _value = "0";
  String profession = "";
  String verificationToken = "";
  int otp = 0;
  static const List<ProfessionModel> professionList = <ProfessionModel>[
    ProfessionModel(
      id: "0",
      label: "Choose Your Profession",
    ),
    ProfessionModel(
      id: "1",
      label: "Graduate",
    ),
    ProfessionModel(
      id: "2",
      label: "Under-Graduate",
    ),
    ProfessionModel(
      id: "3",
      label: "Post-Graduate",
    ),
    ProfessionModel(
      id: "4",
      label: "IT-Employee",
    ),
    ProfessionModel(
      id: "5",
      label: "Entrepreneur",
    ),
    ProfessionModel(
      id: "6",
      label: "Youtuber",
    ),
    ProfessionModel(
      id: "7",
      label: "Freelancer",
    ),
    ProfessionModel(
      id: "8",
      label: "Trader",
    ),
    ProfessionModel(
      id: "9",
      label: "Developer",
    ),
    ProfessionModel(
      id: "10",
      label: "Content Creator",
    ),
    ProfessionModel(
      id: "11",
      label: "Teacher",
    ),
    ProfessionModel(
      id: "12",
      label: "Govt-Employee",
    ),
    ProfessionModel(
      id: "13",
      label: "Private-Employee",
    ),
    ProfessionModel(
      id: "14",
      label: "Professor",
    ),
    ProfessionModel(
      id: "15",
      label: "Doctor",
    ),
    ProfessionModel(
      id: "16",
      label: "Engineer",
    ),
    ProfessionModel(
      id: "17",
      label: "Others",
    ),
  ];
  // final signUpFormKey = GlobalKey<FormState>();
  // final signInFormKey = GlobalKey<FormState>();

  // Future<void> googleSignIn(BuildContext context) async {
  //   final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
  //   await provider.googleLogin();
  //
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;
  //   StorageServices.setUID(user.uid);
  //   StorageServices.setUserName(user.displayName!);
  //   StorageServices.setUserEmail(user.email!);
  //
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const MainScreen(),
  //     ),
  //   );
  // }

  // void getAppDetails() async {
  //   packageInfo = await PackageInfo.fromPlatform();
  // }

  @override
  void initState() {
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _passController = TextEditingController();
    _passConfirmController = TextEditingController();
    _desController = TextEditingController();
    _otpController = TextEditingController();
    _othersProfessionController = TextEditingController();
    // getAppDetails();

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passConfirmController.dispose();
    _passController.dispose();
    _desController.dispose();
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
                  height: (signPage == 0)
                      ? (profession == "Others")
                          ? 1280
                          : 1180
                      : (signPage == 4)
                          ? size.height
                          : (size.height < 700)
                              ? 800
                              : size.height,
                ),
              ),
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: (signPage == 0)
                      ? (profession == "Others")
                          ? 1280
                          : 1180
                      : (signPage == 4)
                          ? size.height
                          : (size.height < 700)
                              ? 800
                              : size.height,
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
                  top: 30,
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
                          height: size.height / 20,
                        ),
                        Lottie.asset(
                          "assets/login-animation.json",
                          width: 200,
                          height: 200,
                        ),
                        GlassmorphicContainer(
                          width: size.width,
                          height: (signPage == 0)
                              ? (profession == "Others")
                                  ? 920
                                  : (selected)
                                      ? 870
                                      : 800
                              : (signPage == 4)
                                  ? 350
                                  : 420,
                          borderRadius: 15,
                          linearGradient:
                              AppColors.customGlassIconButtonGradient,
                          border: 2,
                          blur: 4,
                          borderGradient:
                              AppColors.customGlassIconButtonBorderGradient,
                          child: Column(
                            children: [
                              //SIGN UP
                              if (signPage == 0 &&
                                  selected == true &&
                                  selectedImage != null)
                                GestureDetector(
                                  onTap: (() async {
                                    try {
                                      final image = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);
                                      if (image == null) return;

                                      final imageTemp = File(image.path);
                                      selectedImage = imageTemp;
                                      setState(() {});
                                    } on PlatformException catch (e) {
                                      log(e.toString());
                                    }
                                  }),
                                  child: (selectedImage != null)
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            top: 20,
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage: FileImage(
                                              selectedImage!,
                                            ),
                                            radius: 50,
                                          ),
                                        )
                                      : Container(),
                                ),
                              if (signPage == 0 &&
                                  selected == false &&
                                  selectedImage == null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 30,
                                    left: 15,
                                    right: 15,
                                    bottom: 10,
                                  ),
                                  child: Consumer<AllAppProviders>(
                                    builder: (allAppContext, allAppProvider,
                                        allAppChild) {
                                      return TextFormField(
                                        onTap: (() async {
                                          try {
                                            final image = await ImagePicker()
                                                .pickImage(
                                                    source:
                                                        ImageSource.gallery);
                                            if (image == null) return;

                                            final imageTemp = File(image.path);
                                            selectedImage = imageTemp;
                                            selected = true;
                                            signUpPressed = false;

                                            setState(() {});
                                          } on PlatformException catch (e) {
                                            log(e.toString());
                                          }
                                        }),
                                        textCapitalization:
                                            TextCapitalization.words,
                                        decoration: InputDecoration(
                                          counterText: "",
                                          prefixIcon: const Icon(
                                            Icons.image,
                                            color: AppColors.white,
                                          ),
                                          prefixStyle: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 16,
                                          ),
                                          hintText: "Choose Profile Picture",
                                          hintStyle: TextStyle(
                                            color: AppColors.white
                                                .withOpacity(0.5),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              width: 1,
                                              color: AppColors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              width: 1,
                                              color: AppColors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          contentPadding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                          ),
                                        ),
                                        readOnly: true,
                                        cursorColor: AppColors.white,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              if (signPage == 0 && signUpPressed == true)
                                SizedBox(
                                  width: size.width,
                                  child: const Center(
                                    child: Text(
                                      "Please select your profile picture.",
                                      style: TextStyle(
                                        color: AppColors.red,
                                        fontSize: 15,
                                        letterSpacing: 1,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ),
                                ),

                              if (signPage == 0)
                                AuthNameTextField(
                                  icon: Icons.person,
                                  controller: _firstNameController,
                                  hintText: "Your First Name",
                                ),
                              if (signPage == 0)
                                AuthNameTextField(
                                  icon: Icons.badge_outlined,
                                  controller: _lastNameController,
                                  hintText: "Your Last Name",
                                ),
                              if (signPage == 0)
                                AuthNameTextField(
                                  icon: Icons.description,
                                  controller: _desController,
                                  hintText: "Your Short Description",
                                  maxWords: 50,
                                  desField: true,
                                ),
                              if (signPage == 0)
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 20,
                                    left: 15,
                                    right: 15,
                                    bottom: 10,
                                  ),
                                  width: size.width,
                                  child: Center(
                                    child: DropdownButtonFormField(
                                      decoration: InputDecoration(
                                        counterText: "",
                                        prefixIcon: const Icon(
                                          Icons.work,
                                          color: AppColors.white,
                                        ),
                                        prefixStyle: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 16,
                                        ),
                                        hintText: "Study",
                                        hintStyle: TextStyle(
                                          color:
                                              AppColors.white.withOpacity(0.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            width: 1,
                                            color: AppColors.white,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            width: 1,
                                            color: AppColors.white,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 16,
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.white,
                                      ),
                                      enableFeedback: true,
                                      elevation: 5,
                                      dropdownColor: AppColors.backgroundColour,
                                      borderRadius: BorderRadius.circular(15),
                                      value: _value,
                                      items: professionList.map(
                                        (e) {
                                          return DropdownMenuItem(
                                            value: e.id,
                                            child: Text(e.label),
                                          );
                                        },
                                      ).toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          _value = value!;
                                          profession =
                                              professionList[int.parse(value)]
                                                  .label;
                                          log(profession);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              if (signPage == 0 && profession == "Others")
                                AuthNameTextField(
                                  controller: _othersProfessionController,
                                  hintText: "Enter your Profession",
                                  icon: Icons.work_outline,
                                ),
                              if (signPage == 0)
                                AuthTextField(
                                    icon: Icons.email_outlined,
                                    controller: _emailController,
                                    hintText: "Email",
                                    keyboard: TextInputType.emailAddress,
                                    isPassField: false,
                                    isPassConfirmField: false,
                                    isEmailField: true,
                                    pageIndex: signPage),
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
                                            allAppProvidersProvider
                                                .isLoadingFunc(true);

                                            if (_emailController.text
                                                    .trim()
                                                    .isNotEmpty &&
                                                _passController.text
                                                    .trim()
                                                    .isNotEmpty &&
                                                _passConfirmController.text
                                                    .trim()
                                                    .isNotEmpty &&
                                                _firstNameController.text
                                                    .trim()
                                                    .isNotEmpty &&
                                                _lastNameController.text
                                                    .trim()
                                                    .isNotEmpty &&
                                                _firstNameController.text
                                                        .trim() !=
                                                    _lastNameController.text
                                                        .trim() &&
                                                EmailValidator.validate(
                                                    _emailController.text
                                                        .trim()) &&
                                                _desController
                                                    .text.isNotEmpty &&
                                                profession.isNotEmpty &&
                                                _value.isNotEmpty &&
                                                _value != "0") {
                                              if (_passController.text ==
                                                  _passConfirmController.text) {
                                                if (selected == true) {
                                                  if (profession == "Others") {
                                                    if (_othersProfessionController
                                                        .text.isNotEmpty) {
                                                      profession =
                                                          _othersProfessionController
                                                              .text
                                                              .replaceAll(
                                                                  " ", "\n");
                                                    } else {
                                                      allAppProvidersProvider
                                                          .isLoadingFunc(false);
                                                      ScaffoldMessenger.of(
                                                              allAppProvidersContext)
                                                          .showSnackBar(
                                                        AppSnackbar()
                                                            .customizedAppSnackbar(
                                                          message:
                                                              "Please enter your profession",
                                                          context:
                                                              allAppProvidersContext,
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                  }

                                                  var request =
                                                      http.MultipartRequest(
                                                    'POST',
                                                    Uri.parse(
                                                        "${Keys.apiUsersBaseUrl}/create"),
                                                  );

                                                  var fileStream =
                                                      http.ByteStream(
                                                    selectedImage!.openRead(),
                                                  );
                                                  var length =
                                                      await selectedImage!
                                                          .length();
                                                  var multipartFile =
                                                      http.MultipartFile(
                                                    Keys.usrProfilePic,
                                                    fileStream,
                                                    length,
                                                    filename: selectedImage!
                                                        .path
                                                        .split('/')
                                                        .last,
                                                  );

                                                  request.files
                                                      .add(multipartFile);

                                                  request.headers[
                                                          "content-type"] =
                                                      "multipart/form-data";

                                                  request.fields[
                                                          Keys.usrFirstName] =
                                                      _firstNameController.text
                                                          .trim();
                                                  request.fields[
                                                          Keys.usrLastName] =
                                                      _lastNameController.text
                                                          .trim();
                                                  request.fields[
                                                          Keys.usrPassword] =
                                                      _passController.text
                                                          .trim();
                                                  request.fields[
                                                          Keys.usrEmail] =
                                                      _emailController.text
                                                          .trim();
                                                  request.fields[Keys.uid] =
                                                      _emailController.text
                                                          .trim()
                                                          .split('@')[0];
                                                  request.fields[
                                                          Keys.usrDescription] =
                                                      _desController.text
                                                          .trim();
                                                  request.fields[
                                                          Keys.usrProfession] =
                                                      profession;
                                                  request.fields[Keys
                                                          .notificationToken] =
                                                      (await FirebaseMessaging
                                                          .instance
                                                          .getToken())!;

                                                  http.Response response =
                                                      await http.Response
                                                          .fromStream(
                                                              await request
                                                                  .send());

                                                  Map<String, dynamic>
                                                      responseJson =
                                                      await json.decode(
                                                          response.body);

                                                  log(responseJson.toString());

                                                  if (response.statusCode ==
                                                      200) {
                                                    // log(response.stream
                                                    //     .bytesToString()
                                                    //     .toString());
                                                    StorageServices
                                                        .setSignInType(
                                                            Keys.email);

                                                    if (responseJson[
                                                        "success"]) {
                                                      StorageServices.setUsrName(
                                                          "${responseJson[Keys.data][0][Keys.usrFirstName]}${responseJson[Keys.data][0][Keys.usrLastName]}");

                                                      StorageServices.setUID(
                                                          responseJson[
                                                                  Keys.data][0]
                                                              [Keys.uid]);

                                                      StorageServices.setUsrEmail(
                                                          responseJson[
                                                                  Keys.data][0]
                                                              [Keys.usrEmail]);

                                                      StorageServices
                                                          .setUsrToken(
                                                              responseJson[
                                                                  Keys.token]);

                                                      StorageServices.setUsrDescription(
                                                          responseJson[
                                                              Keys
                                                                  .data][0][Keys
                                                              .usrDescription]);

                                                      StorageServices.setUsrProfilePic(
                                                          responseJson[
                                                              Keys
                                                                  .data][0][Keys
                                                              .usrProfilePic]);

                                                      StorageServices.setUsrProfession(
                                                          responseJson[
                                                              Keys
                                                                  .data][0][Keys
                                                              .usrProfession]);

                                                      // StorageServices
                                                      //     .setNotificationToken(
                                                      //         responseJson[Keys
                                                      //                 .data][0][
                                                      //             Keys.notificationToken]);

                                                      ScaffoldMessenger.of(
                                                              allAppProvidersContext)
                                                          .showSnackBar(
                                                        AppSnackbar()
                                                            .customizedAppSnackbar(
                                                          message: responseJson[
                                                              Keys.message],
                                                          context: context,
                                                        ),
                                                      );
                                                      String signInType =
                                                          await StorageServices
                                                              .getUsrSignInType();

                                                      if (signInType ==
                                                          Keys.email) {
                                                        _passController.clear();
                                                        _firstNameController
                                                            .clear();
                                                        _lastNameController
                                                            .clear();
                                                        _passConfirmController
                                                            .clear();
                                                        _desController.clear();
                                                        _value = "0";
                                                        selectedImage = null;
                                                        verificationToken =
                                                            responseJson[
                                                                "token"];
                                                        otp =
                                                            responseJson["otp"];
                                                        selectedImage = null;
                                                        selected = false;
                                                        setState(() {
                                                          signPage = 4;
                                                        });
                                                      }

                                                      allAppProvidersProvider
                                                          .isLoadingFunc(false);
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              allAppProvidersContext)
                                                          .showSnackBar(
                                                        AppSnackbar()
                                                            .customizedAppSnackbar(
                                                          message: responseJson[
                                                              Keys.message],
                                                          context:
                                                              allAppProvidersContext,
                                                        ),
                                                      );
                                                      allAppProvidersProvider
                                                          .isLoadingFunc(false);
                                                    }
                                                  } else if (response
                                                          .statusCode ==
                                                      501) {
                                                    selected = false;
                                                    selectedImage = null;
                                                    _firstNameController
                                                        .clear();
                                                    _lastNameController.clear();
                                                    _desController.clear();
                                                    profession = "";
                                                    _value = "0";
                                                    _emailController.clear();
                                                    _passController.clear();
                                                    _passConfirmController
                                                        .clear();
                                                    setState(() {
                                                      signPage = 1;
                                                    });
                                                    ScaffoldMessenger.of(
                                                            allAppProvidersContext)
                                                        .showSnackBar(
                                                      AppSnackbar()
                                                          .customizedAppSnackbar(
                                                        message: responseJson[
                                                            Keys.message],
                                                        context:
                                                            allAppProvidersContext,
                                                      ),
                                                    );
                                                    allAppProvidersProvider
                                                        .isLoadingFunc(false);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            allAppProvidersContext)
                                                        .showSnackBar(
                                                      AppSnackbar()
                                                          .customizedAppSnackbar(
                                                        message: responseJson[
                                                            Keys.message],
                                                        context:
                                                            allAppProvidersContext,
                                                      ),
                                                    );
                                                    allAppProvidersProvider
                                                        .isLoadingFunc(false);
                                                  }
                                                } else {
                                                  signUpPressed = true;
                                                  allAppProvidersProvider
                                                      .isLoadingFunc(false);
                                                  ScaffoldMessenger.of(
                                                          allAppProvidersContext)
                                                      .showSnackBar(
                                                    AppSnackbar()
                                                        .customizedAppSnackbar(
                                                      message:
                                                          "Please choose your profile picture",
                                                      context: context,
                                                    ),
                                                  );
                                                }
                                              } else {
                                                allAppProvidersProvider
                                                    .isLoadingFunc(false);
                                                ScaffoldMessenger.of(
                                                        allAppProvidersContext)
                                                    .showSnackBar(
                                                  AppSnackbar()
                                                      .customizedAppSnackbar(
                                                    message:
                                                        "Please check the password fields",
                                                    context: context,
                                                  ),
                                                );
                                              }
                                            } else {
                                              allAppProvidersProvider
                                                  .isLoadingFunc(false);
                                              ScaffoldMessenger.of(
                                                      allAppProvidersContext)
                                                  .showSnackBar(
                                                AppSnackbar()
                                                    .customizedAppSnackbar(
                                                  message:
                                                      "Please fill the fields properly",
                                                  context: context,
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
                                      onPressed: (() async {
                                        if (_emailController.text.isNotEmpty) {
                                          allAppProvidersProvider
                                              .isLoadingFunc(true);

                                          http.Response response =
                                              await http.post(
                                            Uri.parse(
                                              "${Keys.apiUsersBaseUrl}/forgotPass/${_emailController.text.trim()}",
                                            ),
                                            headers: {
                                              "content-type":
                                                  "application/json",
                                            },
                                          );

                                          Map<String, dynamic> responseJson =
                                              jsonDecode(response.body);

                                          if (response.statusCode == 200) {
                                            Map<String, dynamic> responseJson =
                                                jsonDecode(response.body);
                                            log(responseJson.toString());

                                            if (responseJson["success"]) {
                                              StorageServices.setUsrResetToken(
                                                  responseJson["token"]);

                                              resetToken =
                                                  responseJson["token"];
                                              uid = responseJson["uid"];

                                              allAppProvidersProvider
                                                  .isLoadingFunc(false);
                                              setState(() {
                                                signPage = 2;
                                              });
                                              _passController.clear();

                                              ScaffoldMessenger.of(
                                                      allAppProvidersContext)
                                                  .showSnackBar(
                                                AppSnackbar()
                                                    .customizedAppSnackbar(
                                                  message: responseJson[
                                                      Keys.message],
                                                  context:
                                                      allAppProvidersContext,
                                                ),
                                              );
                                            } else {
                                              allAppProvidersProvider
                                                  .isLoadingFunc(false);
                                              ScaffoldMessenger.of(
                                                      allAppProvidersContext)
                                                  .showSnackBar(
                                                AppSnackbar()
                                                    .customizedAppSnackbar(
                                                  message: responseJson[
                                                      Keys.message],
                                                  context:
                                                      allAppProvidersContext,
                                                ),
                                              );
                                            }
                                          } else {
                                            allAppProvidersProvider
                                                .isLoadingFunc(false);
                                            ScaffoldMessenger.of(
                                                    allAppProvidersContext)
                                                .showSnackBar(
                                              AppSnackbar()
                                                  .customizedAppSnackbar(
                                                message:
                                                    responseJson[Keys.message],
                                                context: allAppProvidersContext,
                                              ),
                                            );
                                          }
                                        } else {
                                          allAppProvidersProvider
                                              .isLoadingFunc(false);
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
                                          onTap: (() async {
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
                                              // EmailPassAuthServices()
                                              //     .emailPassSignIn(
                                              //   email: _emailController.text
                                              //       .trim(),
                                              //   pass:
                                              //       _passController.text.trim(),
                                              //   context: allAppProvidersContext,
                                              // );

                                              // String token =
                                              //     await StorageServices
                                              //         .getUsrToken();

                                              String? notificationToken =
                                                  await FirebaseMessaging
                                                      .instance
                                                      .getToken();

                                              log(notificationToken!);

                                              http.Response response =
                                                  await http.post(
                                                Uri.parse(
                                                    "${Keys.apiUsersBaseUrl}/login"),
                                                headers: {
                                                  "content-type":
                                                      "application/json",
                                                  // 'Authorization':
                                                  //     'Bearer $token',
                                                },
                                                body: jsonEncode({
                                                  Keys.uid: _emailController
                                                      .text
                                                      .trim()
                                                      .split('@')[0],
                                                  Keys.usrPassword:
                                                      _passController.text
                                                          .trim(),
                                                  Keys.usrEmail:
                                                      _emailController.text
                                                          .trim(),
                                                  Keys.notificationToken:
                                                      notificationToken,
                                                }),
                                              );

                                              log(response.body);

                                              if (response.statusCode == 200) {
                                                Map<String, dynamic>
                                                    responseJson =
                                                    jsonDecode(response.body);
                                                log(responseJson.toString());

                                                if (responseJson["success"]) {
                                                  // StorageServices
                                                  //     .setNotificationToken(
                                                  //         responseJson[Keys
                                                  //             .notificationToken]);

                                                  StorageServices.setUsrName(
                                                      "${responseJson[Keys.data][Keys.usrFirstName]} ${responseJson[Keys.data][Keys.usrLastName]}");

                                                  StorageServices.setUID(
                                                      responseJson[Keys.data]
                                                          [Keys.uid]);

                                                  StorageServices.setUsrEmail(
                                                      responseJson[Keys.data]
                                                          [Keys.usrEmail]);

                                                  StorageServices.setUsrToken(
                                                      responseJson[Keys.token]);

                                                  StorageServices
                                                      .setUsrDescription(
                                                          responseJson[
                                                              Keys
                                                                  .data][Keys
                                                              .usrDescription]);

                                                  StorageServices
                                                      .setUsrProfilePic(
                                                          responseJson[
                                                              Keys
                                                                  .data][Keys
                                                              .usrProfilePic]);

                                                  StorageServices
                                                      .setUsrProfession(
                                                          responseJson[
                                                              Keys
                                                                  .data][Keys
                                                              .usrProfession]);

                                                  if (responseJson[Keys.data]
                                                              [Keys.hasBloc] ==
                                                          1 ||
                                                      responseJson[Keys.data]
                                                              [Keys.hasBloc] ==
                                                          true) {
                                                    StorageServices
                                                        .setUsrHasBloc(true);
                                                  } else {
                                                    StorageServices
                                                        .setUsrHasBloc(false);
                                                  }
                                                  StorageServices.setUsrBlocID(
                                                      responseJson[Keys.data]
                                                              [Keys.blocID] ??
                                                          "");

                                                  StorageServices.setUsrBlocName(
                                                      responseJson[Keys.data]
                                                              [Keys.blocName] ??
                                                          "");

                                                  StorageServices.setSignStatus(
                                                      true);
                                                  StorageServices.setSignInType(
                                                      Keys.email);

                                                  ScaffoldMessenger.of(
                                                          allAppProvidersContext)
                                                      .showSnackBar(
                                                    AppSnackbar()
                                                        .customizedAppSnackbar(
                                                      message: responseJson[
                                                          Keys.message],
                                                      context:
                                                          allAppProvidersContext,
                                                    ),
                                                  );

                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (nextPageContext) =>
                                                              const MainScreen(),
                                                    ),
                                                  );
                                                } else {
                                                  _emailController.clear();
                                                  _passController.clear();
                                                  setState(() {
                                                    signPage = 0;
                                                  });
                                                  ScaffoldMessenger.of(
                                                          allAppProvidersContext)
                                                      .showSnackBar(
                                                    AppSnackbar()
                                                        .customizedAppSnackbar(
                                                      message: responseJson[
                                                          "message"],
                                                      context:
                                                          allAppProvidersContext,
                                                    ),
                                                  );
                                                }
                                              }

                                              if (response.statusCode == 403) {
                                                Map<String, dynamic>
                                                    responseJson =
                                                    jsonDecode(response.body);
                                                signPage = 4;
                                                verificationToken =
                                                    responseJson[
                                                        "verificationToken"];
                                                otp = responseJson["otp"];
                                                setState(() {});

                                                ScaffoldMessenger.of(
                                                        allAppProvidersContext)
                                                    .showSnackBar(
                                                  AppSnackbar()
                                                      .customizedAppSnackbar(
                                                    message: responseJson[
                                                        Keys.message],
                                                    context:
                                                        allAppProvidersContext,
                                                  ),
                                                );

                                                allAppProvidersProvider
                                                    .isLoadingFunc(false);
                                              }

                                              if (response.statusCode == 404) {
                                                Map<String, dynamic>
                                                    responseJson =
                                                    jsonDecode(response.body);
                                                ScaffoldMessenger.of(
                                                        allAppProvidersContext)
                                                    .showSnackBar(
                                                  AppSnackbar()
                                                      .customizedAppSnackbar(
                                                    message: responseJson[
                                                        Keys.message],
                                                    context:
                                                        allAppProvidersContext,
                                                  ),
                                                );

                                                allAppProvidersProvider
                                                    .isLoadingFunc(false);
                                              }
                                            } else {
                                              allAppProvidersProvider
                                                  .isLoadingFunc(false);
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
                              // const Center(
                              //   child: Text(
                              //     "or",
                              //     style: TextStyle(
                              //       color: AppColors.white,
                              //       fontSize: 15,
                              //     ),
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //     top: 10,
                              //     bottom: 10,
                              //     left: 20,
                              //     right: 20,
                              //   ),
                              //   child: Column(
                              //     crossAxisAlignment:
                              //         CrossAxisAlignment.stretch,
                              //     children: [
                              //       Row(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.center,
                              //         children: [
                              //           CompanyAuth(
                              //             logo: "assets/google-logo.png",
                              //             onTap: (() async {
                              //               allAppProvidersProvider
                              //                   .isLoadingFunc(true);
                              //               const CircularProgressIndicator(
                              //                 color: AppColors.backgroundColour,
                              //               );
                              //               await googleSignIn(context);
                              //               allAppProvidersProvider
                              //                   .isLoadingFunc(false);
                              //             }),
                              //           ),
                              //           SizedBox(
                              //             width: size.width / 10,
                              //           ),
                              //           CompanyAuth(
                              //             logo: "assets/apple-logo.png",
                              //             onTap: (() {
                              //               if (!Platform.isIOS ||
                              //                   !Platform.isMacOS) {
                              //                 ScaffoldMessenger.of(
                              //                         allAppProvidersContext)
                              //                     .showSnackBar(
                              //                   AppSnackbar()
                              //                       .customizedAppSnackbar(
                              //                     message:
                              //                         "Your device is not a iOS or macOS device",
                              //                     context:
                              //                         allAppProvidersContext,
                              //                   ),
                              //                 );
                              //               }
                              //             }),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
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
                                        allAppProvidersProvider
                                            .isLoadingFunc(false);
                                        _emailController.clear();
                                        _passController.clear();
                                        _firstNameController.clear();
                                        _lastNameController.clear();
                                        _passConfirmController.clear();
                                        _desController.clear();
                                        _value = "0";
                                        selectedImage = null;
                                        selected = false;
                                        setState(() {
                                          signPage = 1;
                                        });
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
                                    const Text(
                                      "Don't have any account?",
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: (() {
                                        setState(() {
                                          signPage = 0;
                                        });
                                        allAppProvidersProvider
                                            .isLoadingFunc(false);
                                        _emailController.clear();
                                        _passController.clear();
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
                                ),
                              if (signPage == 2)
                                AuthTextField(
                                  controller: _passController,
                                  hintText: "New Password",
                                  keyboard: TextInputType.visiblePassword,
                                  isPassField: true,
                                  isEmailField: false,
                                  isPassConfirmField: false,
                                  icon: Icons.password,
                                  pageIndex: 2,
                                ),
                              if (signPage == 2)
                                AuthTextField(
                                  controller: _passConfirmController,
                                  hintText: "Confirm Password",
                                  keyboard: TextInputType.visiblePassword,
                                  isPassField: false,
                                  isEmailField: false,
                                  isPassConfirmField: true,
                                  icon: Icons.password,
                                  pageIndex: 2,
                                ),

                              if (signPage == 2)
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
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
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            InkWell(
                                              onTap: (() async {
                                                allAppProvidersProvider
                                                    .isLoadingFunc(true);

                                                http.Response response =
                                                    await http.post(
                                                  Uri.parse(
                                                    "${Keys.apiUsersBaseUrl}/cancelResetPass/$resetToken/$uid",
                                                  ),
                                                  headers: {
                                                    "content-type":
                                                        "application/json",
                                                  },
                                                );

                                                if (response.statusCode ==
                                                    200) {
                                                  Map<String, dynamic>
                                                      responseJson =
                                                      jsonDecode(response.body);

                                                  log(responseJson.toString());
                                                  if (responseJson["success"]) {
                                                    ScaffoldMessenger.of(
                                                            allAppProvidersContext)
                                                        .showSnackBar(
                                                      AppSnackbar()
                                                          .customizedAppSnackbar(
                                                        message: responseJson[
                                                            Keys.message],
                                                        context:
                                                            allAppProvidersContext,
                                                      ),
                                                    );

                                                    setState(() {
                                                      signPage = 1;
                                                    });
                                                    _passController.clear();
                                                    _passConfirmController
                                                        .clear();
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            allAppProvidersContext)
                                                        .showSnackBar(
                                                      AppSnackbar()
                                                          .customizedAppSnackbar(
                                                        message: responseJson[
                                                            Keys.message],
                                                        context:
                                                            allAppProvidersContext,
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(
                                                          allAppProvidersContext)
                                                      .showSnackBar(
                                                    AppSnackbar()
                                                        .customizedAppSnackbar(
                                                      message:
                                                          "Something went wrong, please try after sometime",
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
                                                width: size.width / 3,
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
                                                    "Cancel",
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .backgroundColour,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: (() async {
                                                allAppProvidersProvider
                                                    .isLoadingFunc(true);
                                                if (_passController
                                                        .text.isNotEmpty &&
                                                    _passConfirmController
                                                        .text.isNotEmpty &&
                                                    _passController.text ==
                                                        _passConfirmController
                                                            .text) {
                                                  log(uid);
                                                  log(resetToken);
                                                  http.Response response =
                                                      await http.post(
                                                    Uri.parse(
                                                      "${Keys.apiUsersBaseUrl}/updateUserPassword",
                                                    ),
                                                    headers: {
                                                      "content-type":
                                                          "application/json",
                                                    },
                                                    body: jsonEncode({
                                                      "usrPassword":
                                                          _passController.text
                                                              .trim(),
                                                      "resetToken": resetToken,
                                                      Keys.usrEmail:
                                                          _emailController.text
                                                              .trim(),
                                                      Keys.uid: uid,
                                                    }),
                                                  );

                                                  if (response.statusCode ==
                                                      200) {
                                                    Map<String, dynamic>
                                                        responseJson =
                                                        jsonDecode(
                                                            response.body);

                                                    log(responseJson
                                                        .toString());
                                                    if (responseJson[
                                                        "success"]) {
                                                      setState(() {
                                                        signPage = 1;
                                                      });
                                                      ScaffoldMessenger.of(
                                                              allAppProvidersContext)
                                                          .showSnackBar(
                                                        AppSnackbar()
                                                            .customizedAppSnackbar(
                                                          message:
                                                              "${responseJson[Keys.message]}\nTry to login",
                                                          context:
                                                              allAppProvidersContext,
                                                        ),
                                                      );
                                                      _passController.clear();
                                                      _passConfirmController
                                                          .clear();
                                                      allAppProvidersProvider
                                                          .isLoadingFunc(false);
                                                    } else {
                                                      allAppProvidersProvider
                                                          .isLoadingFunc(false);
                                                      ScaffoldMessenger.of(
                                                              allAppProvidersContext)
                                                          .showSnackBar(
                                                        AppSnackbar()
                                                            .customizedAppSnackbar(
                                                          message: responseJson[
                                                              Keys.message],
                                                          context:
                                                              allAppProvidersContext,
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    allAppProvidersProvider
                                                        .isLoadingFunc(false);
                                                    ScaffoldMessenger.of(
                                                            allAppProvidersContext)
                                                        .showSnackBar(
                                                      AppSnackbar()
                                                          .customizedAppSnackbar(
                                                        message: response
                                                            .statusCode
                                                            .toString(),
                                                        context:
                                                            allAppProvidersContext,
                                                      ),
                                                    );
                                                  }

                                                  allAppProvidersProvider
                                                      .isLoadingFunc(false);
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
                                                width: size.width / 3,
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
                                                    "Submit",
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .backgroundColour,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),

                              if (signPage == 4)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 25,
                                      top: 30,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "OTP Verification",
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Please enter the OTP send to ${_emailController.text.trim()}",
                                          style: TextStyle(
                                              color: AppColors.white
                                                  .withOpacity(0.8),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300,
                                              overflow: TextOverflow.clip),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (signPage == 4)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: AuthTextField(
                                    controller: _otpController,
                                    hintText: "OTP",
                                    keyboard: TextInputType.number,
                                    isPassField: false,
                                    isEmailField: false,
                                    isPassConfirmField: false,
                                    icon: Icons.password,
                                    pageIndex: 4,
                                    maxLen: 8,
                                  ),
                                ),
                              if (signPage == 4)
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
                                            allAppProvidersProvider
                                                .isLoadingFunc(true);
                                            const CircularProgressIndicator(
                                              backgroundColor:
                                                  AppColors.backgroundColour,
                                            );
                                            if (_otpController
                                                .text.isNotEmpty) {
                                              // EmailPassAuthServices()
                                              //     .emailPassSignIn(
                                              //   email: _emailController.text
                                              //       .trim(),
                                              //   pass:
                                              //       _passController.text.trim(),
                                              //   context: allAppProvidersContext,
                                              // );

                                              // String token =
                                              //     await StorageServices
                                              //         .getUsrToken();

                                              log(otp.toString());
                                              if (_otpController.text.trim() ==
                                                  otp.toString()) {
                                                http.Response response =
                                                    await http.post(
                                                  Uri.parse(
                                                      "${Keys.apiUsersBaseUrl}/verification/${_emailController.text.trim().split('@')[0]}/$verificationToken/$otp"),
                                                  headers: {
                                                    "content-type":
                                                        "application/json",
                                                    // 'Authorization':
                                                    //     'Bearer $token',
                                                  },
                                                );

                                                log(response.body);

                                                if (response.statusCode ==
                                                    200) {
                                                  Map<String, dynamic>
                                                      responseJson =
                                                      jsonDecode(response.body);
                                                  log(responseJson.toString());
                                                  allAppProvidersProvider
                                                      .isLoadingFunc(false);

                                                  if (responseJson["success"]) {
                                                    setState(() {
                                                      signPage = 1;
                                                    });
                                                    _otpController.clear();
                                                    allAppProvidersProvider
                                                        .isLoadingFunc(false);
                                                    ScaffoldMessenger.of(
                                                            allAppProvidersContext)
                                                        .showSnackBar(
                                                      AppSnackbar()
                                                          .customizedAppSnackbar(
                                                        message: responseJson[
                                                            "message"],
                                                        context:
                                                            allAppProvidersContext,
                                                      ),
                                                    );
                                                  } else {
                                                    allAppProvidersProvider
                                                        .isLoadingFunc(false);
                                                    ScaffoldMessenger.of(
                                                            allAppProvidersContext)
                                                        .showSnackBar(
                                                      AppSnackbar()
                                                          .customizedAppSnackbar(
                                                        message: responseJson[
                                                            "message"],
                                                        context:
                                                            allAppProvidersContext,
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  allAppProvidersProvider
                                                      .isLoadingFunc(false);
                                                  ScaffoldMessenger.of(
                                                          allAppProvidersContext)
                                                      .showSnackBar(
                                                    AppSnackbar()
                                                        .customizedAppSnackbar(
                                                      message: response
                                                          .statusCode
                                                          .toString(),
                                                      context:
                                                          allAppProvidersContext,
                                                    ),
                                                  );
                                                }
                                              } else {
                                                allAppProvidersProvider
                                                    .isLoadingFunc(false);
                                                ScaffoldMessenger.of(
                                                        allAppProvidersContext)
                                                    .showSnackBar(
                                                  AppSnackbar()
                                                      .customizedAppSnackbar(
                                                    message:
                                                        "Please check your OTP",
                                                    context:
                                                        allAppProvidersContext,
                                                  ),
                                                );
                                              }
                                            } else {
                                              allAppProvidersProvider
                                                  .isLoadingFunc(false);
                                              ScaffoldMessenger.of(
                                                      allAppProvidersContext)
                                                  .showSnackBar(
                                                AppSnackbar()
                                                    .customizedAppSnackbar(
                                                  message:
                                                      "Please enter the OTP",
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
                                                "Submit",
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
                              if (signPage == 4)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Any problem with OTP?",
                                      style: TextStyle(
                                        color:
                                            AppColors.blackLow.withOpacity(0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: (() async {
                                        allAppProvidersProvider
                                            .isLoadingFunc(true);
                                        _otpController.clear();
                                        http.Response response =
                                            await http.post(
                                          Uri.parse(
                                              "${Keys.apiUsersBaseUrl}/resendOTP/${_emailController.text.trim()}/${_emailController.text.trim().split('@')[0]}/$verificationToken"),
                                          headers: {
                                            "content-type": "application/json",
                                            // 'Authorization':
                                            //     'Bearer $token',
                                          },
                                        );

                                        log(response.body);

                                        if (response.statusCode == 200) {
                                          Map<String, dynamic> responseJson =
                                              jsonDecode(response.body);
                                          log(responseJson.toString());
                                          allAppProvidersProvider
                                              .isLoadingFunc(false);

                                          if (responseJson["success"]) {
                                            verificationToken = responseJson[
                                                "verificationToken"];
                                            otp = responseJson["otp"];
                                            setState(() {});
                                            allAppProvidersProvider
                                                .isLoadingFunc(false);
                                            _otpController.clear();
                                            ScaffoldMessenger.of(
                                                    allAppProvidersContext)
                                                .showSnackBar(
                                              AppSnackbar()
                                                  .customizedAppSnackbar(
                                                message:
                                                    responseJson["message"],
                                                context: allAppProvidersContext,
                                              ),
                                            );
                                          } else {
                                            allAppProvidersProvider
                                                .isLoadingFunc(false);
                                            ScaffoldMessenger.of(
                                                    allAppProvidersContext)
                                                .showSnackBar(
                                              AppSnackbar()
                                                  .customizedAppSnackbar(
                                                message:
                                                    responseJson["message"],
                                                context: allAppProvidersContext,
                                              ),
                                            );
                                          }
                                        } else {
                                          allAppProvidersProvider
                                              .isLoadingFunc(false);
                                          ScaffoldMessenger.of(
                                                  allAppProvidersContext)
                                              .showSnackBar(
                                            AppSnackbar().customizedAppSnackbar(
                                              message: response.statusCode
                                                  .toString(),
                                              context: allAppProvidersContext,
                                            ),
                                          );
                                        }
                                      }),
                                      child: const Text(
                                        "Resend it",
                                        style: TextStyle(
                                          color: AppColors.backgroundColour,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
    required this.isEmailField,
    required this.isPassConfirmField,
    required this.icon,
    required this.pageIndex,
    this.maxLen,
    // required this.formKey,
  });
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboard;
  final bool isPassField, isPassConfirmField, isEmailField;
  final IconData icon;
  final int pageIndex;
  int? maxLen;

  // GlobalKey<FormState> formKey;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool passVisibility = true;
  bool passConfirmVisibility = true;

  String? _validate(String? input) {
    if (input != null && input.isNotEmpty) {
      if (widget.isEmailField) {
        if (!EmailValidator.validate(input)) {
          return "Enter a valid email";
        } else {
          return null;
        }
      }
      if (widget.isPassField) {
        if (input.length < 8) {
          return "Password should contain minimum 8 characters";
        }
        if (!RegExp(r'^(?=.*[A-Z])[\w#]+').hasMatch(input)) {
          return "Password should contain minimum 1 Uppercase character";
        }
        if (!RegExp(r'^(?=.*[a-z])[\w#]+').hasMatch(input)) {
          return "Password should contain minimum 1 Lowercase character";
        }
        if (!RegExp(r'^(?=.*[0-9])[\w#]+').hasMatch(input)) {
          return "Password should contain minimum 1 numeric";
        }
        if (!RegExp(r'^(?=.*[@#₹_&-+()/*:;!?~`|$^=.,])[\w#]+')
            .hasMatch(input)) {
          return "Password should contain minimum 1 special character";
        }
      }
      return null;
    }
    return "This is a required field";
  }

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
        maxLength: widget.maxLen,
        enableInteractiveSelection:
            (widget.isPassField || widget.isPassConfirmField) ? false : true,
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
                  icon: (widget.isPassField)
                      ? passVisibility
                          ? const Icon(
                              Icons.visibility,
                              color: AppColors.white,
                            )
                          : const Icon(
                              Icons.visibility_off,
                              color: AppColors.white,
                            )
                      : passConfirmVisibility
                          ? const Icon(
                              Icons.visibility,
                              color: AppColors.white,
                            )
                          : const Icon(
                              Icons.visibility_off,
                              color: AppColors.white,
                            ),
                  onPressed: (() {
                    if (widget.isPassField) {
                      setState(() {
                        passVisibility = !passVisibility;
                      });
                    }
                    if (widget.isPassConfirmField) {
                      setState(() {
                        passConfirmVisibility = !passConfirmVisibility;
                      });
                    }
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
        validator: _validate,
        // (widget.isEmailField && widget.controller.text.isNotEmpty)
        //     ? (email) => (email != null && !EmailValidator.validate(email))
        //         ? "Enter a valid email"
        //         : null
        //     : (widget.isPassField && widget.controller.text.isNotEmpty)
        //         ? ((password) {
        //             if (password != null) {
        //               if (password.length < 8) {
        //                 return "Password should contain minimum 8 characters";
        //               }
        //               if (!RegExp(r'^(?=.*[A-Z])\w+').hasMatch(password)) {
        //                 return "Password should contain minimum 1 Uppercase character";
        //               }
        //               if (!RegExp(r'^(?=.*[a-z])\w+').hasMatch(password)) {
        //                 return "Password should contain minimum 1 Lowercase character";
        //               }
        //               if (!RegExp(r'^(?=.*[0-9])\w+').hasMatch(password)) {
        //                 return "Password should contain minimum 1 numeric";
        //               }
        //               if (!RegExp(r'^(?=.*[@#₹_&-+()/*:;!?~`|$^=.,])\w+')
        //                   .hasMatch(password)) {
        //                 return "Password should contain minimum 1 special character";
        //               }
        //             }
        //             return null;
        //           })
        //         : null

        autovalidateMode: (widget.isEmailField || widget.isPassField)
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        controller: widget.controller,
        keyboardType: widget.keyboard,
        cursorColor: AppColors.white,
        style: const TextStyle(
          color: AppColors.white,
        ),
        obscureText: (widget.isPassField)
            ? passVisibility
            : (widget.isPassConfirmField)
                ? passConfirmVisibility
                : false,
      ),
    );
  }
}

class AuthNameTextField extends StatefulWidget {
  const AuthNameTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.maxWords,
    this.desField,
    this.maxLines,
    this.onTap,
    this.onSubmit,
    this.onTappedOutSide,
    this.readOnly,
    this.nameField,
    this.onChange,
    this.inputFormatter,
    // required this.formKey,
  });
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final int? maxWords, maxLines;
  final bool? nameField, desField, readOnly;
  final VoidCallback? onTap;
  final Function(String)? onSubmit;
  final Function(String)? onChange;
  final Function(PointerDownEvent)? onTappedOutSide;
  final List<TextInputFormatter>? inputFormatter;

  @override
  State<AuthNameTextField> createState() => _AuthNameTextFieldState();
}

class _AuthNameTextFieldState extends State<AuthNameTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
        bottom: 10,
      ),
      child: Consumer<AllAppProviders>(
        builder: (allAppContext, allAppProvider, allAppChild) {
          return TextFormField(
            textCapitalization: TextCapitalization.sentences,
            onTap: widget.onTap,
            readOnly: (widget.readOnly != null) ? true : false,
            decoration: InputDecoration(
              counterText: "",
              suffixText: (widget.desField != null && widget.desField == true)
                  ? "${allAppProvider.desPosition.toString()}/${widget.maxWords}"
                  : (widget.nameField != null && widget.nameField == true)
                      ? "${allAppProvider.namePosition.toString()}/${widget.maxWords}"
                      : "",
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
            onChanged: ((text) {
              if (widget.desField != null && widget.desField == true) {
                allAppProvider.desLengthFunc(text.trim().length);
              }
              if (widget.nameField != null && widget.nameField == true) {
                allAppProvider.nameLengthFunc(text.trim().length);
              }
            }),
            maxLength: widget.maxWords,
            maxLines: (widget.desField != null && widget.desField == true)
                ? (widget.maxLines == null)
                    ? 2
                    : widget.maxLines
                : null,
            minLines: 1,
            controller: widget.controller,
            keyboardType: (widget.desField != null && widget.desField == true)
                ? TextInputType.multiline
                : TextInputType.name,
            cursorColor: AppColors.white,
            style: const TextStyle(
              color: AppColors.white,
            ),
            onFieldSubmitted: widget.onSubmit,
            onTapOutside: widget.onTappedOutSide,
            inputFormatters: widget.inputFormatter,
          );
        },
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
