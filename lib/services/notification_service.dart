import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medtrack/screens/alert_screen_ui.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'medicine_alarm_channel';
  static const String _channelName = 'Medicine Alarms';
  static const String _channelDescription = 'Critical medicine reminder alarms';

  static const String _actionStop = 'STOP_ALARM';
  static const String _actionSnooze = 'SNOOZE_ALARM';

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    try {
      debugPrint('═══════════════════════════════════════');
      debugPrint('🚀 INITIALIZING NOTIFICATION SERVICE');
      debugPrint('═══════════════════════════════════════');

      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      debugPrint('✅ Timezone initialized: Asia/Kolkata');

      await _requestPermissions();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings =
          InitializationSettings(android: androidSettings);

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onNotificationTappedBackground,
      );
      debugPrint('✅ Notification plugin initialized');

      debugPrint('═══════════════════════════════════════');
      debugPrint('✅ NOTIFICATION SERVICE READY');
      debugPrint('═══════════════════════════════════════');
    } catch (e, stack) {
      debugPrint('❌ Notification initialization error: $e');
      debugPrint('Stack: $stack');
    }
  }

  static Future<void> _requestPermissions() async {
    try {
      final notificationStatus = await Permission.notification.request();
      final alarmStatus = await Permission.scheduleExactAlarm.request();

      debugPrint('📱 Notification permission: $notificationStatus');
      debugPrint('⏰ Exact alarm permission: $alarmStatus');

      if (!notificationStatus.isGranted) {
        debugPrint('⚠️ WARNING: Notification permission not granted!');
      }
      if (!alarmStatus.isGranted) {
        debugPrint('⚠️ WARNING: Exact alarm permission not granted!');
      }
    } catch (e) {
      debugPrint('⚠️ Error requesting permissions: $e');
    }
  }

  static Future<void> scheduleMedicineAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    try {
      debugPrint('═══════════════════════════════════════');
      debugPrint('📅 SCHEDULING ALARM');
      debugPrint('═══════════════════════════════════════');

      final now = DateTime.now();
      var scheduledTime = dateTime;
      
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
        debugPrint('⏭️ Time passed, rescheduling for tomorrow');
      }

      debugPrint('🕐 Scheduled time: $scheduledTime');
      debugPrint('🆔 Notification ID: $id');
      debugPrint('⏱️ Minutes until alarm: ${scheduledTime.difference(now).inMinutes}');

      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        
        importance: Importance.max,
        priority: Priority.max,
        
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        
        ticker: title,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF008080),
        
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),

        visibility: NotificationVisibility.public,
        autoCancel: false,
        ongoing: true,
        
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            _actionStop,
            '✓ STOP & TOOK IT',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            _actionSnooze,
            '⏰ Snooze 10min',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
        
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
        ),
      );

      NotificationDetails details =
          NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '$id|$title|$body|${_formatTime(dateTime)}',
      );

      debugPrint('✅ ALARM SCHEDULED SUCCESSFULLY');
      
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('📋 Total pending: ${pending.length}');
      
      debugPrint('═══════════════════════════════════════');
    } catch (e, stack) {
      debugPrint('❌ ERROR: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('👆 Notification tapped: ${response.actionId}');
    
    if (response.actionId == _actionStop) {
      _handleStopAlarm(response);
    } else if (response.actionId == _actionSnooze) {
      _handleSnoozeAlarm(response);
    } else {
      _showFullScreenAlarm(response);
    }
  }

  @pragma('vm:entry-point')
  static void _onNotificationTappedBackground(NotificationResponse response) {
    _onNotificationTapped(response);
  }

  static void _handleStopAlarm(NotificationResponse response) {
    debugPrint('✅ Alarm stopped by user');
    if (response.id != null) {
      cancelAlarm(response.id!);
    }
  }

  static void _handleSnoozeAlarm(NotificationResponse response) {
    debugPrint('⏰ Alarm snoozed by user');
    
    if (response.payload != null && response.id != null) {
      final parts = response.payload!.split('|');
      if (parts.length >= 3) {
        final medicineName = parts[1];
        final dose = parts[2];
        
        snoozeAlarm(response.id!, medicineName, dose);
      }
    }
  }

  static void _showFullScreenAlarm(NotificationResponse response) {
    if (response.payload == null) return;
    
    final parts = response.payload!.split('|');
    if (parts.length < 4) return;
    
    final id = int.tryParse(parts[0]) ?? 0;
    final medicineName = parts[1];
    final dose = parts[2];
    final time = parts[3];
    
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AlarmScreenUI(
          medicineName: medicineName,
          dose: dose,
          time: time,
          notificationId: id,
        ),
      ),
    );
  }

  static Future<void> snoozeAlarm(
    int originalId,
    String medicineName,
    String dose, {
    int snoozeMinutes = 10,
  }) async {
    final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMinutes));
    final newId = DateTime.now().millisecondsSinceEpoch % 2147483647;
    
    await scheduleMedicineAlarm(
      id: newId,
      title: '💊 Medicine Reminder (Snoozed)',
      body: '$medicineName - $dose',
      dateTime: snoozeTime,
    );
    
    debugPrint('⏰ Snoozed alarm for $snoozeMinutes minutes');
  }

  static Future<void> cancelAlarm(int id) async {
    await _notifications.cancel(id);
    debugPrint('🔕 Cancelled alarm: $id');
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('🔕 Cancelled all alarms');
  }

  static Future<List<PendingNotificationRequest>> getPendingAlarms() async {
    return await _notifications.pendingNotificationRequests();
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }
}