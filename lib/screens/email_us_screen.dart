import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';

class EmailUSScreen extends StatefulWidget {
  const EmailUSScreen({Key? key}) : super(key: key);

  @override
  State<EmailUSScreen> createState() => _EmailUSScreenState();
}

class _EmailUSScreenState extends State<EmailUSScreen> {
  late TextEditingController _bodyController;
  late TextEditingController _subjectController;
  BannerAd? bannerAd;
  late FocusNode subjectFocusNode;
  late FocusNode bodyFocusNode;
  late NativeAd nativeAd;
  bool isNativeAdLoaded = false;
  bool isBannerAdLoaded = false;

  @override
  void initState() {
    _bodyController = TextEditingController();
    _subjectController = TextEditingController();
    subjectFocusNode = FocusNode();
    bodyFocusNode = FocusNode();
    nativeAd = NativeAd(
      adUnitId: "ca-app-pub-3940256099942544/2247696110",
      factoryId: "listTile",
      listener: NativeAdListener(
        onAdLoaded: ((ad) {
          setState(() {
            isNativeAdLoaded = true;
          });
        }),
        onAdFailedToLoad: ((ad, err) {
          nativeAd.dispose();
          print("Native ad failed : ${err.message}");
        }),
      ),
      request: AdRequest(),
    );
    nativeAd.load();
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
      request: AdRequest(),
    );
    bannerAd!.load();
    super.initState();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _subjectController.dispose();
    bannerAd?.dispose();
    nativeAd.dispose();
    bodyFocusNode.dispose();
    subjectFocusNode.dispose();
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
        title: CustomAppBarTitle(
          heading: "Email us",
        ),
      ),
      bottomNavigationBar: CustomBottmNavBarWithBannerAd(
        bannerAd: bannerAd,
      ),
      body: SingleChildScrollView(
        child: EmailUsScreenColumn(
          subjectFocusNode: subjectFocusNode,
          subjectController: _subjectController,
          bodyFocusNode: bodyFocusNode,
          size: size,
          bodyController: _bodyController,
          isNativeAdLoaded: isNativeAdLoaded,
          nativeAd: nativeAd,
        ),
      ),
    );
  }
}
