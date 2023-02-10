import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_login/service/local_notification.dart';
import 'package:google_login/utils/shared_preference_utils.dart';
import 'package:google_login/view/home_screen.dart';
import 'package:google_login/view/login_screen.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  log("======backGround======${message.notification!.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationServices.initialize();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isLogin;
  String? fcmToken;

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future getFcmToken() async {
    fcmToken = await messaging.getToken();
    log('====fcmToken====$fcmToken');
  }

  @override
  void initState() {
    isLogin = PreferenceManagerUtils.getLogin();
    super.initState();
    getFcmToken();

    ///Notification
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        if (message != null) {
          Get.to(HomeScreen());
        }
      },
    );

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        log("===========message======${message.notification!.body}");
        LocalNotificationServices.display(
          message.notification!.title,
          message.notification!.body,
        );
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        print('Message clicked!');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // ignore: unrelated_type_equality_checks
      home: isLogin == true ? HomeScreen() : LoginScreen(),
    );
  }
}
