import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_login/view/home_screen.dart';

class LocalNotificationServices {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    _notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onselectednotification,
    );
  }

  static onselectednotification(String? text) {
    return Get.to(HomeScreen());
  }

  static Future display(String? title, String? body) async {
    const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
      "google_login",
      "google_login",
      channelDescription: "google_login",
      priority: Priority.high,
      importance: Importance.max,
    ));
    await _notificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}
