import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/task_details_provider.dart';
import '../styles.dart';

class TempScreen extends StatefulWidget {
  const TempScreen({Key? key}) : super(key: key);

  @override
  State<TempScreen> createState() => _TempScreenState();
}

class _TempScreenState extends State<TempScreen> {
  String TotalTaskSuffix(int task) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Lottie.asset(
              "assets/success-done-animation.json",
            ),
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height / 4,
            child: const Center(
              child: Text(
                "Brought Back",
                style: TextStyle(
                  color: AppColors.backgroundColour,
                  fontSize: 35,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 6,
            left: 0,
            right: 0,
            child: Consumer<TaskDetailsProvider>(builder:
                (taskDetailsContext, taskDetailsProvider, taskDetailsChild) {
              return const Center(
                child: Text(
                  "Your this task is brought back as pending",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.backgroundColour,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
