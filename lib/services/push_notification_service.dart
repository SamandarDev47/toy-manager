import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(initSettings);

    if (Platform.isIOS) {
      await _fcm.requestPermission();
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(
          notification.title ?? "Yangi xabar",
          notification.body ?? "",
        );
      }
    });
  }

  static Future<void> _showLocalNotification(
      String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'push_channel',
      'Push Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _localNotifications.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<String?> getToken() async {
    final token = await _fcm.getToken();
    print("📱 FCM Token: $token");
    return token;
  }
}
