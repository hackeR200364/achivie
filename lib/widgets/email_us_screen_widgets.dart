import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';

import '../Utils/custom_glass_icon.dart';
import '../Utils/custom_text_field_utils.dart';
import '../Utils/snackbar_utils.dart';
import '../styles.dart';

class EmailUsScreenColumn extends StatefulWidget {
  EmailUsScreenColumn({
    super.key,
    required this.subjectFocusNode,
    required TextEditingController subjectController,
    required this.bodyFocusNode,
    required this.size,
    required TextEditingController bodyController,
    required this.isNativeAdLoaded,
    required this.nativeAd,
    // required this.rewardedAd,
  })  : _subjectController = subjectController,
        _bodyController = bodyController;

  final FocusNode subjectFocusNode;
  final TextEditingController _subjectController;
  final FocusNode bodyFocusNode;
  final Size size;
  final TextEditingController _bodyController;
  final bool isNativeAdLoaded;
  final NativeAd nativeAd;
  // RewardedAd? rewardedAd;

  @override
  State<EmailUsScreenColumn> createState() => _EmailUsScreenColumnState();
}

class _EmailUsScreenColumnState extends State<EmailUsScreenColumn> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const UpperIconContainer(
          icon: CupertinoIcons.mail_solid,
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 15,
            right: 15,
          ),
          child: Column(
            children: [
              const HeadingContainer(),
              CustomTextField(
                focusNode: widget.subjectFocusNode,
                controller: widget._subjectController,
                hintText: "Subject",
                keyboard: TextInputType.text,
                isPassField: false,
                isEmailField: false,
                isPassConfirmField: false,
                icon: Icons.subject,
              ),
              CustomTextField(
                focusNode: widget.bodyFocusNode,
                maxLen: (widget.size.height ~/ 100 < 2)
                    ? 2
                    : widget.size.height ~/ 100,
                minLen: 1,
                controller: widget._bodyController,
                hintText: "Body",
                keyboard: TextInputType.multiline,
                isPassField: false,
                isEmailField: false,
                isPassConfirmField: false,
                icon: Icons.description,
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        if (widget.isNativeAdLoaded)
          NativeAdContainer(
            size: widget.size,
            nativeAd: widget.nativeAd,
          ),
        CustomBottomSubmitButton(
          title: "Send Email",
          onTap: (() async {
            HapticFeedback.mediumImpact();

            widget.subjectFocusNode.unfocus();
            widget.bodyFocusNode.unfocus();
            if (widget._subjectController.text.isNotEmpty &&
                widget._bodyController.text.isNotEmpty) {
              setState(() {
                isLoading = true;
              });

              // await widget.rewardedAd?.show(
              //   onUserEarnedReward: ((ad, point) {}),
              // );

              // widget.rewardedAd?.fullScreenContentCallback =
              //     FullScreenContentCallback(
              //   onAdClicked: ((ad) {}),
              //   onAdDismissedFullScreenContent: ((ad) async {
              //     // print("ad dismissed");
              //     Email email = Email(
              //       subject: widget._subjectController.text.trim(),
              //       body: widget._bodyController.text.trim(),
              //       recipients: [
              //         "hello@achivie.com",
              //       ],
              //     );
              //
              //     String errorRes = "";
              //     try {
              //       await FlutterEmailSender.send(email).then((value) {
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           AppSnackbar().customizedAppSnackbar(
              //             message: "Email sent successfully",
              //             context: context,
              //           ),
              //         );
              //       });
              //     } catch (error) {
              //       // print(error);
              //       errorRes = error.toString();
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         AppSnackbar().customizedAppSnackbar(
              //           message: "Error $errorRes",
              //           context: context,
              //         ),
              //       );
              //     }
              //
              //     if (!mounted) return;
              //
              //     widget._bodyController.clear();
              //     widget._subjectController.clear();
              //   }),
              //   onAdFailedToShowFullScreenContent: ((ad, err) {
              //     ad.dispose();
              //     // print("ad error $err");
              //   }),
              //   onAdImpression: ((ad) {}),
              //   onAdShowedFullScreenContent: ((ad) {
              //     // print("ad shown ${ad.responseInfo}");
              //   }),
              //   onAdWillDismissFullScreenContent: ((ad) async {
              //     Email email = Email(
              //       subject: widget._subjectController.text.trim(),
              //       body: widget._bodyController.text.trim(),
              //       recipients: [
              //         "hello@achivie.com",
              //       ],
              //     );
              //
              //     String errorRes = "";
              //     try {
              //       await FlutterEmailSender.send(email).then((value) {
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           AppSnackbar().customizedAppSnackbar(
              //             message: "Email sent successfully",
              //             context: context,
              //           ),
              //         );
              //       });
              //     } catch (error) {
              //       // print(error);
              //       errorRes = error.toString();
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         AppSnackbar().customizedAppSnackbar(
              //           message: "Error $errorRes",
              //           context: context,
              //         ),
              //       );
              //     }
              //
              //     if (!mounted) return;
              //
              //     widget._bodyController.clear();
              //     widget._subjectController.clear();
              //   }),
              // );

              Email email = Email(
                subject: widget._subjectController.text.trim(),
                body: widget._bodyController.text.trim(),
                recipients: [
                  "hello@achivie.com",
                ],
              );

              String errorRes = "";
              try {
                await FlutterEmailSender.send(email).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    AppSnackbar().customizedAppSnackbar(
                      message: "Email sent successfully",
                      context: context,
                    ),
                  );
                });
              } catch (error) {
                // print(error);
                errorRes = error.toString();
                ScaffoldMessenger.of(context).showSnackBar(
                  AppSnackbar().customizedAppSnackbar(
                    message: "Error $errorRes",
                    context: context,
                  ),
                );
              }

              if (!mounted) return;

              widget._bodyController.clear();
              widget._subjectController.clear();

              setState(() {
                isLoading = false;
              });
            } else {
              // print(widget.size.height ~/ 100);
              ScaffoldMessenger.of(context).showSnackBar(
                AppSnackbar().customizedAppSnackbar(
                  message: "Please fill the fields properly",
                  context: context,
                ),
              );
            }
          }),
          isNativeAdLoaded: widget.isNativeAdLoaded,
          size: widget.size,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class CustomBottmNavBarWithBannerAd extends StatelessWidget {
  const CustomBottmNavBarWithBannerAd({
    super.key,
    required this.bannerAd,
    required this.color,
  });

  final BannerAd? bannerAd;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      height: bannerAd!.size.height.toDouble(),
      width: MediaQuery.of(context).size.width,
      child: AdWidget(
        ad: bannerAd!,
      ),
    );
  }
}

class CustomAppBarTitle extends StatelessWidget {
  const CustomAppBarTitle({
    super.key,
    required this.heading,
  });

  final String heading;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 41,
        borderRadius: 40,
        linearGradient: AppColors.customGlassIconButtonGradient,
        border: 2,
        blur: 4,
        borderGradient: AppColors.customGlassIconButtonBorderGradient,
        child: CustomApBarTitleChildText(
          heading: heading,
        ),
      ),
    );
  }
}

class CustomApBarTitleChildText extends StatelessWidget {
  const CustomApBarTitleChildText({
    super.key,
    required this.heading,
  });

  final String heading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        heading,
        style: const TextStyle(
          overflow: TextOverflow.fade,
          fontSize: 17,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
    );
  }
}

class CustomAppBarLeading extends StatelessWidget {
  const CustomAppBarLeading({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: CustomGlassIconButton(
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }
}

class UpperIconContainer extends StatelessWidget {
  const UpperIconContainer({
    super.key,
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppColors.backgroundColour,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            MediaQuery.of(context).size.width / 3,
          ),
        ),
      ),
      child: Center(
        child: GlassmorphicContainer(
          margin: const EdgeInsets.only(
            top: 20,
            bottom: 30,
          ),
          width: 100,
          height: 100,
          borderRadius: 50,
          linearGradient: AppColors.customGlassIconButtonGradient,
          border: 2,
          blur: 4,
          borderGradient: AppColors.customGlassIconButtonBorderGradient,
          child: Center(
            child: Icon(
              icon,
              color: AppColors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomBottomSubmitButton extends StatelessWidget {
  const CustomBottomSubmitButton({
    super.key,
    required this.onTap,
    required this.isNativeAdLoaded,
    required this.size,
    required this.title,
    required this.isLoading,
  });

  final bool isNativeAdLoaded, isLoading;
  final Size size;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (isNativeAdLoaded) ? size.height / 6 : size.height / 3,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundColour,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            MediaQuery.of(context).size.width / 3,
          ),
        ),
      ),
      child: Center(
        child: (isLoading)
            ? Lottie.asset("assets/loading-animation.json")
            : InkWell(
                onTap: onTap,
                child: SubmitButtonChildDesign(
                  title: title,
                ),
              ),
      ),
    );
  }
}

class SubmitButtonChildDesign extends StatelessWidget {
  const SubmitButtonChildDesign({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: MediaQuery.of(context).size.width / 1.5,
      height: 50,
      borderRadius: 20,
      linearGradient: AppColors.customGlassIconButtonGradient,
      border: 2,
      blur: 4,
      borderGradient: AppColors.customGlassIconButtonBorderGradient,
      child: SubmitButtonChildButtonText(
        title: title,
      ),
    );
  }
}

class SubmitButtonChildButtonText extends StatelessWidget {
  const SubmitButtonChildButtonText({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class NativeAdContainer extends StatelessWidget {
  const NativeAdContainer({
    super.key,
    required this.size,
    required this.nativeAd,
  });

  final Size size;
  final NativeAd nativeAd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 20,
        left: 30,
        right: 30,
      ),
      width: double.infinity,
      height: size.height / 7.5,
      decoration: BoxDecoration(
        color: AppColors.backgroundColour,
        borderRadius: BorderRadius.circular(15),
      ),
      child: AdWidget(
        ad: nativeAd,
      ),
    );
  }
}

class HeadingContainer extends StatelessWidget {
  const HeadingContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
        top: 10,
        left: 15,
        right: 15,
      ),
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.backgroundColour,
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Center(
        child: Text(
          "Enter your words",
          style: AppColors.headingTextStyle,
        ),
      ),
    );
  }
}
