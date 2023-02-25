import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:task_app/styles.dart';

import '../Utils/custom_glass_icon.dart';
import '../models/info_list_model.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> with TickerProviderStateMixin {
  late PageController tabController;
  List<InfoListModel> infoList = [
    InfoListModel(
      des:
          "Encourages users to tackle their to-do list one task at a time, emphasizing the importance of focus and productivity.",
      head: "Get things done, one task at a time!",
      index: 0,
    ),
    InfoListModel(
      index: 1,
      des:
          "Emphasizes the importance of maintaining consistency and daily progress towards one's goals.",
      head: "Stay on track with your day, every day.",
    ),
    InfoListModel(
      index: 2,
      des:
          "Positions the app as a go-to tool for anyone looking to enhance their productivity and streamline their tasks.",
      head: "Your ultimate productivity companion.",
    ),
    InfoListModel(
      index: 3,
      des:
          "Suggests that the app helps users organize their life and streamline their tasks for a more efficient and productive day.",
      head: "Organize your life, simplify your day.",
    ),
    InfoListModel(
      index: 4,
      des:
          "Encourages users to set goals and use the app as a tool to accomplish them efficiently.",
      head: "Achieve your goals, crush your to-do list.",
    ),
    InfoListModel(
      index: 5,
      des:
          "Emphasizes the app's simplicity and user-friendliness as key selling points.",
      head: "Productivity made simple, just for you.",
    ),
    InfoListModel(
      index: 6,
      des:
          "Suggests that the app helps users optimize their workflow and increase their productivity.",
      head: "Streamline your workflow, boost your efficiency.",
    ),
    InfoListModel(
      index: 7,
      des:
          "Promises users that using the app will result in getting more done while reducing stress and overwhelm.",
      head: "Get more done, stress less.",
    ),
    InfoListModel(
      index: 8,
      des:
          "Positions the app as a personal assistant, helping users manage their tasks efficiently.",
      head: "Your personal task master at your fingertips.",
    ),
    InfoListModel(
      index: 9,
      des:
          "Encourages users to take control of their time and be more productive with the help of the app.",
      head: "Master your day, own your time.",
    ),
  ];
  int tabIndex = 0;

  @override
  void initState() {
    tabController = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        alignment: Alignment.center,
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
                    "assets/motivational-pics/motivational-pic-1.jpg",
                  ),
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
            child: Container(
              margin: EdgeInsets.only(
                left: 25,
                right: 25,
              ),
              width: size.width,
              height: size.height,
              child: PageView(
                onPageChanged: ((page) {
                  print(page);
                  setState(() {
                    tabIndex = page;
                  });
                }),
                controller: tabController,
                physics: AppColors.scrollPhysics,
                children: infoList.map<Widget>((e) {
                  return infoWidget(
                    index: e.index,
                    infoList: infoList,
                    head: e.head,
                    des: e.des,
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            bottom: size.height / 10,
            child: SmoothPageIndicator(
              effect: ExpandingDotsEffect(
                dotColor: AppColors.backgroundColour.withOpacity(0.2),
                activeDotColor: AppColors.backgroundColour,
              ),
              controller: tabController,
              count: infoList.length,
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
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomGlassIconButton(
                  onPressed: (() {
                    ZoomDrawer.of(context)!.toggle();
                  }),
                  icon: Icons.menu,
                ),
                Row(
                  children: [
                    if (tabIndex != 0)
                      CustomGlassIconButton(
                        icon: CupertinoIcons.chevron_left,
                        tabController: tabController,
                        onPressed: (() {
                          tabController.previousPage(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.ease,
                          );
                        }),
                      ),
                    SizedBox(
                      width: 10,
                    ),
                    if (tabIndex != infoList.length - 1)
                      CustomGlassIconButton(
                        icon: CupertinoIcons.chevron_right,
                        tabController: tabController,
                        onPressed: (() {
                          tabController.nextPage(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.bounceInOut,
                          );
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class infoWidget extends StatelessWidget {
  infoWidget({
    super.key,
    required this.head,
    required this.des,
    required this.index,
    required this.infoList,
  });

  String head;
  String des;
  int index;
  List<InfoListModel> infoList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 5,
        right: 5,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: Text(
              '"$head',
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          GlassmorphicContainer(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
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
                    des,
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
          ),
          SizedBox(
            height: 25,
          ),
          if (index == infoList.length - 1)
            InkWell(
              onTap: (() {}),
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
                    "Visit Website",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
