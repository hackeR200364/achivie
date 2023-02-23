import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:task_app/styles.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: AppColors.backgroundColour,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                      "assets/motivational-pics/motivational-pic-1.jpg"),
                ),
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.mainColor.withOpacity(0.7),
                    AppColors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height / 4.1,
            left: size.width / 10,
            right: size.width / 10,
            child: Column(
              children: [
                Text(
                  "Get things done, one task at a time!",
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                GlassmorphicContainer(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 25,
                          right: 25,
                        ),
                        child: Text(
                          "This tagline emphasizes the importance of focus and productivity, encouraging users to tackle their to-do list one task at a time. By prioritizing tasks and avoiding multitasking, users can achieve more and feel more accomplished.",
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.mainColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            height: 1.7,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          // Positioned(
          //   bottom: size.height / 11,
          //   left: size.width / 10,
          //   right: size.width / 10,
          //   child: GlassmorphicContainer(
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height / 2,
          //     borderRadius: 20,
          //     linearGradient: LinearGradient(
          //       colors: [
          //         AppColors.white.withOpacity(0.1),
          //         AppColors.white.withOpacity(0.3),
          //       ],
          //     ),
          //     border: 2,
          //     blur: 4,
          //     borderGradient: LinearGradient(
          //       colors: [
          //         AppColors.white.withOpacity(0.3),
          //         AppColors.white.withOpacity(0.5),
          //       ],
          //     ),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Padding(
          //           padding: EdgeInsets.only(
          //             left: 25,
          //             right: 25,
          //           ),
          //           child: Text(
          //             "This tagline emphasizes the importance of focus and productivity, encouraging users to tackle their to-do list one task at a time. By prioritizing tasks and avoiding multitasking, users can achieve more and feel more accomplished.",
          //             overflow: TextOverflow.clip,
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //               color: AppColors.mainColor,
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold,
          //               letterSpacing: 3,
          //               height: 1.7,
          //             ),
          //           ),
          //         )
          //       ],
          //     ),
          //   ),
          // ),
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
                  ZoomDrawer.of(context)!.toggle();
                }),
                icon: Icon(
                  Icons.menu,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
