import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

import '../Utils/custom_text_field_utils.dart';
import '../Utils/snackbar_utils.dart';
import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';

class SendSMSScreen extends StatefulWidget {
  const SendSMSScreen({Key? key}) : super(key: key);

  @override
  State<SendSMSScreen> createState() => _SendSMSScreenState();
}

class _SendSMSScreenState extends State<SendSMSScreen> {
  late TextEditingController _bodyController;
  late BannerAd bannerAd;
  late NativeAd nativeAd;
  late FocusNode focusNode;
  bool isBannerAdLoaded = false, isNativeAdLoaded = false, isLoading = false;
  bool pageLoading = true;

  @override
  void initState() {
    _bodyController = TextEditingController();
    focusNode = FocusNode();
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      listener: BannerAdListener(
        onAdLoaded: ((ad) {
          setState(() {
            isBannerAdLoaded = true;
          });
        }),
      ),
      request: const AdRequest(),
    );
    bannerAd.load();
    nativeAd = NativeAd(
      adUnitId: "ca-app-pub-3940256099942544/2247696110",
      factoryId: "listTile",
      listener: NativeAdListener(
        onAdLoaded: ((ad) {
          setState(() {
            isNativeAdLoaded = true;
            pageLoading = false;
          });
        }),
        onAdFailedToLoad: ((ad, err) {
          nativeAd.dispose();
          // print("Native ad failed : ${err.message}");
        }),
      ),
      request: const AdRequest(),
    );
    nativeAd.load();

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
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColour,
        elevation: 0,
        leading: CustomAppBarLeading(
          icon: Icons.menu,
          onPressed: (() {
            ZoomDrawer.of(context)!.toggle();
          }),
        ),
        title: const CustomAppBarTitle(
          heading: "Send us SMS",
        ),
      ),
      bottomNavigationBar: CustomBottmNavBarWithBannerAd(
        color: (isBannerAdLoaded)
            ? AppColors.backgroundColour
            : AppColors.mainColor,
        bannerAd: bannerAd,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                const UpperIconContainer(
                  icon: Icons.sms,
                ),
                SizedBox(
                  height: size.height / 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Column(
                    children: [
                      const HeadingContainer(),
                      CustomTextField(
                        focusNode: focusNode,
                        maxLen:
                            (size.height ~/ 100 < 2) ? 2 : size.height ~/ 100,
                        minLen: 1,
                        controller: _bodyController,
                        hintText: "Body",
                        keyboard: TextInputType.multiline,
                        isPassField: false,
                        isEmailField: false,
                        isPassConfirmField: false,
                        icon: Icons.description,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height / 25,
                ),
                if (isNativeAdLoaded)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: size.height / 25,
                    ),
                    child: NativeAdContainer(
                      size: size,
                      nativeAd: nativeAd,
                    ),
                  ),
                CustomBottomSubmitButton(
                  isLoading: isLoading,
                  title: "Send SMS",
                  isNativeAdLoaded: isNativeAdLoaded,
                  size: size,
                  onTap: (() async {
                    focusNode.unfocus();
                    setState(() {
                      isLoading = true;
                    });
                    if (_bodyController.text.isNotEmpty) {
                      var phoneStatus = await Permission.phone.status;
                      if (phoneStatus.isRestricted) {
                        openAppSettings();
                        setState(() {
                          isLoading = false;
                        });
                      }
                      if (phoneStatus.isPermanentlyDenied) {
                        openAppSettings();
                        setState(() {
                          isLoading = false;
                        });
                      }
                      if (phoneStatus.isDenied) {
                        Permission.phone.request();
                        setState(() {
                          isLoading = false;
                        });
                      }
                      if (phoneStatus.isGranted) {
                        await Telephony.instance.sendSms(
                          to: "8583006460",
                          message: _bodyController.text.trim(),
                          statusListener: ((statusListener) {
                            // print(statusListener.name);
                            ScaffoldMessenger.of(context).showSnackBar(
                              AppSnackbar().customizedAppSnackbar(
                                message:
                                    "Your message ${statusListener.name.toLowerCase()} successfully",
                                context: context,
                              ),
                            );
                          }),
                        );
                        _bodyController.clear();
                        setState(() {
                          isLoading = false;
                        });
                      }
                    } else {
                      // print("empty");
                      ScaffoldMessenger.of(context).showSnackBar(
                        AppSnackbar().customizedAppSnackbar(
                          message: "Please fill the fields properly",
                          context: context,
                        ),
                      );
                    }
                  }),
                )
              ],
            ),
            if (pageLoading)
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    color: AppColors.mainColor,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
