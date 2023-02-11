import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/notification_services.dart';
import 'package:task_app/providers/all_tasks_provider.dart';
import 'package:task_app/providers/app_providers.dart';
import 'package:task_app/providers/google_sign_in.dart';
import 'package:task_app/providers/task_details_provider.dart';
import 'package:task_app/providers/user_details_providers.dart';
import 'package:task_app/screens/splash_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationServices().init();
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: "TasksChannel",
        channelName: "TasksChannelName",
        channelDescription: "TasksChannelDes",
      ),
    ],
    debug: true,
  );
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AllAppProviders(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserDetailsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GoogleSignInProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskDetailsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AllTaskProvider(),
        ),
      ],
      child: const TaskApp(),
    ),
  );
}

class TaskApp extends StatelessWidget {
  const TaskApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
