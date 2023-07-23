import 'dart:convert';
import 'dart:developer';

import 'package:achivie/providers/app_providers.dart';
import 'package:achivie/providers/news_searching_provider.dart';
import 'package:achivie/providers/song_playing_provider.dart';
import 'package:achivie/providers/user_details_providers.dart';
import 'package:achivie/screens/splash_screen.dart';
import 'package:achivie/services/keys.dart';
import 'package:achivie/services/notification_services.dart';
import 'package:achivie/services/shared_preferences.dart';
import 'package:achivie/styles.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:nowplaying/nowplaying.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background FCM messages here

  NotificationServices().onReceiveFCMNotification(message);
  print("onBackgroundMessage: ${message.data}");
}

Future main() async {
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
  await Firebase.initializeApp();

  // await isMusicPlaying();
  // await NotificationServices().init();

  final bool isEnabled = await NowPlaying.instance.isEnabled();

  // final phonePermission = await Permission.phone.status;

  if (!isEnabled) {
    final bool hasShownPermissions =
        await NowPlaying.instance.requestPermissions();
    if (!hasShownPermissions) {
      NowPlaying.instance.requestPermissions(force: true);
    }
  }

  await [
    Permission.audio,
    Permission.storage,
  ].request();

  bool signStatus = await StorageServices.getSignStatus();
  log(signStatus.toString());

  if (!signStatus) {
    await Permission.notification.request();
    await Permission.accessNotificationPolicy.request();
  }

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
        channelKey: Keys.sponsorChannelKey,
        channelName: Keys.sponsorChannelName,
        channelDescription: Keys.sponsorChannelDes,
        defaultColor: AppColors.backgroundColour,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
      // NotificationChannel(
      //   channelKey: Keys.tasksScheduledChannelKey,
      //   channelName: Keys.tasksScheduledChannelName,
      //   channelDescription: Keys.tasksScheduledChannelDes,
      //   defaultColor: AppColors.backgroundColour,
      //   importance: NotificationImportance.High,
      //   locked: true,
      //   channelShowBadge: true,
      // ),
    ],
    // channelGroups: [
    //   NotificationChannelGroup(
    //     channelGroupKey: Keys.tasksInstantChannelKey,
    //     channelGroupName: Keys.tasksInstantChannelKeyGroup,
    //   ),
    // ],
    debug: true,
  );

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  await _firebaseMessaging.requestPermission();
  log(await _firebaseMessaging.getToken() ?? "");
  _firebaseMessaging.onTokenRefresh.listen((token) async {
    String usrToken = await StorageServices.getUsrToken();
    http.Response response = await http.post(
      Uri.parse("${Keys.apiUsersBaseUrl}/updateNotificationToken/$token"),
      headers: {
        "content-type": "application/json",
        'Authorization': 'Bearer $usrToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      if (responseJson["success"] == true) {
        StorageServices.setNotificationToken(
            (await FirebaseMessaging.instance.getToken())!);
      }
    }
  });
  await _firebaseMessaging.subscribeToTopic("SPONSOR");
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    NotificationServices().onReceiveFCMNotification(message);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    NotificationServices().onReceiveFCMNotification(message);
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await Firebase.initializeApp();
  MobileAds.instance.initialize();
  NowPlaying.instance.start();

  // if (phonePermission.isRestricted || phonePermission.isDenied) {
  //   Permission.phone.request();
  // } else if (phonePermission.isPermanentlyDenied) {
  //   openAppSettings();
  // }

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  FlutterNativeSplash.remove();

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
          create: (_) => SongPlayingProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NewsSearchingProvider(),
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.backgroundColour,
          secondary: AppColors.backgroundColour.withOpacity(0.5),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
