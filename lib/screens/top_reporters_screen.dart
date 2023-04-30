import 'dart:developer';

import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/styles.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';

import '../widgets/email_us_screen_widgets.dart';

class TopReportersScreen extends StatefulWidget {
  const TopReportersScreen({Key? key}) : super(key: key);

  @override
  State<TopReportersScreen> createState() => _TopReportersScreenState();
}

class _TopReportersScreenState extends State<TopReportersScreen> {
  bool followed = false, saved = false;
  int likeCount = 1000000;

  Future<void> refresh() async {
    log("refreshing");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: CustomAppBarLeading(
          onPressed: (() {
            Navigator.pop(context);
            // print(isPlaying);
          }),
          icon: Icons.arrow_back_ios_new,
        ),
        title: GlassmorphicContainer(
          width: double.infinity,
          height: 41,
          borderRadius: 40,
          linearGradient: AppColors.customGlassIconButtonGradient,
          border: 2,
          blur: 4,
          borderGradient: AppColors.customGlassIconButtonBorderGradient,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            // height: 41 / 2.3,
            child: Center(
              child: Text(
                "Top Reporters",
                style: AppColors.subHeadingTextStyle,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(top: 10),
          child: ListView.separated(
            itemBuilder: ((topReportersContext, topReportersIndex) {
              return GestureDetector(
                onTap: (() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (profileDetailsContext) => ReporterPublicProfile(
                        blockUID: "",
                      ),
                    ),
                  );
                }),
                child: Container(
                  width: MediaQuery.of(topReportersContext).size.width,
                  margin: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 12,
                    right: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Rupam Karmajksdf sdfsd dsncdsjkncdnmzcnkar",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white.withOpacity(0.8),
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${NumberFormat.compact().format(10000000).toString()} Followers",
                                  style: TextStyle(
                                    color: AppColors.white.withOpacity(0.4),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: (() {
                          setState(() {
                            followed = !followed;
                          });
                        }),
                        child: AnimatedContainer(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          width: MediaQuery.of(context).size.width / 3.5,
                          decoration: BoxDecoration(
                            color: (followed == true)
                                ? AppColors.red
                                : AppColors.backgroundColour,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          duration: Duration(milliseconds: 400),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  (followed == true)
                                      ? Icons.sentiment_dissatisfied
                                      : Icons.emoji_emotions_outlined,
                                  color: AppColors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  (followed == true) ? "Unfollow" : "Follow",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
            separatorBuilder:
                ((topReportersSeparatorContext, topReportersSeparatorIndex) {
              return SizedBox(
                height: 20,
              );
            }),
            itemCount: 10,
          ),
        ),
      ),
    );
  }
}
