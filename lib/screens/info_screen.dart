import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/custom_glass_icon.dart';
import '../models/info_list_model.dart';
import '../styles.dart';
import '../widgets/menu_screen_widgets.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> with TickerProviderStateMixin {
  late PageController tabController;
  List<InfoListModel> infoList = [
    InfoListModel(
      des: "",
      head: "",
      index: 0,
    ),
    InfoListModel(
      des:
          "Encourages users to tackle their to-do list one task at a time, emphasizing the importance of focus and productivity.",
      head: "Get things done, one task at a time!",
      index: 1,
    ),
    InfoListModel(
      index: 2,
      des:
          "Emphasizes the importance of maintaining consistency and daily progress towards one's goals.",
      head: "Stay on track with your day, every day.",
    ),
    InfoListModel(
      index: 3,
      des:
          "Positions the app as a go-to tool for anyone looking to enhance their productivity and streamline their tasks.",
      head: "Your ultimate productivity companion.",
    ),
    InfoListModel(
      index: 4,
      des:
          "Suggests that the app helps users organize their life and streamline their tasks for a more efficient and productive day.",
      head: "Organize your life, simplify your day.",
    ),
    InfoListModel(
      index: 5,
      des:
          "Encourages users to set goals and use the app as a tool to accomplish them efficiently.",
      head: "Achieve your goals, crush your to-do list.",
    ),
    InfoListModel(
      index: 6,
      des:
          "Emphasizes the app's simplicity and user-friendliness as key selling points.",
      head: "Productivity made simple, just for you.",
    ),
    InfoListModel(
      index: 7,
      des:
          "Suggests that the app helps users optimize their workflow and increase their productivity.",
      head: "Streamline your workflow, boost your efficiency.",
    ),
    InfoListModel(
      index: 8,
      des:
          "Promises users that using the app will result in getting more done while reducing stress and overwhelm.",
      head: "Get more done, stress less.",
    ),
    InfoListModel(
      index: 9,
      des:
          "Positions the app as a personal assistant, helping users manage their tasks efficiently.",
      head: "Your personal task master at your fingertips.",
    ),
    InfoListModel(
      index: 10,
      des:
          "Encourages users to take control of their time and be more productive with the help of the app.",
      head: "Master your day, own your time.",
    ),
  ];
  int tabIndex = 0;
  bool pageLoading = true;

  @override
  void initState() {
    tabController = PageController();
    Future.delayed(
      const Duration(milliseconds: 500),
      (() {
        setState(() {
          pageLoading = false;
        });
      }),
    );
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
          const InfoScreenBGWidget(),
          InfoScreenShadeWidget(size: size),
          Positioned(
            child: Container(
              margin: const EdgeInsets.only(
                left: 25,
                right: 25,
              ),
              width: size.width,
              height: size.height,
              child: PageView(
                onPageChanged: ((page) {
                  // print(page);
                  setState(() {
                    tabIndex = page;
                  });
                }),
                controller: tabController,
                physics: AppColors.scrollPhysics,
                children: infoList.map<Widget>((e) {
                  return (e.index == 0)
                      ? const InfoScreenMainSocialsWidget()
                      : InfoWidget(
                          head: e.head,
                          des: e.des,
                        );
                }).toList(),
              ),
            ),
          ),
          InfoScreenPageIndexDot(
            size: size,
            tabController: tabController,
            infoList: infoList,
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 15,
            left: 20,
            right: 20,
            child: InfoScreenAppBarWidgets(
              tabIndex: tabIndex,
              tabController: tabController,
              infoList: infoList,
            ),
          ),
          if (pageLoading) const LoadingWidget(),
        ],
      ),
    );
  }
}

class InfoScreenBGWidget extends StatelessWidget {
  const InfoScreenBGWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: AppColors.backgroundColour,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(
              "assets/motivational-pics/motivational-pic-1.jpg",
            ),
          ),
        ),
      ),
    );
  }
}

class InfoScreenShadeWidget extends StatelessWidget {
  const InfoScreenShadeWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}

class InfoScreenMainSocialsWidget extends StatelessWidget {
  const InfoScreenMainSocialsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        InfoScreenSocialsHeading(),
        SizedBox(
          height: 25,
        ),
        InfoScreenGlassSocialsContainer(),
      ],
    );
  }
}

class InfoScreenSocialsHeading extends StatelessWidget {
  const InfoScreenSocialsHeading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Socials',
      overflow: TextOverflow.clip,
      style: TextStyle(
        color: AppColors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class InfoScreenGlassSocialsContainer extends StatelessWidget {
  const InfoScreenGlassSocialsContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(
        left: 13,
        right: 13,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      borderRadius: 20,
      linearGradient: AppColors.customGlassIconButtonGradient,
      border: 2,
      blur: 4,
      borderGradient: AppColors.customGlassIconButtonBorderGradient,
      child: const InfoScreenMainGlassContainerChild(),
    );
  }
}

class InfoScreenMainGlassContainerChild extends StatelessWidget {
  const InfoScreenMainGlassContainerChild({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const MenuScreenSocialFirstRow(),
        const SizedBox(
          height: 15,
        ),
        const MenuScreenSocialSecondRow(),
        SizedBox(
          height: MediaQuery.of(context).size.height / 20,
        ),
        const InfoPageSocialsWidget()
      ],
    );
  }
}

class InfoPageSocialsWidget extends StatelessWidget {
  const InfoPageSocialsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      child: Column(
        children: [
          MenuScreenExtraButton(
            onTap: (() async {
              await launchUrl(
                Uri.parse(
                  "https://achivie.com",
                ),
                mode: LaunchMode.externalNonBrowserApplication,
              );
            }),
            title: "Visit Website",
          ),
          const SizedBox(
            height: 20,
          ),
          MenuScreenExtraButton(
            onTap: (() async {
              await launchUrl(
                Uri.parse(
                  "https://github.com/hackeR200364/task_app",
                ),
                mode: LaunchMode.externalNonBrowserApplication,
              );
            }),
            title: "GitHub Repository",
          ),
        ],
      ),
    );
  }
}

class InfoScreenPageIndexDot extends StatelessWidget {
  const InfoScreenPageIndexDot({
    super.key,
    required this.size,
    required this.tabController,
    required this.infoList,
  });

  final Size size;
  final PageController tabController;
  final List<InfoListModel> infoList;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: size.height / 10,
      child: SmoothPageIndicator(
        effect: ScrollingDotsEffect(
          dotColor: AppColors.backgroundColour.withOpacity(0.2),
          activeDotColor: AppColors.backgroundColour.withOpacity(0.8),
        ),
        controller: tabController,
        count: infoList.length,
      ),
    );
  }
}

class InfoScreenAppBarWidgets extends StatelessWidget {
  const InfoScreenAppBarWidgets({
    super.key,
    required this.tabIndex,
    required this.tabController,
    required this.infoList,
  });

  final int tabIndex;
  final PageController tabController;
  final List<InfoListModel> infoList;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomGlassIconButton(
          onPressed: (() {
            ZoomDrawer.of(context)!.toggle();
          }),
          icon: Icons.menu,
        ),
        InfoScreenWidgetToggleButtons(
          tabIndex: tabIndex,
          tabController: tabController,
          infoList: infoList,
        ),
      ],
    );
  }
}

class InfoScreenWidgetToggleButtons extends StatelessWidget {
  const InfoScreenWidgetToggleButtons({
    super.key,
    required this.tabIndex,
    required this.tabController,
    required this.infoList,
  });

  final int tabIndex;
  final PageController tabController;
  final List<InfoListModel> infoList;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (tabIndex != 0)
          CustomGlassIconButton(
            icon: CupertinoIcons.chevron_left,
            tabController: tabController,
            onPressed: (() {
              tabController.previousPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            }),
          ),
        const SizedBox(
          width: 10,
        ),
        if (tabIndex != infoList.length - 1)
          CustomGlassIconButton(
            icon: CupertinoIcons.chevron_right,
            tabController: tabController,
            onPressed: (() {
              tabController.nextPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            }),
          ),
      ],
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}

class InfoWidget extends StatelessWidget {
  const InfoWidget({
    super.key,
    required this.head,
    required this.des,
  });

  final String head;
  final String des;

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
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          GlassmorphicContainer(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            borderRadius: 20,
            linearGradient: AppColors.customGlassIconButtonGradient,
            border: 2,
            blur: 4,
            borderGradient: AppColors.customGlassIconButtonBorderGradient,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: Text(
                    des,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
        ],
      ),
    );
  }
}
