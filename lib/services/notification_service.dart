import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ---------------- INIT ----------------
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(settings);

    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }

  // ---------------- SCHEDULE ALARM ----------------
  static Future<void> scheduleMedicineAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    if (dateTime.isBefore(DateTime.now())) {
      dateTime = dateTime.add(const Duration(days: 1));
    }

    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(dateTime, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medicine_channel',
      'Medicine Reminders',
      channelDescription: 'Medicine reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ---------------- CANCEL ALARM ----------------
  static Future<void> cancelAlarm(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // ---------------- CANCEL ALL ----------------
  static Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}