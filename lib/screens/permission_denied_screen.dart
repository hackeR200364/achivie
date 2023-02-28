import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:task_app/Utils/snackbar_utils.dart';
import 'package:task_app/screens/sign_screen.dart';
import 'package:task_app/styles.dart';

import '../services/shared_preferences.dart';
import 'main_screen.dart';

class PermissionDeniedScreen extends StatefulWidget {
  const PermissionDeniedScreen({Key? key}) : super(key: key);

  @override
  State<PermissionDeniedScreen> createState() => _PermissionDeniedScreenState();
}

class _PermissionDeniedScreenState extends State<PermissionDeniedScreen> {
  bool? signStatus = false;
  @override
  void initState() {
    getUserSignStatus();
    super.initState();
  }

  void getUserSignStatus() async {
    signStatus = await StorageServices.getSignStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.mainColor,
        body: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "We need all the permissions to run the app properly",
                textAlign: TextAlign.center,
                style: AppColors.headingTextStyle,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 20,
              ),
              Center(
                child: InkWell(
                  onTap: (() async {
                    Map<Permission, PermissionStatus> statuses = await [
                      Permission.accessNotificationPolicy,
                      Permission.notification,
                      Permission.phone,
                      Permission.sms,
                    ].request();
                    bool isAnyPermissionDenied =
                        statuses.values.any((status) => status.isDenied);
                    if (isAnyPermissionDenied) {
                      AppSnackbar().customizedAppSnackbar(
                        message: "Please give us all permission",
                        context: context,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => (signStatus!)
                              ? const MainScreen()
                              : const SignUpScreen(),
                        ),
                      );
                    }
                  }),
                  child: GlassmorphicContainer(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 50,
                    borderRadius: 20,
                    linearGradient: AppColors.customGlassIconButtonGradient,
                    border: 2,
                    blur: 4,
                    borderGradient:
                        AppColors.customGlassIconButtonBorderGradient,
                    child: const Center(
                      child: Text(
                        "Visit Website",
                        style: AppColors.headingTextStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
