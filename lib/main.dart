import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:task_app/providers/all_tasks_provider.dart';
import 'package:task_app/providers/app_providers.dart';
import 'package:task_app/providers/song_playing_provider.dart';
import 'package:task_app/providers/task_details_provider.dart';
import 'package:task_app/providers/user_details_providers.dart';
import 'package:task_app/screens/splash_screen.dart';
import 'package:task_app/services/auth_services.dart';
import 'package:task_app/services/notification_services.dart';
import 'package:task_app/services/shared_preferences.dart';
import 'package:task_app/styles.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await isMusicPlaying();
  await NotificationServices().init();
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: Keys.tasksInstantChannelKey,
        channelName: Keys.tasksInstantChannelName,
        channelDescription: Keys.tasksInstantChannelDes,
        defaultColor: AppColors.backgroundColour,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
      NotificationChannel(
        channelKey: Keys.tasksScheduledChannelKey,
        channelName: Keys.tasksScheduledChannelName,
        channelDescription: Keys.tasksScheduledChannelDes,
        defaultColor: AppColors.backgroundColour,
        importance: NotificationImportance.High,
        locked: true,
        channelShowBadge: true,
      ),
    ],
    debug: true,
  );
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  NowPlaying.instance.start();
  final bool isEnabled = await NowPlaying.instance.isEnabled();
  final phonePermission = await Permission.phone.status;

  if (!isEnabled) {
    final bool hasShownPermissions =
        await NowPlaying.instance.requestPermissions();
    if (!hasShownPermissions) {
      NowPlaying.instance.requestPermissions(force: true);
    }
  }

  if (phonePermission.isRestricted || phonePermission.isDenied) {
    Permission.phone.request();
  } else if (phonePermission.isPermanentlyDenied) {
    openAppSettings();
  }

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

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
        ChangeNotifierProvider(
          create: (_) => SongPlayingProvider(),
        ),
      ],
      child: StreamProvider.value(
        value: NowPlaying.instance.stream,
        initialData: NowPlayingTrack.notPlaying,
        child: const TaskApp(),
      ),
    ),
  );
}

class TaskApp extends StatefulWidget {
  const TaskApp({Key? key}) : super(key: key);

  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
