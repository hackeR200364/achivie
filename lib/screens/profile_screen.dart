import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../Utils/snackbar_utils.dart';
import '../providers/app_providers.dart';
import '../services/keys.dart';
import '../services/shared_preferences.dart';
import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "", email = "", profilePic = "", profession = "", des = "";
  BannerAd? bannerAd;
  RewardedAd? rewardedAd;
  RewardedAd? rewardedAd2;
  NativeAd? nativeAd;
  bool isBannerAdLoaded = false;
  bool isNativeAdLoaded = false;

  bool phoneVisibility = false;
  bool desVisibility = false;
  bool skillVisibility = false;
  bool emailVisibility = true;
  int rate = 0;
  // int totalPending = 0;
  // int totalDone = 5;
  // int totalBusiness = 0;
  // int totalPersonal = 0;
  // int totalDelete = 0;
  late TextEditingController _phoneController;
  late TextEditingController _desController;
  late TextEditingController _keySkillController;
  late ScreenshotController _screenshotController;

  void getDetails() async {
    name = await StorageServices.getUsrName();
    email = await StorageServices.getUsrEmail();
    profilePic = await StorageServices.getUsrProfilePic();
    des = await StorageServices.getUsrDescription();
    profession = await StorageServices.getUsrProfession();
    _desController.text = des;
    setState(() {});
  }

  @override
  void initState() {
    _phoneController = TextEditingController();
    _desController = TextEditingController();
    _screenshotController = ScreenshotController();
    _keySkillController = TextEditingController();
    getDetails();
    completionRate();
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-7050103229809241/8475560629",
      listener: BannerAdListener(
        onAdLoaded: ((ad) {
          setState(() {
            isBannerAdLoaded = true;
          });
        }),
      ),
      request: const AdRequest(),
    );
    bannerAd!.load();
    RewardedAd.load(
      adUnitId: "ca-app-pub-7050103229809241/4189665409",
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: ((onAdLoaded) {
          rewardedAd = onAdLoaded;
        }),
        onAdFailedToLoad: ((onAdFailedToLoad) {
          // print("Failed: ${onAdFailedToLoad.message}");
        }),
      ),
    );
    RewardedAd.load(
      adUnitId: "ca-app-pub-7050103229809241/9189381656",
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: ((onAdLoaded) {
          rewardedAd2 = onAdLoaded;
        }),
        onAdFailedToLoad: ((onAdFailedToLoad) {
          // print("Failed: ${onAdFailedToLoad.message}");
        }),
      ),
    );
    nativeAd = NativeAd(
      adUnitId: "ca-app-pub-7050103229809241/9680336245",
      factoryId: "listTile",
      listener: NativeAdListener(
        onAdLoaded: ((ad) {
          setState(() {
            isNativeAdLoaded = true;
          });
        }),
        onAdFailedToLoad: ((ad, err) {
          nativeAd?.dispose();
        }),
      ),
      request: const AdRequest(),
    );
    nativeAd!.load();

    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _desController.dispose();
    bannerAd?.dispose();
    nativeAd?.dispose();
    rewardedAd?.dispose();
    rewardedAd2?.dispose();
    super.dispose();
  }

  String validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return "";
  }

  Future<void> completionRate() async {
    // ((totalDone / (totalTasks - totalDelete)) * 100).round();

    String uid = await StorageServices.getUID();
    String token = await StorageServices.getUsrToken();

    http.Response response = await http.get(
        Uri.parse("${Keys.apiUsersBaseUrl}/completionRate/$uid"),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      // log(responseJson.toString());
      if (responseJson["success"]) {
        rate = responseJson["completionRate"];
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log(email.length.toString());
    Size size = MediaQuery.of(context).size;
    log((size.height / 25).round().toString());
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          leading: CustomAppBarLeading(
            icon: CupertinoIcons.back,
            onPressed: (() {
              Navigator.pop(context);
            }),
          ),
          title: const CustomAppBarTitle(
            heading: "Profile Progress",
          ),
        ),
        backgroundColor: AppColors.mainColor,
        bottomNavigationBar: (isBannerAdLoaded)
            ? Container(
                color: AppColors.mainColor,
                width: MediaQuery.of(context).size.width,
                height: bannerAd!.size.height.toDouble(),
                child: AdWidget(
                  ad: bannerAd!,
                ),
              )
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 20,
                  ),
                  child: Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 20,
                      ),
                      width: size.width,
                      // margin: EdgeInsets.symmetric(
                      //   horizontal: 10,
                      // ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (profilePic.isNotEmpty)
                            Column(
                              children: [
                                CircleAvatar(
                                  foregroundImage: NetworkImage(
                                    profilePic,
                                  ),
                                  backgroundColor: AppColors.mainColor,
                                  radius: 50,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                if (rate <= 25)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.red,
                                          AppColors.orange,
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Silver",
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (rate > 25 && rate <= 50)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.goldDark,
                                          AppColors.gold,
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Gold",
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (rate > 50 && rate <= 100)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.diamondDark,
                                          AppColors.diamond,
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Diamond",
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          if (profilePic.isEmpty)
                            const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.backgroundColour,
                              ),
                            ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: AppColors.blackLow,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: size.width / 2.1,
                                child: (desVisibility)
                                    ? Consumer<AllAppProviders>(
                                        builder: (allAppContext, allAppProvider,
                                            allAppChild) {
                                          return Text(
                                            allAppProvider.des,
                                            style: TextStyle(
                                              overflow: TextOverflow.clip,
                                              color: AppColors.blackLow
                                                  .withOpacity(0.6),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      )
                                    : Text(
                                        des,
                                        style: TextStyle(
                                          overflow: TextOverflow.clip,
                                          color: AppColors.blackLow
                                              .withOpacity(0.45),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                              if (emailVisibility)
                                const SizedBox(
                                  height: 10,
                                ),
                              if (emailVisibility)
                                Row(
                                  children: [
                                    if (email.length >
                                        (size.height / 25).round())
                                      const Icon(
                                        Icons.email,
                                        color: AppColors.grey,
                                        size: 20,
                                      ),
                                    if (email.length >
                                        (size.height / 25).round())
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    SizedBox(
                                      width: (email.length >
                                              (size.height / 20).round())
                                          ? size.width / 2.5
                                          : null,
                                      child: Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          overflow: TextOverflow.clip,
                                          color: AppColors.blackLow
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (phoneVisibility)
                                const SizedBox(
                                  height: 5,
                                ),
                              if (phoneVisibility)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      color: AppColors.grey,
                                      size: 17,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Consumer<AllAppProviders>(builder:
                                        (allAppContext, allAppProvider,
                                            allAppChild) {
                                      return Row(
                                        children: [
                                          Text(
                                            allAppProvider.phCode,
                                            style: TextStyle(
                                              fontSize: 12,
                                              overflow: TextOverflow.clip,
                                              color: AppColors.blackLow
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            _phoneController.text.trim(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              overflow: TextOverflow.clip,
                                              color: AppColors.blackLow
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    profession,
                                    style: const TextStyle(
                                      overflow: TextOverflow.clip,
                                      color: AppColors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (skillVisibility)
                                    Container(
                                      height: 10,
                                      width: 1.5,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      decoration: const BoxDecoration(
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  if (skillVisibility)
                                    Consumer<AllAppProviders>(builder:
                                        (allAppContext, allAppProvider,
                                            allAppChild) {
                                      return SizedBox(
                                        width: size.width / 4,
                                        child: Text(
                                          allAppProvider.keySkill,
                                          style: const TextStyle(
                                            overflow: TextOverflow.clip,
                                            color: AppColors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Completion rate: ",
                                    style: TextStyle(
                                      color:
                                          AppColors.blackLow.withOpacity(0.6),
                                    ),
                                  ),
                                  if (rate <= 25)
                                    Text(
                                      "${rate.toString()}%",
                                      style: const TextStyle(
                                        color: AppColors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (rate > 25 && rate <= 50)
                                    Text(
                                      "${rate.toString()}%",
                                      style: const TextStyle(
                                        color: AppColors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (rate > 50 && rate <= 100)
                                    Text(
                                      "${rate.toString()}%",
                                      style: const TextStyle(
                                        color: AppColors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: const [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundImage: AssetImage(
                                      "assets/logo-first-splash.png",
                                    ),
                                  ),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Center(
                                    child: Text(
                                      "achivie.com",
                                      style: TextStyle(
                                        color: AppColors.backgroundColour,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (() {
                    setState(() {
                      emailVisibility = !emailVisibility;
                    });
                  }),
                  child: GlassmorphicContainer(
                    margin: const EdgeInsets.only(
                      top: 30,
                      bottom: 15,
                      left: 30,
                      right: 30,
                    ),
                    width: size.width,
                    height: 35,
                    borderRadius: 20,
                    linearGradient: AppColors.customGlassIconButtonGradient,
                    border: 2,
                    blur: 3,
                    borderGradient:
                        AppColors.customGlassIconButtonBorderGradient,
                    child: Center(
                      child: (emailVisibility)
                          ? Text(
                              "Hide Email",
                              style: AppColors.subHeadingTextStyle,
                            )
                          : Text(
                              "Show Email",
                              style: AppColors.subHeadingTextStyle,
                            ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (() {
                    setState(() {
                      phoneVisibility = !phoneVisibility;
                    });
                  }),
                  child: GlassmorphicContainer(
                    margin: const EdgeInsets.only(
                      top: 10,
                      bottom: 15,
                      left: 30,
                      right: 30,
                    ),
                    width: size.width,
                    height: 35,
                    borderRadius: 20,
                    linearGradient: AppColors.customGlassIconButtonGradient,
                    border: 2,
                    blur: 3,
                    borderGradient:
                        AppColors.customGlassIconButtonBorderGradient,
                    child: Center(
                      child: (phoneVisibility)
                          ? Text(
                              "Remove Phone Number",
                              style: AppColors.subHeadingTextStyle,
                            )
                          : Text(
                              "Add Phone Number",
                              style: AppColors.subHeadingTextStyle,
                            ),
                    ),
                  ),
                ),
                if (phoneVisibility)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 30,
                      right: 30,
                      bottom: 10,
                    ),
                    child: Consumer<AllAppProviders>(
                      builder: (allAppContext, allAppProvider, allAppChild) {
                        return TextFormField(
                          controller: _phoneController,
                          validator: ((number) {
                            if (number!.isEmpty) {
                              return "Please Enter a Phone Number";
                            } else if (!RegExp(
                                    r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
                                .hasMatch(number)) {
                              return "Please Enter a Valid Phone Number";
                            }
                            return null;
                          }),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: const TextStyle(
                            color: AppColors.white,
                          ),
                          keyboardType: TextInputType.phone,
                          cursorColor: AppColors.white,
                          onChanged: ((phoneNumber) {
                            allAppProvider.phNumberFunc(phoneNumber);
                          }),
                          decoration: InputDecoration(
                            errorStyle: const TextStyle(
                              overflow: TextOverflow.clip,
                            ),
                            prefixIcon: CountryCodePicker(
                              initialSelection: "IN",
                              showCountryOnly: true,
                              textStyle: const TextStyle(
                                color: AppColors.white,
                              ),
                              onInit: ((code) {
                                Future.delayed(
                                  Duration.zero,
                                  (() {
                                    allAppProvider.phCodeFunc(code!.dialCode!);
                                  }),
                                );
                              }),
                              onChanged: ((code) {
                                log(code.dialCode.toString());
                                Future.delayed(
                                  Duration.zero,
                                  (() {
                                    allAppProvider.phCodeFunc(code.dialCode!);
                                  }),
                                );
                              }),
                            ),
                            prefixStyle: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                            hintText: "Enter Your Ph No.",
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
                        );
                      },
                    ),
                  ),
                GestureDetector(
                  onTap: (() {
                    setState(() {
                      desVisibility = !desVisibility;
                    });
                  }),
                  child: GlassmorphicContainer(
                    margin: const EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                      left: 30,
                      right: 30,
                    ),
                    width: size.width,
                    height: 35,
                    borderRadius: 20,
                    linearGradient: AppColors.customGlassIconButtonGradient,
                    border: 2,
                    blur: 3,
                    borderGradient:
                        AppColors.customGlassIconButtonBorderGradient,
                    child: Center(
                      child: (desVisibility)
                          ? Text(
                              "Remove Custom Description",
                              style: AppColors.subHeadingTextStyle,
                            )
                          : Text(
                              "Add Custom Description",
                              style: AppColors.subHeadingTextStyle,
                            ),
                    ),
                  ),
                ),
                if (desVisibility)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 30,
                      right: 30,
                      bottom: 10,
                    ),
                    child: Consumer<AllAppProviders>(
                      builder: (allAppContext, allAppProvider, allAppChild) {
                        return TextFormField(
                          scrollPhysics: AppColors.scrollPhysics,
                          maxLines: 5,
                          minLines: 1,
                          onChanged: ((description) {
                            allAppProvider.desFunc(description.trim());
                          }),
                          decoration: InputDecoration(
                            errorStyle: const TextStyle(
                              overflow: TextOverflow.clip,
                            ),
                            prefixIcon: const Icon(
                              Icons.description,
                              color: AppColors.white,
                            ),
                            prefixStyle: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                            hintText: "Description",
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _desController,
                          keyboardType: TextInputType.text,
                          cursorColor: AppColors.white,
                          style: const TextStyle(
                            color: AppColors.white,
                          ),
                        );
                      },
                    ),
                  ),
                GestureDetector(
                  onTap: (() {
                    setState(() {
                      skillVisibility = !skillVisibility;
                    });
                  }),
                  child: GlassmorphicContainer(
                    margin: const EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                      left: 30,
                      right: 30,
                    ),
                    width: size.width,
                    height: 35,
                    borderRadius: 20,
                    linearGradient: AppColors.customGlassIconButtonGradient,
                    border: 2,
                    blur: 3,
                    borderGradient:
                        AppColors.customGlassIconButtonBorderGradient,
                    child: Center(
                      child: (skillVisibility)
                          ? Text(
                              "Remove Key Skill",
                              style: AppColors.subHeadingTextStyle,
                            )
                          : Text(
                              "Add Key Skill",
                              style: AppColors.subHeadingTextStyle,
                            ),
                    ),
                  ),
                ),
                if (skillVisibility)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 30,
                      right: 30,
                      bottom: 10,
                    ),
                    child: Consumer<AllAppProviders>(
                      builder: (allAppContext, allAppProvider, allAppChild) {
                        return TextFormField(
                          scrollPhysics: AppColors.scrollPhysics,
                          maxLines: 5,
                          minLines: 1,
                          onChanged: ((keySkill) {
                            allAppProvider.keySkillFunc(keySkill.trim());
                          }),
                          decoration: InputDecoration(
                            errorStyle: const TextStyle(
                              overflow: TextOverflow.clip,
                            ),
                            prefixIcon: const Icon(
                              Icons.school,
                              color: AppColors.white,
                            ),
                            prefixStyle: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                            hintText: "Key Skill",
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _keySkillController,
                          keyboardType: TextInputType.text,
                          cursorColor: AppColors.white,
                          style: const TextStyle(
                            color: AppColors.white,
                          ),
                        );
                      },
                    ),
                  ),
                Consumer<AllAppProviders>(
                    builder: (allAppContext, allAppProvider, allAppChild) {
                  return GestureDetector(
                    onTap: (() async {
                      if (phoneVisibility) {
                        if (_phoneController.text.isEmpty) {
                          allAppProvider.isLoadingFunc(false);
                          AppSnackbar().customizedAppSnackbar(
                            message: "Please enter your phone number",
                            context: context,
                          );
                        }
                      }

                      if (desVisibility) {
                        if (_desController.text.isEmpty) {
                          allAppProvider.isLoadingFunc(false);
                          AppSnackbar().customizedAppSnackbar(
                            message: "Please enter new description",
                            context: context,
                          );
                        }
                      }

                      allAppProvider.isLoadingFunc(true);

                      await rewardedAd?.show(
                        onUserEarnedReward: ((ad, point) {}),
                      );

                      rewardedAd?.fullScreenContentCallback =
                          FullScreenContentCallback(
                        onAdClicked: ((ad) {}),
                        onAdDismissedFullScreenContent: ((ad) async {
                          // print("ad dismissed");
                          log(ad.adUnitId.toString());
                          final visitingCard =
                              await _screenshotController.capture();
                          final directory = await getTemporaryDirectory();
                          final path =
                              "${directory.path}/achivie_visiting_card.png";
                          File(path).writeAsBytesSync(visitingCard!);
                          const link = "https://achivie.com";

                          await Share.shareFiles(
                            [path],
                            text:
                                "Excited to share my progress on Achieve! 🎉💪 I've been making great strides towards my goals and can't wait to see what else I can accomplish. Start your journey towards success today with Achieve: $link",
                          ).then((value) {
                            ScaffoldMessenger.of(allAppContext).showSnackBar(
                              AppSnackbar().customizedAppSnackbar(
                                message:
                                    "Your progress card was shared successfully",
                                context: allAppContext,
                              ),
                            );
                            Navigator.pop(context);
                          });
                        }),
                        onAdFailedToShowFullScreenContent: ((ad, err) {
                          ad.dispose();
                          // print("ad error $err");
                        }),
                        onAdImpression: ((ad) {}),
                        onAdShowedFullScreenContent: ((ad) {
                          // print("ad shown ${ad.responseInfo}");
                        }),
                        onAdWillDismissFullScreenContent: ((ad) async {
                          log(ad.adUnitId.toString());
                          final visitingCard =
                              await _screenshotController.capture();
                          final directory = await getTemporaryDirectory();
                          final path =
                              "${directory.path}/achivie_visiting_card.png";
                          File(path).writeAsBytesSync(visitingCard!);
                          const link = "https://achivie.com";

                          await Share.shareFiles(
                            [path],
                            text:
                                "Excited to share my progress on Achieve! 🎉💪 I've been making great strides towards my goals and can't wait to see what else I can accomplish. Start your journey towards success today with Achieve: $link",
                          ).then((value) {
                            ScaffoldMessenger.of(allAppContext).showSnackBar(
                              AppSnackbar().customizedAppSnackbar(
                                message:
                                    "Your progress card was shared successfully",
                                context: allAppContext,
                              ),
                            );

                            Navigator.pop(context);
                          });
                        }),
                      );

                      allAppProvider.isLoadingFunc(false);

                      // final date = DateTime.now()
                      //     .toIso8601String()
                      //     .replaceAll(".", "-")
                      //     .replaceAll(":", "-");
                      //
                      // final savedFile =
                      //     await ImageGallerySaver.saveImage(
                      //         visitingCard!,
                      //         name: "achivie_visiting_card_$date");

                      // XFile file = XFile.fromData(visitingCard!);
                      // final image = XFile(path);
                      // image.(visitingCard!);
                    }),
                    child: GlassmorphicContainer(
                      margin: const EdgeInsets.only(
                        top: 15,
                        bottom: 15,
                        left: 30,
                        right: 30,
                      ),
                      width: size.width,
                      height: 35,
                      borderRadius: 20,
                      linearGradient: AppColors.customGlassIconButtonGradient,
                      border: 2,
                      blur: 3,
                      borderGradient:
                          AppColors.customGlassIconButtonBorderGradient,
                      child: Center(
                        child: (allAppProvider.isLoading)
                            ? Lottie.asset("assets/loading-animation.json")
                            : Text(
                                "Share Your Progress",
                                style: AppColors.subHeadingTextStyle,
                              ),
                      ),
                    ),
                  );
                }),
                // if (shareVisibility)
                //   Container(
                //     margin: const EdgeInsets.only(
                //       top: 10,
                //       left: 30,
                //       right: 30,
                //       bottom: 10,
                //     ),
                //     padding: EdgeInsets.symmetric(
                //       horizontal: 15,
                //       vertical: 10,
                //     ),
                //     width: size.width,
                //     decoration: BoxDecoration(
                //       border: Border.all(
                //         color: AppColors.white,
                //       ),
                //       borderRadius: BorderRadius.circular(15),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.stretch,
                //       children: [
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //           children: [
                //             GestureDetector(
                //               onTap: (() async {
                //                 if (phoneVisibility) {
                //                   if (_phoneController.text.isEmpty) {
                //                     AppSnackbar().customizedAppSnackbar(
                //                       message: "Please enter your phone number",
                //                       context: context,
                //                     );
                //                   }
                //                 }
                //
                //                 if (desVisibility) {
                //                   if (_desController.text.isEmpty) {
                //                     AppSnackbar().customizedAppSnackbar(
                //                       message: "Please enter new description",
                //                       context: context,
                //                     );
                //                   }
                //                 }
                //
                //                 final visitingCard =
                //                     await _screenshotController.capture();
                //
                //                 // final date = DateTime.now()
                //                 //     .toIso8601String()
                //                 //     .replaceAll(".", "-")
                //                 //     .replaceAll(":", "-");
                //                 //
                //                 // final savedFile =
                //                 //     await ImageGallerySaver.saveImage(
                //                 //         visitingCard!,
                //                 //         name: "achivie_visiting_card_$date");
                //
                //                 final directory = await getTemporaryDirectory();
                //                 final path =
                //                     "${directory.path}/achivie_visiting_card.png";
                //                 final image = XFile(path);
                //                 // image.writeAsBytesSync(visitingCard!);
                //
                //                 const link =
                //                     "https://play.google.com/store/apps/details?id=com.apnatime&ref=w&utm_source=Apna+Main+Website&utm_medium=Internal+Navigation&utm_campaign=Internal+Navigation&_height=900&_width=1440&_branch_match_id=1165740843525340250&_branch_referrer=H4sIAAAAAAAAA8soKSkottLXz9FLLMhL1EvO189yci02cXRPz6hMso/PSM1MzyixtTQwUIsvz0wpybA1NDExAABv9FuFNQAAAA%3D%3D&pli=1";
                //
                //                 await Share.shareXFiles([image],
                //                     text:
                //                         "Excited to share my progress on Achieve! 🎉💪 I've been making great strides towards my goals and can't wait to see what else I can accomplish. Start your journey towards success today with Achieve: $link");
                //               }),
                //               child: Container(
                //                 width: 40,
                //                 height: 40,
                //                 decoration: BoxDecoration(
                //                   image: DecorationImage(
                //                     image: AssetImage(
                //                       "assets/social-icons/colored-whatsaap-icon.png",
                //                     ),
                //                   ),
                //                   shape: BoxShape.circle,
                //                 ),
                //               ),
                //             ),
                //             GestureDetector(
                //               onTap: (() {}),
                //               child: Container(
                //                 width: 40,
                //                 height: 40,
                //                 decoration: BoxDecoration(
                //                   image: DecorationImage(
                //                     image: AssetImage(
                //                       "assets/social-icons/colored-linkedin-icon.png",
                //                     ),
                //                   ),
                //                   shape: BoxShape.circle,
                //                 ),
                //               ),
                //             ),
                //             GestureDetector(
                //               onTap: (() {}),
                //               child: Container(
                //                 width: 40,
                //                 height: 40,
                //                 decoration: BoxDecoration(
                //                   image: DecorationImage(
                //                     image: AssetImage(
                //                       "assets/social-icons/colored-facebook-icon.png",
                //                     ),
                //                   ),
                //                   shape: BoxShape.circle,
                //                 ),
                //               ),
                //             ),
                //             GestureDetector(
                //               onTap: (() {}),
                //               child: Container(
                //                 width: 40,
                //                 height: 40,
                //                 decoration: BoxDecoration(
                //                   image: DecorationImage(
                //                     image: AssetImage(
                //                       "assets/social-icons/colored-twitter-icon.png",
                //                     ),
                //                   ),
                //                   shape: BoxShape.circle,
                //                 ),
                //               ),
                //             ),
                //           ],
                //         )
                //       ],
                //     ),
                //   ),
                Consumer<AllAppProviders>(
                    builder: (allAppContext, allAppProvider, allAppChild) {
                  return GestureDetector(
                    onTap: (() async {
                      allAppProvider.isLoadingFunc(true);

                      await rewardedAd2?.show(
                        onUserEarnedReward: ((ad, point) {}),
                      );

                      rewardedAd2?.fullScreenContentCallback =
                          FullScreenContentCallback(
                        onAdClicked: ((ad) {}),
                        onAdDismissedFullScreenContent: ((ad) async {
                          // print("ad dismissed");
                          final visitingCard =
                              await _screenshotController.capture();

                          final date = DateTime.now()
                              .toIso8601String()
                              .replaceAll(".", "-")
                              .replaceAll(":", "-");

                          await ImageGallerySaver.saveImage(
                            visitingCard!,
                            name: "achivie_visiting_card_$date",
                            quality: 100,
                            isReturnImagePathOfIOS: true,
                          );

                          ScaffoldMessenger.of(allAppContext).showSnackBar(
                            AppSnackbar().customizedAppSnackbar(
                              message:
                                  "Your progress card was saved successfully",
                              context: allAppContext,
                            ),
                          );
                        }),
                        onAdFailedToShowFullScreenContent: ((ad, err) {
                          ad.dispose();
                          // print("ad error $err");
                        }),
                        onAdImpression: ((ad) {}),
                        onAdShowedFullScreenContent: ((ad) {
                          // print("ad shown ${ad.responseInfo}");
                        }),
                        onAdWillDismissFullScreenContent: ((ad) async {
                          final visitingCard =
                              await _screenshotController.capture();

                          final date = DateTime.now()
                              .toIso8601String()
                              .replaceAll(".", "-")
                              .replaceAll(":", "-");

                          await ImageGallerySaver.saveImage(
                            visitingCard!,
                            name: "achivie_visiting_card_$date",
                            quality: 100,
                            isReturnImagePathOfIOS: true,
                          );

                          ScaffoldMessenger.of(allAppContext).showSnackBar(
                            AppSnackbar().customizedAppSnackbar(
                              message:
                                  "Your progress card was saved successfully",
                              context: allAppContext,
                            ),
                          );
                        }),
                      );

                      log("saved");

                      allAppProvider.isLoadingFunc(false);
                    }),
                    child: GlassmorphicContainer(
                      margin: const EdgeInsets.only(
                        top: 15,
                        bottom: 15,
                        left: 30,
                        right: 30,
                      ),
                      width: size.width,
                      height: 35,
                      borderRadius: 20,
                      linearGradient: AppColors.customGlassIconButtonGradient,
                      border: 2,
                      blur: 3,
                      borderGradient:
                          AppColors.customGlassIconButtonBorderGradient,
                      child: Center(
                        child: (allAppProvider.isLoading)
                            ? Lottie.asset("assets/loading-animation.json")
                            : Text(
                                "Save Your Profile Card",
                                style: AppColors.subHeadingTextStyle,
                              ),
                      ),
                    ),
                  );
                }),
                if (isNativeAdLoaded)
                  NativeAdContainer(
                    size: MediaQuery.of(context).size,
                    nativeAd: nativeAd!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
