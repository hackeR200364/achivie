import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:task_app/providers/app_providers.dart';
import 'package:telephony/telephony.dart';

import '../Utils/custom_text_field_utils.dart';
import '../Utils/snackbar_utils.dart';
import '../styles.dart';

class SendSMSScreen extends StatefulWidget {
  const SendSMSScreen({Key? key}) : super(key: key);

  @override
  State<SendSMSScreen> createState() => _SendSMSScreenState();
}

class _SendSMSScreenState extends State<SendSMSScreen> {
  late TextEditingController _bodyController;
  BannerAd? bannerAd;
  late FocusNode focusNode;

  @override
  void initState() {
    _bodyController = TextEditingController();
    focusNode = FocusNode();
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      listener: BannerAdListener(
        onAdLoaded: ((ad) {
          print("Banner ad loaded ${ad.adUnitId}");
        }),
      ),
      request: AdRequest(),
    );
    bannerAd!.load();
    super.initState();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundColour,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: Image.asset(
                "assets/motivational-pics/sms-send-screen-bg.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              child: Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.mainColor.withOpacity(0.7),
                      AppColors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: size.height / 6,
              child: GlassmorphicContainer(
                margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.5,
                borderRadius: 20,
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
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Please enter your query",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: size.height / 30,
                      ),
                      Column(
                        children: [
                          CustomTextField(
                            maxLen: ((size.height / 100).toInt() < 2)
                                ? 2
                                : (size.height / 100).toInt(),
                            minLen: 1,
                            controller: _bodyController,
                            hintText: "Body",
                            keyboard: TextInputType.multiline,
                            isPassField: false,
                            isEmailField: false,
                            isPassConfirmField: false,
                            icon: Icons.sms,
                            focusNode: focusNode,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Consumer<AllAppProviders>(builder:
                              (allAppContext, allAppProvider, allAppChild) {
                            return InkWell(
                              onTap: (allAppProvider.isLoading)
                                  ? null
                                  : (() async {
                                      focusNode.unfocus();
                                      allAppProvider.isLoadingFunc(true);
                                      if (_bodyController.text.isNotEmpty) {
                                        var phoneStatus =
                                            await Permission.phone.status;
                                        if (phoneStatus.isRestricted) {
                                          openAppSettings();
                                          allAppProvider.isLoadingFunc(false);
                                        }
                                        if (phoneStatus.isPermanentlyDenied) {
                                          openAppSettings();
                                          allAppProvider.isLoadingFunc(false);
                                        }
                                        if (phoneStatus.isDenied) {
                                          Permission.phone.request();
                                          allAppProvider.isLoadingFunc(false);
                                        }
                                        if (phoneStatus.isGranted) {
                                          await Telephony.instance.sendSms(
                                            to: "8583006460",
                                            message:
                                                _bodyController.text.trim(),
                                            statusListener: ((statusListener) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                AppSnackbar()
                                                    .customizedAppSnackbar(
                                                  message:
                                                      "Your message ${statusListener.name.toLowerCase()} successfully",
                                                  context: context,
                                                ),
                                              );
                                            }),
                                          );
                                          _bodyController.clear();
                                          allAppProvider.isLoadingFunc(false);
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          AppSnackbar().customizedAppSnackbar(
                                            message:
                                                "Please fill the fields properly",
                                            context: context,
                                          ),
                                        );
                                      }
                                    }),
                              child: GlassmorphicContainer(
                                width: MediaQuery.of(context).size.width / 1.5,
                                height: 50,
                                borderRadius: 20,
                                linearGradient: LinearGradient(
                                  colors: [
                                    AppColors.backgroundColour.withOpacity(0.3),
                                    AppColors.backgroundColour.withOpacity(0.5),
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
                                child: Center(
                                  child: Text(
                                    "Send SMS",
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 15,
              left: 20,
              child: GlassmorphicContainer(
                width: 40,
                height: 40,
                borderRadius: 25,
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
                child: IconButton(
                  onPressed: (() {
                    focusNode.unfocus();
                    ZoomDrawer.of(context)!.toggle();
                  }),
                  icon: Icon(
                    Icons.menu,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: bannerAd!.size.height.toDouble(),
                width: MediaQuery.of(context).size.width,
                child: AdWidget(
                  ad: bannerAd!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
