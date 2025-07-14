import 'dart:convert';

import 'package:achivie/services/keys.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../Utils/snackbar_utils.dart';
import '../services/notification_services.dart';
import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  BannerAd? bannerAd;
  bool isBannerAdLoaded = false;

  @override
  void initState() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-7050103229809241/9957831559",
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
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor:
    //         AppColors.mainColor, // Change this color to your desired color
    //   ),
    // );
    super.initState();
  }

  @override
  void dispose() {
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: AppColors
    //         .backgroundColour, // Change this color to your desired color
    //   ),
    // );
    bannerAd?.dispose();
    super.dispose();
  }

  String formattedTime(
    int year,
    int month,
    int day,
    int hour,
    int minute,
  ) =>
      DateFormat.Hm().format(
        DateTime(
          year,
          month,
          day,
          hour,
          minute,
        ),
      );

  String formattedDate(
    int year,
    int month,
    int day,
  ) =>
      DateFormat("dd/MM/yyyy").format(
        DateTime(
          year,
          month,
          day,
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: CustomAppBarLeading(
          icon: CupertinoIcons.back,
          onPressed: (() {
            Navigator.pop(context);
          }),
        ),
        title: Align(
          alignment: Alignment.center,
          child: GlassmorphicContainer(
            width: MediaQuery.of(context).size.width - 70,
            height: 41,
            borderRadius: 40,
            linearGradient: AppColors.customGlassIconButtonGradient,
            border: 2,
            blur: 4,
            borderGradient: AppColors.customGlassIconButtonBorderGradient,
            child: const CustomApBarTitleChildText(
              heading: "Notifications",
            ),
          ),
        ),
      ),
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
      body: CustomScrollView(
        slivers: [
          // SliverToBoxAdapter(
          //   child: SafeArea(
          //     child: Row(
          //       children: [
          //         CustomAppBarLeading(
          //           icon: CupertinoIcons.back,
          //           onPressed: (() {
          //             Navigator.pop(context);
          //           }),
          //         ),
          //         const CustomAppBarTitle(
          //           heading: "Notifications",
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // SliverToBoxAdapter(
          //   child: Container(
          //     margin: EdgeInsets.only(
          //       left: 10,
          //       right: 10,
          //       top: 10,
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         CustomAppBarLeading(
          //           icon: CupertinoIcons.back,
          //           onPressed: (() {
          //             Navigator.pop(context);
          //           }),
          //         ),
          //         Align(
          //           alignment: Alignment.center,
          //           child: GlassmorphicContainer(
          //             width: MediaQuery.of(context).size.width - 70,
          //             height: 41,
          //             borderRadius: 40,
          //             linearGradient: AppColors.customGlassIconButtonGradient,
          //             border: 2,
          //             blur: 4,
          //             borderGradient:
          //                 AppColors.customGlassIconButtonBorderGradient,
          //             child: const CustomApBarTitleChildText(
          //               heading: "Notifications",
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          SliverFillRemaining(
            child: FutureBuilder(
              future: AwesomeNotifications().listScheduledNotifications(),
              builder: (BuildContext notificationContext,
                  AsyncSnapshot<List<NotificationModel>> snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  // log(snapshot.data.toString());
                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 30,
                    ),
                    physics: AppColors.scrollPhysics,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      NotificationModel notification = snapshot.data![index];
                      var response =
                          jsonDecode(snapshot.data![index].toString());
                      // log(snapshot.data![index].toString());
                      // log(response.toString());
                      return Dismissible(
                        key: Key(notification.content!.id.toString()),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          padding: const EdgeInsets.only(left: 15),
                          margin: const EdgeInsets.only(
                            bottom: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: AppColors.white,
                              ),
                            ],
                          ),
                        ),
                        onDismissed: ((direction) async {
                          await NotificationServices()
                              .cancelTaskScheduledNotification(
                            id: notification.content!.id!,
                          );
                          ScaffoldMessenger.of(notificationContext)
                              .showSnackBar(
                            SnackBar(
                              duration: const Duration(hours: 1),
                              margin: const EdgeInsets.only(
                                bottom: 30,
                                left: 15,
                                right: 15,
                              ),
                              behavior: SnackBarBehavior.floating,
                              dismissDirection: DismissDirection.horizontal,
                              backgroundColor: AppColors.backgroundColour,
                              action: SnackBarAction(
                                label: "Undo",
                                onPressed: (() async {
                                  await NotificationServices()
                                      .createScheduledTaskNotification(
                                    id: notification.content!.id!,
                                    title: notification.content!.title!,
                                    body: notification.content!.body!,
                                    payload: notification.content!.body!,
                                    dateTime: DateTime(
                                      response[Keys.schedule]["year"],
                                      response[Keys.schedule]["month"],
                                      response[Keys.schedule]["day"],
                                      response[Keys.schedule]["hour"],
                                      response[Keys.schedule]["minute"],
                                    ),
                                  );

                                  ScaffoldMessenger.of(notificationContext)
                                      .showSnackBar(
                                    AppSnackbar().customizedAppSnackbar(
                                      message: "Your notification is recovered",
                                      context: notificationContext,
                                    ),
                                  );
                                }),
                              ),
                              content: const Text(
                                "Notification Deleted",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 20,
                            left: 10,
                            right: 10,
                          ),
                          padding: const EdgeInsets.only(
                            top: 15,
                            bottom: 15,
                            left: 15,
                            right: 15,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColour,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GlassmorphicContainer(
                                    width: 50,
                                    height: 50,
                                    borderRadius: 40,
                                    linearGradient:
                                        AppColors.customGlassIconButtonGradient,
                                    border: 2,
                                    blur: 4,
                                    borderGradient: AppColors
                                        .customGlassIconButtonBorderGradient,
                                    child: const Center(
                                      child: Icon(
                                        Icons.notifications,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.content!.title!,
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          notification.content!.body!,
                                          style: TextStyle(
                                            color: AppColors.white
                                                .withOpacity(0.6),
                                            overflow: TextOverflow.clip,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formattedTime(
                                      response[Keys.schedule]["year"],
                                      response[Keys.schedule]["month"],
                                      response[Keys.schedule]["day"],
                                      response[Keys.schedule]["hour"],
                                      response[Keys.schedule]["minute"],
                                    ),
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.6),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    formattedDate(
                                      response[Keys.schedule]["year"],
                                      response[Keys.schedule]["month"],
                                      response[Keys.schedule]["day"],
                                    ),
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.6),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.backgroundColour,
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        "assets/empty_animation.json",
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 6,
                      ),
                      const Center(
                        child: Text(
                          "Nothing to show",
                          style: AppColors.headingTextStyle,
                        ),
                      ),
                    ],
                  );
                }
                return const Center(
                  child: Text("Nothing"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
