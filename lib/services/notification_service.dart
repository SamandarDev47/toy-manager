import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  /// 🔹 Dastlabki sozlash
  static Future<void> initialize() async {
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);
  }

  /// 🔹 Darhol (hozir) xabar yuborish
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'wedding_channel',
        'Wedding Notifications',
        channelDescription: 'To‘ylar uchun bildirishnomalar',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notifications.show(id, title, body, details);
  }

  /// 🔹 Belgilangan vaqtda xabar yuborish (masalan ertangi to‘y)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'wedding_channel',
          'Wedding Notifications',
          channelDescription: 'To‘ylar uchun bildirishnomalar',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// 🔹 Xabarni o‘chirish
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// 🔹 Barcha xabarlarni tozalash
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
