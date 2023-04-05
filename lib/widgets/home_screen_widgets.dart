import 'dart:convert';
import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../Utils/snackbar_utils.dart';
import '../providers/app_providers.dart';
import '../providers/user_details_providers.dart';
import '../screens/home_screen.dart';
import '../screens/new_task_screen.dart';
import '../services/keys.dart';
import '../services/notification_services.dart';
import '../styles.dart';

class CustomFocusedMenuTile extends StatelessWidget {
  const CustomFocusedMenuTile({
    super.key,
    required this.type,
    required this.status,
    required this.date,
    required this.time,
    required this.name,
    required this.des,
    required this.taskDocID,
    required this.tileFirstOnPressed,
    required this.tileOnPressed,
    required this.tileSecondOnPressed,
    required this.tileThirdOnPressed,
  });

  final String name;
  final String des;
  final String status;
  final String time;
  final String date;
  final String type;
  final String taskDocID;
  final VoidCallback tileOnPressed;
  final VoidCallback tileFirstOnPressed;
  final VoidCallback tileSecondOnPressed;
  final VoidCallback tileThirdOnPressed;

  @override
  Widget build(BuildContext context) {
    return FocusedMenuHolder(
      onPressed: tileOnPressed,
      menuBoxDecoration: const BoxDecoration(
        color: AppColors.transparent,
      ),
      openWithTap: true,
      menuItems: [
        if (status != "Deleted")
          FocusedMenuItem(
            title: (status == "Pending")
                ? const FocusedMenuItemTitleTextDone()
                : const FocusedMenuItemTitleTextUnDone(),
            trailingIcon: (status == "Pending")
                ? const Icon(
                    Icons.done,
                    color: AppColors.lightGreen,
                    size: 20,
                  )
                : const Icon(
                    Icons.cancel_outlined,
                    color: AppColors.red,
                    size: 20,
                  ),
            onPressed: tileFirstOnPressed,
            backgroundColor: AppColors.backgroundColour,
          ),
        FocusedMenuItem(
          title: const FocusedMenuItemTitleTextEdit(),
          onPressed: tileSecondOnPressed,
          backgroundColor: AppColors.backgroundColour,
        ),
        FocusedMenuItem(
          title: (status == Keys.deleteStatus)
              ? const FocusedMenuItemTitleTextUndo()
              : const FocusedMenuItemTitleTextDelete(),
          onPressed: tileThirdOnPressed,
          backgroundColor: AppColors.backgroundColour,
        ),
      ],
      child: FocusedMenuTileChildContainer(
        name: name,
        des: des,
        time: time,
        type: type,
        status: status,
        date: date,
      ),
    );
  }
}

class FocusedMenuTileChildContainer extends StatelessWidget {
  const FocusedMenuTileChildContainer({
    super.key,
    required this.type,
    required this.status,
    required this.date,
    required this.time,
    required this.name,
    required this.des,
  });

  final String name;
  final String des;
  final String status;
  final String time;
  final String date;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColour,
        borderRadius: BorderRadius.circular(15),
      ),
      child: FocusMenuTileRow(
        name: name,
        des: des,
        status: status,
        time: time,
        date: date,
        type: type,
      ),
    );
  }
}

class FocusMenuTileRow extends StatelessWidget {
  const FocusMenuTileRow({
    super.key,
    required this.type,
    required this.status,
    required this.date,
    required this.time,
    required this.name,
    required this.des,
  });

  final String name;
  final String des;
  final String status;
  final String time;
  final String date;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FocusedMenuTileFirstRow(
          name: name,
          des: des,
          pendingStatus: status,
        ),
        FocusedMenuTileSecondRow(
          time: time,
          date: date,
          status: status,
          type: type,
        ),
      ],
    );
  }
}

class FocusedMenuTileSecondRow extends StatelessWidget {
  const FocusedMenuTileSecondRow({
    super.key,
    required this.time,
    required this.type,
    required this.status,
    required this.date,
  });

  final String time;
  final String date;
  final String status;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FocusedMenuTileTaskDateTimeText(
          time: time,
          date: date,
        ),
        const SizedBox(
          height: 10,
        ),
        FocusedMenuTileParentRow(status: status, type: type),
      ],
    );
  }
}

class FocusedMenuTileParentRow extends StatelessWidget {
  const FocusedMenuTileParentRow({
    super.key,
    required this.type,
    required this.status,
  });

  final String status;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (status != "Deleted")
          FocusedMenuTileDoneUnDoneLight(
            pendingStatus: status,
          ),
        if (status == "Deleted")
          FocusedMenuTileDeletedStatusText(
            deletedStatus: status,
          ),
        if (status != "Deleted")
          const SizedBox(
            width: 10,
          ),
        if (status == "Deleted") const FocusedMenuTileDeletedSeparator(),
        FocusedMenuTileTaskTypeContainer(
          type: type,
        ),
      ],
    );
  }
}

class FocusedMenuTileTaskTypeContainer extends StatelessWidget {
  const FocusedMenuTileTaskTypeContainer({
    super.key,
    required this.type,
  });

  final String type;

  @override
  Widget build(BuildContext context) {
    return Text(
      type,
      style: TextStyle(
        color: AppColors.white.withOpacity(0.5),
      ),
    );
  }
}

class FocusedMenuTileDeletedSeparator extends StatelessWidget {
  const FocusedMenuTileDeletedSeparator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      height: 4,
      width: 4,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

class FocusedMenuTileDeletedStatusText extends StatelessWidget {
  const FocusedMenuTileDeletedStatusText(
      {super.key, required this.deletedStatus});

  final String deletedStatus;

  @override
  Widget build(BuildContext context) {
    return Text(
      deletedStatus,
      style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
    );
  }
}

class FocusedMenuTileDoneUnDoneLight extends StatelessWidget {
  const FocusedMenuTileDoneUnDoneLight({
    super.key,
    required this.pendingStatus,
  });

  final String pendingStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      width: 5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            (pendingStatus == "Pending") ? AppColors.red : AppColors.lightGreen,
        boxShadow: [
          BoxShadow(
            color: (pendingStatus == "Pending")
                ? AppColors.red
                : AppColors.lightGreen,
            blurRadius: 5,
            spreadRadius: 3,
          )
        ],
      ),
    );
  }
}

class FocusedMenuTileTaskDateTimeText extends StatelessWidget {
  const FocusedMenuTileTaskDateTimeText({
    super.key,
    required this.date,
    required this.time,
  });

  final String time;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Text(
      "$time\n$date",
      textAlign: TextAlign.end,
      style: TextStyle(
        color: AppColors.white.withOpacity(0.5),
      ),
    );
  }
}

class FocusedMenuTileFirstRow extends StatelessWidget {
  const FocusedMenuTileFirstRow(
      {super.key,
      required this.des,
      required this.name,
      required this.pendingStatus});

  final String name;
  final String des;
  final String pendingStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FocusedMenuTileIconContainer(
          pendingStatus: pendingStatus,
        ),
        const SizedBox(
          width: 5,
        ),
        FocusedMenuTileTaskDetailsContainer(
          name: name,
          des: des,
        ),
      ],
    );
  }
}

class FocusedMenuTileTaskDetailsContainer extends StatelessWidget {
  const FocusedMenuTileTaskDetailsContainer({
    super.key,
    required this.des,
    required this.name,
  });

  final String name;
  final String des;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FocusedMenuTileTaskName(name: name),
        const SizedBox(
          height: 5,
        ),
        FocusedMenuTileTaskDes(
          des: des,
        ),
      ],
    );
  }
}

class FocusedMenuTileTaskDes extends StatelessWidget {
  const FocusedMenuTileTaskDes({
    super.key,
    required this.des,
  });

  final String des;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      child: Text(
        des,
        overflow: TextOverflow.clip,
        softWrap: true,
        style: TextStyle(
          color: AppColors.white.withOpacity(0.5),
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
      ),
    );
  }
}

class FocusedMenuTileTaskName extends StatelessWidget {
  const FocusedMenuTileTaskName({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 4,
      child: Text(
        name,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class FocusedMenuTileIconContainer extends StatelessWidget {
  const FocusedMenuTileIconContainer({
    super.key,
    required this.pendingStatus,
  });

  final String pendingStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: (pendingStatus == "Deleted")
          ? const FocusedMenuTileDeletedImage()
          : FocusedMenuTileDoneUnDoneIcon(
              pendingStatus: pendingStatus,
            ),
    );
  }
}

class FocusedMenuTileDoneUnDoneIcon extends StatelessWidget {
  const FocusedMenuTileDoneUnDoneIcon({
    super.key,
    required this.pendingStatus,
  });

  final String pendingStatus;

  @override
  Widget build(BuildContext context) {
    return Icon(
      shadows: [
        Shadow(
          color: (pendingStatus == "Pending")
              ? AppColors.red
              : AppColors.lightGreen,
          blurRadius: 10,
        )
      ],
      Icons.work_outline,
      color:
          (pendingStatus == "Pending") ? AppColors.red : AppColors.lightGreen,
      size: 35,
    );
  }
}

class FocusedMenuTileDeletedImage extends StatelessWidget {
  const FocusedMenuTileDeletedImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/cancel-task.png",
      width: 35,
      height: 35,
    );
  }
}

class FocusedMenuItemTitleTextDelete extends StatelessWidget {
  const FocusedMenuItemTitleTextDelete({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Delete",
      style: TextStyle(
        color: AppColors.white,
      ),
    );
  }
}

class FocusedMenuItemTitleTextUndo extends StatelessWidget {
  const FocusedMenuItemTitleTextUndo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Undo",
      style: TextStyle(
        color: AppColors.white,
      ),
    );
  }
}

class FocusedMenuItemTitleTextEdit extends StatelessWidget {
  const FocusedMenuItemTitleTextEdit({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Edit",
      style: TextStyle(
        color: AppColors.white,
      ),
    );
  }
}

class TaskUnDoneDialogChild extends StatelessWidget {
  const TaskUnDoneDialogChild({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TaskDialog(
      animation: "assets/cancel-undone-animation.json",
      headMessage: "Canceled!",
      subMessage: "Your this task is canceled",
      subMessageBottomDivision: 5,
    );
  }
}

class FocusedMenuItemTitleTextUnDone extends StatelessWidget {
  const FocusedMenuItemTitleTextUnDone({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Un Done",
      style: TextStyle(
        color: AppColors.white,
      ),
    );
  }
}

class FocusedMenuItemTitleTextDone extends StatelessWidget {
  const FocusedMenuItemTitleTextDone({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Done",
      style: TextStyle(
        color: AppColors.white,
      ),
    );
  }
}

class CustomHomeScreenSeparator extends StatelessWidget {
  const CustomHomeScreenSeparator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      height: 2,
      color: AppColors.grey.withOpacity(0.1),
    );
  }
}

class CustomHomeScreenTabBarHeadList extends StatelessWidget {
  const CustomHomeScreenTabBarHeadList({
    super.key,
    required this.tabController,
  });

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      enableFeedback: true,
      splashBorderRadius: BorderRadius.circular(50),
      physics: AppColors.scrollPhysics,
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: BoxDecoration(
        color: AppColors.backgroundColour,
        borderRadius: BorderRadius.circular(50),
      ),
      labelColor: AppColors.white,
      labelStyle: const TextStyle(
        // color: AppColors.grey,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelColor: AppColors.backgroundColour,
      controller: tabController,
      tabs: const [
        CustomTabBarItems(
          label: "PENDING",
        ),
        CustomTabBarItems(
          label: "COMPLETED",
        ),
        CustomTabBarItems(
          label: "INBOX",
        ),
        CustomTabBarItems(
          label: "DELETED",
        ),
      ],
    );
  }
}

class CustomHomeScreenBottomNavBarWithBannerAd extends StatelessWidget {
  const CustomHomeScreenBottomNavBarWithBannerAd({
    super.key,
    required this.bannerAd,
  });

  final BannerAd? bannerAd;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mainColor,
      height: bannerAd!.size.height.toDouble(),
      width: MediaQuery.of(context).size.width,
      child: AdWidget(
        ad: bannerAd!,
      ),
    );
  }
}

class CustomTabBarItems extends StatelessWidget {
  const CustomTabBarItems({
    super.key,
    required this.label,
  });
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 5,
      height: 25,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.backgroundColour,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(
          label,
        ),
      ),
    );
  }
}

class ConnectivityErrorContainer extends StatelessWidget {
  const ConnectivityErrorContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: const Center(
        child: Text(
          "Please check your connection",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class HomeScreenTaskTypePickerContainer extends StatelessWidget {
  const HomeScreenTaskTypePickerContainer({
    super.key,
    required this.taskType,
  });

  final List<String> taskType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      // padding: const EdgeInsets.only(left: 10),
      height: 40,
      width: MediaQuery.of(context).size.width,
      // color: AppColors.sky,
      decoration: BoxDecoration(
        // color: AppColors.sky,
        borderRadius: BorderRadius.circular(15),
      ),
      child: HomeScreenTaskTypePickerContainerConsumer(taskType: taskType),
    );
  }
}

class HomeScreenTaskTypePickerContainerConsumer extends StatelessWidget {
  const HomeScreenTaskTypePickerContainerConsumer({
    super.key,
    required this.taskType,
  });

  final List<String> taskType;

  @override
  Widget build(BuildContext context) {
    return Consumer<AllAppProviders>(
      builder:
          (allAppProvidersCtx, allAppProvidersProvider, allAppProvidersChild) {
        List<Text> taskTypeTextList = [];

        for (String type in taskType) {
          taskTypeTextList.add(
            Text(
              type,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return HomeScreenTaskTypePickerContainerConsumerDesign(
          taskType: taskType,
          taskTypeTextList: taskTypeTextList,
          allAppProvidersProvider: allAppProvidersProvider,
        );
      },
    );
  }
}

class HomeScreenTaskTypePickerContainerConsumerDesign extends StatelessWidget {
  const HomeScreenTaskTypePickerContainerConsumerDesign({
    super.key,
    required this.taskType,
    required this.taskTypeTextList,
    required this.allAppProvidersProvider,
  });

  final List<String> taskType;
  final List<Text> taskTypeTextList;
  final AllAppProviders allAppProvidersProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColour,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CupertinoPicker(
        backgroundColor: AppColors.transparent,
        itemExtent: 23,
        onSelectedItemChanged: (value) {
          allAppProvidersProvider.selectedTypeFunc(taskType[value]);
          // print(AllAppProvidersProvider.selectedType);
          // print(taskType[value]);
        },
        children: taskTypeTextList,
      ),
    );
  }
}

class HomeScreenGraphContainer extends StatelessWidget {
  const HomeScreenGraphContainer({
    super.key,
    required this.taskDone,
    required this.taskDelete,
    required this.taskPersonal,
    required this.taskPending,
    required this.taskCount,
    required this.taskBusiness,
  });

  final int taskDone;
  final int taskDelete;
  final int taskPersonal;
  final int taskPending;
  final int taskCount;
  final int taskBusiness;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 20,
        bottom: MediaQuery.of(context).size.height / 30,
        left: 15,
        right: 15,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3.5,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColour,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 2,
        child: _BarChart(
          done: taskDone,
          deleted: taskDelete,
          personal: taskPersonal,
          pending: taskPending,
          business: taskBusiness,
          count: taskCount - taskDelete,
        ),
      ),
    );
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(
        right: 10,
      ),
      width: 50,
      height: 50,
      borderRadius: 40,
      linearGradient: AppColors.customGlassIconButtonGradient,
      border: 2,
      blur: 4,
      borderGradient: AppColors.customGlassIconButtonBorderGradient,
      child: const CustomFloatingActionButtonChild(),
    );
  }
}

class CustomFloatingActionButtonChild extends StatelessWidget {
  const CustomFloatingActionButtonChild({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (nextPageContext) => const NewTaskScreen(),
            ),
          );
        },
        icon: const Icon(
          Icons.add,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class CustomHomeScreenAppBarTitle extends StatelessWidget {
  const CustomHomeScreenAppBarTitle({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (_, userDetailsProviderProvider, userDetailsProviderChild) {
        Future.delayed(
          Duration.zero,
          (() {
            userDetailsProviderProvider.userNameFunc();
          }),
        );
        return CustomHomeScreenAppBarTitleChild(
          date: date,
          userDetailsProviderProvider: userDetailsProviderProvider,
        );
      },
    );
  }
}

class CustomHomeScreenAppBarTitleChild extends StatelessWidget {
  const CustomHomeScreenAppBarTitleChild({
    super.key,
    required this.date,
    required this.userDetailsProviderProvider,
  });

  final DateTime date;
  final UserDetailsProvider userDetailsProviderProvider;

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
        child: Center(
          child: SingleChildScrollView(
            physics: AppColors.scrollPhysics,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomHomeScreenAppBarTitleHeading(
                  userDetailsProviderProvider: userDetailsProviderProvider,
                ),
                CustomHomeScreenAppBarTitleSubHeading(
                  date: date,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomHomeScreenAppBarTitleHeading extends StatelessWidget {
  const CustomHomeScreenAppBarTitleHeading({
    super.key,
    required this.userDetailsProviderProvider,
  });

  final UserDetailsProvider userDetailsProviderProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (userDetailsProviderProvider.userName.trim().split(" ").length < 3)
          Center(
            child: Text(
              userDetailsProviderProvider.userName,
              style: AppColors.headingTextStyle,
            ),
          ),
        if (userDetailsProviderProvider.userName.trim().split(" ").length > 2)
          SizedBox(
            height: 41,
            child: Marquee(
              fadingEdgeStartFraction: 0.2,
              fadingEdgeEndFraction: 0.2,
              velocity: 50,
              blankSpace: 1,
              text: userDetailsProviderProvider.userName.padLeft(30),
              style: AppColors.headingTextStyle,
            ),
          ),
      ],
    );
  }
}

class CustomHomeScreenAppBarTitleSubHeading extends StatelessWidget {
  const CustomHomeScreenAppBarTitleSubHeading({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Text(
      "${DateFormat.MMMM().format(date)[0]}${DateFormat.MMMM().format(date)[1]}${DateFormat.MMMM().format(date)[2]} ${date.day.toString()}, ${date.year}",
      style: AppColors.subHeadingTextStyle,
    );
  }
}

class TaskDialog extends StatelessWidget {
  TaskDialog({
    super.key,
    required this.animation,
    required this.headMessage,
    required this.subMessage,
    required this.subMessageBottomDivision,
  });

  final String animation;
  final String headMessage;
  final String subMessage;
  int subMessageBottomDivision = 0;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        top: MediaQuery.of(context).size.height / 5,
        bottom: MediaQuery.of(context).size.height / 5,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.1,
      borderRadius: 20,
      linearGradient: AppColors.customGlassIconButtonGradient,
      border: 2,
      blur: 4,
      borderGradient: AppColors.customGlassIconButtonBorderGradient,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height / 3.8,
            height: 200,
            child: Lottie.asset(
              animation,
              width: 50,
              height: 50,
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 8,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  Text(
                    headMessage,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    subMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  _BarChart({
    required this.done,
    required this.personal,
    required this.pending,
    required this.business,
    required this.deleted,
    required this.count,
  });

  int deleted = 0;
  int done = 0;
  int pending = 0;
  int business = 0;
  int personal = 0;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: buildTitleDate(),
        borderData: borderData,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: done.toDouble(),
                gradient: _barsGradient,
              )
            ],
            showingTooltipIndicators: [0],
          ),
          // BarChartGroupData(
          //   x: 1,
          //   barRods: [
          //     BarChartRodData(
          //       toY: deleted.toDouble(),
          //       gradient: _barsGradient,
          //     )
          //   ],
          //   showingTooltipIndicators: [0],
          // ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: pending.toDouble(),
                gradient: _barsGradient,
              )
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: business.toDouble(),
                gradient: _barsGradient,
              )
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: personal.toDouble(),
                gradient: _barsGradient,
              )
            ],
            showingTooltipIndicators: [0],
          ),
        ],
        gridData: FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: count.toDouble(),
      ),
    );
  }

  buildTitleDate() => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (double val, TitleMeta meta) {
              const textStyle = TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              );
              switch (val.toInt()) {
                case 0:
                  return const Text(
                    "\nDone",
                    style: textStyle,
                  );
                case 1:
                  return const Text(
                    "\nPending",
                    style: textStyle,
                  );
                case 2:
                  return const Text(
                    "\nBusiness",
                    style: textStyle,
                  );
                case 3:
                  return const Text(
                    "\nPersonal",
                    style: textStyle,
                  );
                case 4:
                  return const Text(
                    "\nPersonal",
                    style: textStyle,
                  );
              }
              return const Text("");
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            );
          },
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => const LinearGradient(
        colors: [
          AppColors.orange,
          AppColors.yellow,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> get barGroups => [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 8,
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
      ];
}

class CustomHomeScreenTabs extends StatefulWidget {
  const CustomHomeScreenTabs({
    super.key,
    required this.type,
    required this.status,
    required this.firestoreEmail,
    required this.widget,
    required this.scrollController,
    required this.date,
    required this.token,
    required this.uid,
  });

  final String type;
  final String status;
  final String firestoreEmail;
  final HomeScreen widget;
  final ScrollController scrollController;
  final DateTime date;
  final String token, uid;

  @override
  State<CustomHomeScreenTabs> createState() => _CustomHomeScreenTabsState();
}

class _CustomHomeScreenTabsState extends State<CustomHomeScreenTabs> {
  String totalTaskSuffix(int task) {
    int count = task % 10;
    switch (count) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }

  @override
  void initState() {
    super.initState();
  }

  // void updateTasks({
  //   required String taskDocID,
  //   required String status,
  //   required String firestoreEmail,
  //   required int taskSavedYear,
  //   required int taskSavedDay,
  //   required int taskSavedHour,
  //   required int taskSavedMonth,
  //   required int taskSavedMinute,
  // }) async {
  //   final taskDocUpdate = FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(firestoreEmail)
  //       .collection("tasks")
  //       .doc(taskDocID);
  //
  //   DocumentSnapshot taskDocRef = await taskDocUpdate.get();
  //
  //   DateTime taskSavedDate = DateTime(
  //     taskSavedYear,
  //     taskSavedMonth,
  //     taskSavedDay,
  //     taskSavedHour,
  //     taskSavedMinute,
  //   );
  //
  //   DateTime date = DateTime.now();
  //
  //   DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(firestoreEmail)
  //       .get();
  //
  //   final userDocUpdate =
  //       FirebaseFirestore.instance.collection("users").doc(firestoreEmail);
  //
  //   if (status == "Pending") {
  //     taskDocUpdate.update(
  //       {
  //         Keys.taskStatus: "Completed",
  //       },
  //     );
  //
  //     userDocUpdate.update(
  //       {
  //         Keys.taskDone: userDoc[Keys.taskDone] + 1,
  //       },
  //     );
  //     userDocUpdate.update(
  //       {
  //         Keys.taskPending: userDoc[Keys.taskPending] - 1,
  //       },
  //     );
  //
  //     if (taskSavedDate.difference(date).inMinutes > 0) {
  //       NotificationServices().cancelTaskScheduledNotification(
  //         id: taskDocRef[Keys.notificationID],
  //       );
  //     }
  //   } else if (status == "Completed") {
  //     taskDocUpdate.update(
  //       {
  //         Keys.taskStatus: "Pending",
  //       },
  //     );
  //
  //     userDocUpdate.update(
  //       {
  //         Keys.taskPending: userDoc[Keys.taskPending] + 1,
  //       },
  //     );
  //     userDocUpdate.update(
  //       {
  //         Keys.taskDone: userDoc[Keys.taskDone] - 1,
  //       },
  //     );
  //
  //     if (taskSavedDate.difference(date).inMinutes > 0) {
  //       NotificationServices().createScheduledTaskNotification(
  //         title: taskDocRef[Keys.taskNotification],
  //         body: "${taskDocRef[Keys.taskName]}\n${taskDocRef[Keys.taskDes]}",
  //         id: taskDocRef[Keys.notificationID],
  //         payload: taskDocRef[Keys.taskName],
  //         dateTime: taskSavedDate,
  //       );
  //     }
  //   }
  // }

  // void deleteTasks({
  //   required String taskDocID,
  //   required String status,
  //   required String firestoreEmail,
  //   required int taskSavedYear,
  //   required int taskSavedDay,
  //   required int taskSavedHour,
  //   required int taskSavedMonth,
  //   required int taskSavedMinute,
  // }) async {
  //   DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(firestoreEmail)
  //       .get();
  //   DocumentSnapshot taskDoc = await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(firestoreEmail)
  //       .collection("tasks")
  //       .doc(taskDocID)
  //       .get();
  //
  //   final userDocUpdate =
  //       FirebaseFirestore.instance.collection("users").doc(firestoreEmail);
  //
  //   final taskDocUpdate = FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(firestoreEmail)
  //       .collection("tasks")
  //       .doc(taskDocID);
  //
  //   DateTime taskSavedDate = DateTime(
  //     taskSavedYear,
  //     taskSavedMonth,
  //     taskSavedDay,
  //     taskSavedHour,
  //     taskSavedMinute,
  //   );
  //
  //   DateTime date = DateTime.now();
  //
  //   if (status == "Pending") {
  //     userDocUpdate.update(
  //       {
  //         Keys.taskPending: userDoc[Keys.taskPending] - 1,
  //       },
  //     );
  //
  //     if (taskDoc[Keys.taskType] == "Business") {
  //       userDocUpdate.update(
  //         {
  //           Keys.taskBusiness: userDoc[Keys.taskBusiness] - 1,
  //         },
  //       );
  //     } else if (taskDoc[Keys.taskType] == "Personal") {
  //       userDocUpdate.update(
  //         {
  //           Keys.taskPersonal: userDoc[Keys.taskPersonal] - 1,
  //         },
  //       );
  //     }
  //   } else if (status == "Completed") {
  //     userDocUpdate.update(
  //       {
  //         Keys.taskDone: userDoc[Keys.taskDone] - 1,
  //       },
  //     );
  //
  //     if (taskDoc[Keys.taskType] == "Business") {
  //       userDocUpdate.update(
  //         {
  //           Keys.taskBusiness: userDoc[Keys.taskBusiness] - 1,
  //         },
  //       );
  //     } else if (taskDoc[Keys.taskType] == "Personal") {
  //       userDocUpdate.update(
  //         {
  //           Keys.taskPersonal: userDoc[Keys.taskPersonal] - 1,
  //         },
  //       );
  //     }
  //
  //     userDocUpdate.update(
  //       {
  //         Keys.taskDelete: userDoc[Keys.taskDelete] - 1,
  //       },
  //     );
  //   }
  //
  //   taskDocUpdate.update(
  //     {
  //       Keys.taskStatus: Keys.deleteStatus,
  //     },
  //   );
  //
  //   userDocUpdate.update(
  //     {
  //       Keys.taskDelete: userDoc[Keys.taskDelete] + 1,
  //     },
  //   );
  //
  //   if (taskSavedDate.difference(date).inMinutes > 0) {
  //     NotificationServices().cancelTaskScheduledNotification(
  //       id: taskDoc[Keys.notificationID],
  //     );
  //   }
  // }

  // void undoTasks({
  //   required String taskDocID,
  //   required String status,
  //   required String firestoreEmail,
  //   required int taskSavedYear,
  //   required int taskSavedDay,
  //   required int taskSavedHour,
  //   required int taskSavedMonth,
  //   required int taskSavedMinute,
  // }) async {
  //   DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(firestoreEmail)
  //       .get();
  //   DocumentSnapshot taskDoc = await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(firestoreEmail)
  //       .collection("tasks")
  //       .doc(taskDocID)
  //       .get();
  //
  //   DateTime taskSavedDate = DateTime(
  //     taskSavedYear,
  //     taskSavedMonth,
  //     taskSavedDay,
  //     taskSavedHour,
  //     taskSavedMinute,
  //   );
  //
  //   DateTime date = DateTime.now();
  //
  //   final userDocUpdate =
  //       FirebaseFirestore.instance.collection("users").doc(firestoreEmail);
  //
  //   final taskDocUpdate = FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(firestoreEmail)
  //       .collection("tasks")
  //       .doc(taskDocID);
  //
  //   userDocUpdate.update(
  //     {
  //       Keys.taskPending: userDoc[Keys.taskPending] + 1,
  //     },
  //   );
  //   userDocUpdate.update(
  //     {
  //       Keys.taskDelete: userDoc[Keys.taskDelete] - 1,
  //     },
  //   );
  //
  //   if (taskDoc[Keys.taskType] == "Business") {
  //     userDocUpdate.update(
  //       {
  //         Keys.taskBusiness: userDoc[Keys.taskBusiness] + 1,
  //       },
  //     );
  //   } else if (taskDoc[Keys.taskType] == "Personal") {
  //     userDocUpdate.update(
  //       {
  //         Keys.taskPersonal: userDoc[Keys.taskPersonal] + 1,
  //       },
  //     );
  //   }
  //
  //   taskDocUpdate.update(
  //     {
  //       Keys.taskStatus: "Pending",
  //     },
  //   );
  //
  //   if (taskSavedDate.difference(date).inMinutes > 0) {
  //     NotificationServices().createScheduledTaskNotification(
  //       id: taskDoc[Keys.notificationID],
  //       title: taskDoc[Keys.taskNotification],
  //       body: "${taskDoc[Keys.taskName]}\n${taskDoc[Keys.taskDes]}",
  //       payload: taskDoc[Keys.taskDes],
  //       dateTime: taskSavedDate,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 10,
        left: 10,
      ),
      child: FutureBuilder<http.Response>(
        future: (widget.status != "INBOX")
            ? http.get(
                Uri.parse(
                    "${Keys.apiTasksBaseUrl}/getTasksOfTypeStatus/${widget.uid}/${widget.type}/${widget.status}"),
                headers: {
                  'content-Type': 'application/json',
                  'authorization': 'Bearer ${widget.token}',
                },
              )
            : http.get(
                Uri.parse(
                    "${Keys.apiTasksBaseUrl}/getAllTasksSpecificType/${widget.uid}/${widget.type}"),
                headers: {
                  "content-Type": "application/json",
                  "authorization": "Bearer ${widget.token}",
                },
              ),
        builder: (streamContext, AsyncSnapshot<http.Response> snapshot) {
          // print(snapshot.data!.docs.length);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.backgroundColour,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "No data",
                style: AppColors.headingTextStyle,
              ),
            );
          }

          log(snapshot.data!.body.toString());

          Map<String, dynamic> tasksJson = jsonDecode(snapshot.data!.body);

          if (tasksJson[Keys.data].isEmpty) {
            return Center(
              child: Lottie.asset("assets/empty_animation.json"),
            );
          }

          List snapshotList = tasksJson[Keys.data];

          // snapshotList.sort(
          //   (a, b) => DateTime.parse(
          //     (b as Map)[Keys.taskDate].split('/').reversed.join(),
          //   ).compareTo(
          //     DateTime.now(),
          //   ),
          // );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                // color: AppColors.sky,
                height: MediaQuery.of(context).size.height / 2.4,
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  // physics: AppColors.scrollPhysics,
                  itemCount: tasksJson[Keys.data].length,
                  controller: widget.scrollController,
                  itemBuilder: (listContext, listIndex) {
                    final individualTask = snapshotList[listIndex];

                    int taskSavedDay = int.parse(
                        "${individualTask[Keys.taskDate][0]}${individualTask[Keys.taskDate][1]}");
                    int taskSavedMonth = int.parse(
                        "${individualTask[Keys.taskDate][3]}${individualTask[Keys.taskDate][4]}");
                    int taskSavedYear = int.parse(
                        "${individualTask[Keys.taskDate][6]}${individualTask[Keys.taskDate][7]}${individualTask[Keys.taskDate][8]}${individualTask[Keys.taskDate][9]}");
                    int taskSavedHour = int.parse(
                        "${individualTask[Keys.taskTime][0]}${individualTask[Keys.taskTime][1]}");
                    int taskSavedMinute = int.parse(
                        "${individualTask[Keys.taskTime][3]}${individualTask[Keys.taskTime][4]}");

                    DateTime taskSavedDate = DateTime(
                      taskSavedYear,
                      taskSavedMonth,
                      taskSavedDay,
                      taskSavedHour,
                      taskSavedMinute,
                    );

                    // String taskDocID = snapshotList[listIndex].reference.id;

                    return CustomFocusedMenuTile(
                      name: snapshotList[listIndex][Keys.taskName],
                      des: snapshotList[listIndex][Keys.taskDes],
                      status: snapshotList[listIndex][Keys.taskStatus],
                      time: snapshotList[listIndex][Keys.taskTime],
                      date: snapshotList[listIndex][Keys.taskDate],
                      type: snapshotList[listIndex][Keys.taskType],
                      taskDocID: "taskDocID",
                      tileOnPressed: (() {
                        HapticFeedback.heavyImpact();
                      }),
                      tileFirstOnPressed: (() async {
                        if ((snapshotList[listIndex][Keys.taskStatus] !=
                                "Pending") &&
                            (taskSavedDate.difference(widget.date).inMinutes >
                                0)) {
                          http.Response unDoneResponse = await http.post(
                            Uri.parse("${Keys.apiTasksBaseUrl}/unDoneTask"),
                            headers: {
                              "content-Type": "application/json",
                              "authorization": "Bearer ${widget.token}",
                            },
                            body: jsonEncode(
                              {
                                Keys.uid: widget.uid,
                                Keys.notificationID: snapshotList[listIndex]
                                    [Keys.notificationID],
                              },
                            ),
                          );

                          Map<String, dynamic> unDoneResponseJson =
                              jsonDecode(unDoneResponse.body);

                          if (unDoneResponse.statusCode == 200) {
                            if (unDoneResponseJson["success"]) {
                              DateTime date = DateTime.now();

                              if (taskSavedDate.difference(date).inMinutes >
                                  0) {
                                log("unDoneResponseJson=${unDoneResponseJson[Keys.data].toString()}");
                                NotificationServices()
                                    .cancelTaskScheduledNotification(
                                  id: snapshotList[listIndex]
                                      [Keys.notificationID],
                                );
                                NotificationServices()
                                    .createScheduledTaskNotification(
                                  title: snapshotList[listIndex][Keys.taskName],
                                  body:
                                      "${snapshotList[listIndex][Keys.taskName]}\n${snapshotList[listIndex][Keys.taskDes]}",
                                  id: snapshotList[listIndex]
                                      [Keys.notificationID],
                                  payload: "",
                                  dateTime: taskSavedDate,
                                );
                              }

                              showDialog(
                                context: streamContext,
                                builder: (BuildContext unDoneContext) {
                                  Future.delayed(
                                    const Duration(
                                      seconds: 2,
                                    ),
                                    (() {
                                      Navigator.pop(unDoneContext);
                                    }),
                                  );
                                  return const TaskUnDoneDialogChild();
                                },
                              );

                              NotificationServices()
                                  .createScheduledTaskNotification(
                                title: snapshotList[listIndex][Keys.taskName],
                                body:
                                    "${snapshotList[listIndex][Keys.taskName]}\n${snapshotList[listIndex][Keys.taskDes]}",
                                id: snapshotList[listIndex]
                                    [Keys.notificationID],
                                payload: snapshotList[listIndex][Keys.taskName],
                                dateTime: taskSavedDate,
                              );
                            } else {
                              AppSnackbar().customizedAppSnackbar(
                                message: unDoneResponseJson["message"],
                                context: streamContext,
                              );
                            }
                          } else {
                            AppSnackbar().customizedAppSnackbar(
                              message: unDoneResponse.statusCode.toString(),
                              context: streamContext,
                            );
                          }

                          // updateTasks(
                          //   taskDocID: "taskDocID",
                          //   status: snapshotList[listIndex][Keys.taskStatus],
                          //   firestoreEmail: widget.firestoreEmail,
                          //   taskSavedDay: taskSavedDay,
                          //   taskSavedHour: taskSavedHour,
                          //   taskSavedMinute: taskSavedMinute,
                          //   taskSavedMonth: taskSavedMonth,
                          //   taskSavedYear: taskSavedYear,
                          // );

                          // Navigator.push(
                          //   streamContext,
                          //   MaterialPageRoute(
                          //     builder: (nextPageContext) => TempScreen(),
                          //   ),
                          // );
                        } else if (snapshotList[listIndex][Keys.taskStatus] ==
                            "Pending") {
                          http.Response doneResponse = await http.post(
                            Uri.parse("${Keys.apiTasksBaseUrl}/doneTask"),
                            headers: {
                              "content-Type": "application/json",
                              "authorization": "Bearer ${widget.token}",
                            },
                            body: jsonEncode(
                              {
                                Keys.uid: widget.uid,
                                Keys.notificationID: snapshotList[listIndex]
                                    [Keys.notificationID],
                              },
                            ),
                          );

                          Map<String, dynamic> doneResponseJson =
                              jsonDecode(doneResponse.body);

                          if (doneResponse.statusCode == 200) {
                            if (doneResponseJson["success"]) {
                              DateTime date = DateTime.now();

                              if (taskSavedDate.difference(date).inMinutes >
                                  0) {
                                NotificationServices()
                                    .cancelTaskScheduledNotification(
                                  id: snapshotList[listIndex]
                                      [Keys.notificationID],
                                );
                              }

                              showDialog(
                                context: streamContext,
                                builder: (BuildContext doneContext) {
                                  Future.delayed(
                                    const Duration(
                                      seconds: 2,
                                    ),
                                    (() {
                                      Navigator.pop(doneContext);
                                    }),
                                  );
                                  return TaskDialog(
                                    animation:
                                        "assets/success-done-animation.json",
                                    headMessage: "Congratulations",
                                    subMessage: "You completed your task",
                                    subMessageBottomDivision: 5,
                                  );
                                },
                              );
                            } else {
                              AppSnackbar().customizedAppSnackbar(
                                message: doneResponseJson["message"],
                                context: streamContext,
                              );
                            }
                          } else {
                            AppSnackbar().customizedAppSnackbar(
                              message: doneResponse.statusCode.toString(),
                              context: streamContext,
                            );
                          }

                          // updateTasks(
                          //   taskDocID: "taskDocID",
                          //   status: snapshotList[listIndex][Keys.taskStatus],
                          //   firestoreEmail: widget.firestoreEmail,
                          //   taskSavedDay: taskSavedDay,
                          //   taskSavedHour: taskSavedHour,
                          //   taskSavedMinute: taskSavedMinute,
                          //   taskSavedMonth: taskSavedMonth,
                          //   taskSavedYear: taskSavedYear,
                          // );

                          // Navigator.push(
                          //   streamContext,
                          //   MaterialPageRoute(
                          //     builder: (nextPageContext) => TempScreen(),
                          //   ),
                          // );
                        } else {
                          ScaffoldMessenger.of(streamContext).showSnackBar(
                            AppTaskSnackBar().customizedSnackbarForTasks(
                              listIndex: listIndex,
                              firestoreEmail: widget.firestoreEmail,
                              streamContext: streamContext,
                              onPressed: (() {
                                // String taskDocID =
                                //     snapshotList[listIndex].reference.id;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (nextPageContext) => NewTaskScreen(
                                      taskName: snapshotList[listIndex]
                                          [Keys.taskName],
                                      taskDes: snapshotList[listIndex]
                                          [Keys.taskDes],
                                      taskNoti: snapshotList[listIndex]
                                          [Keys.taskNotification],
                                      taskTime: snapshotList[listIndex]
                                          [Keys.taskTime],
                                      taskType: snapshotList[listIndex]
                                          [Keys.taskType],
                                      // taskDoc: "taskDocID",
                                      userEmail: widget.firestoreEmail,
                                      taskDate: snapshotList[listIndex]
                                          [Keys.taskDate],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }
                      }),
                      tileSecondOnPressed: (() {
                        // String taskDocID = snapshotList[listIndex].reference.id;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (nextPageContext) => NewTaskScreen(
                              taskName: snapshotList[listIndex][Keys.taskName],
                              taskDes: snapshotList[listIndex][Keys.taskDes],
                              taskNoti: snapshotList[listIndex]
                                  [Keys.taskNotification],
                              taskTime: snapshotList[listIndex][Keys.taskTime],
                              taskType: snapshotList[listIndex][Keys.taskType],
                              // taskDoc: "taskDocID",
                              notificationID: snapshotList[listIndex]
                                  [Keys.notificationID],
                              userEmail: widget.firestoreEmail,
                              taskDate: snapshotList[listIndex][Keys.taskDate],
                            ),
                          ),
                        );
                      }),
                      tileThirdOnPressed: (() async {
                        // String taskDocID = snapshotList[listIndex].reference.id;

                        if (snapshotList[listIndex][Keys.taskStatus] !=
                            Keys.deleteStatus) {
                          // deleteTasks(
                          //   taskSavedDay: taskSavedDay,
                          //   taskSavedYear: taskSavedYear,
                          //   taskSavedMonth: taskSavedMonth,
                          //   taskSavedMinute: taskSavedMinute,
                          //   taskSavedHour: taskSavedHour,
                          //   taskDocID: taskDocID,
                          //   status: snapshotList[listIndex][Keys.taskStatus],
                          //   firestoreEmail: widget.firestoreEmail,
                          // );

                          http.Response deleteTaskResponse = await http.post(
                            Uri.parse("${Keys.apiTasksBaseUrl}/deleteTask"),
                            headers: {
                              "content-Type": "application/json",
                              "authorization": "Bearer ${widget.token}",
                            },
                            body: jsonEncode(
                              {
                                Keys.uid: widget.uid,
                                Keys.notificationID: snapshotList[listIndex]
                                    [Keys.notificationID],
                              },
                            ),
                          );

                          Map<String, dynamic> deleteTaskResponseJson =
                              jsonDecode(deleteTaskResponse.body);

                          if (deleteTaskResponse.statusCode == 200) {
                            if (deleteTaskResponseJson["success"]) {
                              NotificationServices()
                                  .cancelTaskScheduledNotification(
                                id: snapshotList[listIndex]
                                    [Keys.notificationID],
                              );

                              showDialog(
                                context: streamContext,
                                builder: (BuildContext deleteContext) {
                                  Future.delayed(
                                    const Duration(
                                      seconds: 2,
                                    ),
                                    (() {
                                      Navigator.pop(deleteContext);
                                    }),
                                  );
                                  return TaskDialog(
                                    animation: "assets/deleted-animation.json",
                                    headMessage: "Deleted!",
                                    subMessage: "Your this task is deleted",
                                    subMessageBottomDivision: 5,
                                  );
                                },
                              );
                            } else {
                              AppSnackbar().customizedAppSnackbar(
                                message: deleteTaskResponseJson["message"],
                                context: streamContext,
                              );
                            }
                          } else {
                            AppSnackbar().customizedAppSnackbar(
                              message: deleteTaskResponse.statusCode.toString(),
                              context: streamContext,
                            );
                          }
                        }

                        if ((snapshotList[listIndex][Keys.taskStatus] ==
                            Keys.deleteStatus)) {
                          if (taskSavedDate.difference(widget.date).inMinutes >
                              0) {
                            http.Response undoResponse = await http.post(
                              Uri.parse("${Keys.apiTasksBaseUrl}/undoTask"),
                              headers: {
                                "content-Type": "application/json",
                                "authorization": "Bearer ${widget.token}",
                              },
                              body: jsonEncode(
                                {
                                  Keys.uid: widget.uid,
                                  Keys.notificationID: snapshotList[listIndex]
                                      [Keys.notificationID],
                                },
                              ),
                            );

                            Map<String, dynamic> undoResponseJson =
                                jsonDecode(undoResponse.body);

                            if (undoResponse.statusCode == 200) {
                              if (undoResponseJson["success"]) {
                                NotificationServices()
                                    .createScheduledTaskNotification(
                                  id: undoResponseJson[Keys.notificationID],
                                  title:
                                      undoResponseJson[Keys.taskNotification],
                                  body:
                                      "${undoResponseJson[Keys.taskName]}\n${undoResponseJson[Keys.taskDes]}",
                                  payload: undoResponseJson[Keys.taskDes],
                                  dateTime: taskSavedDate,
                                );

                                showDialog(
                                  context: streamContext,
                                  builder: (BuildContext unDoContext) {
                                    Future.delayed(
                                      const Duration(
                                        seconds: 2,
                                      ),
                                      (() {
                                        Navigator.pop(unDoContext);
                                      }),
                                    );
                                    return TaskDialog(
                                      animation:
                                          "assets/success-done-animation.json",
                                      headMessage: "Woohooo...!",
                                      subMessage:
                                          "Your this message is brought back as pending",
                                      subMessageBottomDivision: 6,
                                    );
                                  },
                                );
                              } else {
                                AppSnackbar().customizedAppSnackbar(
                                  message: undoResponseJson["message"],
                                  context: streamContext,
                                );
                              }
                            } else {
                              AppSnackbar().customizedAppSnackbar(
                                message: undoResponse.statusCode.toString(),
                                context: streamContext,
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(streamContext).showSnackBar(
                              AppTaskSnackBar().customizedSnackbarForTasks(
                                listIndex: listIndex,
                                firestoreEmail: widget.firestoreEmail,
                                streamContext: streamContext,
                                onPressed: (() {
                                  // String taskDocID =
                                  //     snapshotList[listIndex].reference.id;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (nextPageContext) =>
                                          NewTaskScreen(
                                        taskName: snapshotList[listIndex]
                                            [Keys.taskName],
                                        taskDes: snapshotList[listIndex]
                                            [Keys.taskDes],
                                        taskNoti: snapshotList[listIndex]
                                            [Keys.taskNotification],
                                        taskTime: snapshotList[listIndex]
                                            [Keys.taskTime],
                                        taskType: snapshotList[listIndex]
                                            [Keys.taskType],
                                        // taskDoc: taskDocID,
                                        userEmail: widget.firestoreEmail,
                                        taskDate: snapshotList[listIndex]
                                            [Keys.taskDate],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }
                        }
                      }),
                    );
                  },
                  separatorBuilder:
                      (BuildContext separatorContext, int separatorIndex) {
                    return const CustomHomeScreenSeparator();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CustomHomeScreenContainerWithConnectivityWidget extends StatelessWidget {
  const CustomHomeScreenContainerWithConnectivityWidget({
    super.key,
    required this.taskType,
    required this.tabController,
    required this.pendingStatus,
    required this.email,
    required this.widget,
    required ScrollController scrollController,
    required this.date,
    required this.completedStatus,
    required this.inboxStatus,
    required this.userPoints,
    required this.taskDone,
    required this.taskCount,
    required this.taskDelete,
    required this.taskPending,
    required this.taskBusiness,
    required this.taskPersonal,
    required this.token,
    required this.uid,
  }) : _scrollController = scrollController;

  final List<String> taskType;
  final TabController tabController;
  final String pendingStatus;
  final String email;
  final HomeScreen widget;
  final ScrollController _scrollController;
  final DateTime date;
  final String completedStatus;
  final String inboxStatus;
  final int userPoints,
      taskDone,
      taskCount,
      taskDelete,
      taskPending,
      taskBusiness,
      taskPersonal;
  final String token, uid;

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      offlineBanner: const ConnectivityErrorContainer(),
      builder: (connectivityContext, isConnect) {
        return CustomHomeScreenMainColumn(
          taskType: taskType,
          tabController: tabController,
          pendingStatus: pendingStatus,
          email: email,
          widget: widget,
          scrollController: _scrollController,
          date: date,
          completedStatus: completedStatus,
          inboxStatus: inboxStatus,
          userPoints: userPoints,
          taskDone: taskDone,
          taskCount: taskCount,
          taskDelete: taskDelete,
          taskPending: taskPending,
          taskBusiness: taskBusiness,
          taskPersonal: taskPersonal,
          token: token,
          uid: uid,
        );
      },
    );
  }
}

class CustomHomeScreenMainColumn extends StatelessWidget {
  const CustomHomeScreenMainColumn({
    super.key,
    required this.taskType,
    required this.tabController,
    required this.pendingStatus,
    required this.email,
    required this.widget,
    required ScrollController scrollController,
    required this.date,
    required this.completedStatus,
    required this.inboxStatus,
    required this.userPoints,
    required this.taskDone,
    required this.taskCount,
    required this.taskDelete,
    required this.taskPending,
    required this.taskBusiness,
    required this.taskPersonal,
    required this.token,
    required this.uid,
  }) : _scrollController = scrollController;

  final List<String> taskType;
  final TabController tabController;
  final String pendingStatus;
  final String email;
  final HomeScreen widget;
  final ScrollController _scrollController;
  final DateTime date;
  final String completedStatus;
  final String inboxStatus;
  final int userPoints,
      taskDone,
      taskCount,
      taskDelete,
      taskPending,
      taskBusiness,
      taskPersonal;
  final String token, uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          height: 100,
          color: AppColors.backgroundColour,
        ),
        HomeScreenGraphContainer(
          taskDone: taskDone,
          taskDelete: taskDelete,
          taskPersonal: taskPersonal,
          taskPending: taskPending,
          taskCount: taskCount,
          taskBusiness: taskBusiness,
        ),
        HomeScreenTaskTypePickerContainer(taskType: taskType),
        CustomHomeScreenTabBarHeadList(tabController: tabController),
        const SizedBox(
          height: 10,
        ),
        CustomHomeScreenTabBarViewParentContainer(
          tabController: tabController,
          pendingStatus: pendingStatus,
          email: email,
          widget: widget,
          scrollController: _scrollController,
          date: date,
          completedStatus: completedStatus,
          inboxStatus: inboxStatus,
          token: token,
          uid: uid,
        ),

        // bottomTiles(heading: "COMPLETED", value: "10"),
      ],
    );
  }
}

class CustomHomeScreenTabBarViewParentContainer extends StatelessWidget {
  const CustomHomeScreenTabBarViewParentContainer({
    super.key,
    required this.tabController,
    required this.pendingStatus,
    required this.email,
    required this.widget,
    required ScrollController scrollController,
    required this.date,
    required this.completedStatus,
    required this.inboxStatus,
    required this.token,
    required this.uid,
  }) : _scrollController = scrollController;

  final TabController tabController;
  final String pendingStatus;
  final String email;
  final HomeScreen widget;
  final ScrollController _scrollController;
  final DateTime date;
  final String completedStatus;
  final String inboxStatus;
  final String token, uid;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2.3,
      width: MediaQuery.of(context).size.width,
      child: CustomHomeScreenTabBarViewWithConsumer(
        tabController: tabController,
        pendingStatus: pendingStatus,
        email: email,
        widget: widget,
        scrollController: _scrollController,
        date: date,
        completedStatus: completedStatus,
        inboxStatus: inboxStatus,
        token: token,
        uid: uid,
      ),
    );
  }
}

class CustomHomeScreenTabBarViewWithConsumer extends StatelessWidget {
  const CustomHomeScreenTabBarViewWithConsumer({
    super.key,
    required this.tabController,
    required this.pendingStatus,
    required this.email,
    required this.widget,
    required ScrollController scrollController,
    required this.date,
    required this.completedStatus,
    required this.inboxStatus,
    required this.token,
    required this.uid,
  }) : _scrollController = scrollController;

  final TabController tabController;
  final String pendingStatus;
  final String email;
  final HomeScreen widget;
  final ScrollController _scrollController;
  final DateTime date;
  final String completedStatus;
  final String inboxStatus;
  final String token, uid;

  @override
  Widget build(BuildContext context) {
    return Consumer<AllAppProviders>(
      builder:
          (allAppProvidersCtx, allAppProvidersProviders, allAppProvidersChild) {
        return CustomHomeScreenTabBarView(
          tabController: tabController,
          pendingStatus: pendingStatus,
          email: email,
          widget: widget,
          scrollController: _scrollController,
          date: date,
          completedStatus: completedStatus,
          inboxStatus: inboxStatus,
          allAppProvidersProviders: allAppProvidersProviders,
          token: token,
          uid: uid,
        );
      },
    );
  }
}

class CustomHomeScreenTabBarView extends StatelessWidget {
  const CustomHomeScreenTabBarView(
      {super.key,
      required this.tabController,
      required this.pendingStatus,
      required this.email,
      required this.widget,
      required ScrollController scrollController,
      required this.date,
      required this.completedStatus,
      required this.inboxStatus,
      required this.allAppProvidersProviders,
      required this.token,
      required this.uid})
      : _scrollController = scrollController;

  final TabController tabController;
  final String pendingStatus;
  final String email;
  final HomeScreen widget;
  final ScrollController _scrollController;
  final DateTime date;
  final String completedStatus;
  final String inboxStatus;
  final AllAppProviders allAppProvidersProviders;
  final String token, uid;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      physics: AppColors.scrollPhysics,
      controller: tabController,
      children: [
        CustomHomeScreenTabs(
          type: allAppProvidersProviders.selectedType,
          status: pendingStatus,
          firestoreEmail: email,
          widget: widget,
          scrollController: _scrollController,
          date: date,
          token: token,
          uid: uid,
        ),
        CustomHomeScreenTabs(
          type: allAppProvidersProviders.selectedType,
          status: completedStatus,
          firestoreEmail: email,
          widget: widget,
          scrollController: _scrollController,
          date: date,
          token: token,
          uid: uid,
        ),
        CustomHomeScreenTabs(
          type: allAppProvidersProviders.selectedType,
          status: inboxStatus,
          firestoreEmail: email,
          widget: widget,
          scrollController: _scrollController,
          date: date,
          token: token,
          uid: uid,
        ),
        CustomHomeScreenTabs(
          type: allAppProvidersProviders.selectedType,
          status: Keys.deleteStatus,
          firestoreEmail: email,
          widget: widget,
          scrollController: _scrollController,
          date: date,
          token: token,
          uid: uid,
        ),
      ],
    );
  }
}
