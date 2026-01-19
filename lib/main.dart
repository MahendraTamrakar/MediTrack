import 'package:flutter/material.dart';
import 'package:medtrack/viewmodels/medicine_viewmodels.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medtrack/app/app.dart';
import 'package:medtrack/models/medicine_model.dart';
import 'package:medtrack/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MedicineModelAdapter());
  await Hive.openBox<MedicineModel>('medicines');
  
  // Initialize Notifications
  await NotificationService.initialize();

    final notificationStatus = await Permission.notification.status;
  final alarmStatus = await Permission.scheduleExactAlarm.status;
  debugPrint('📱 Notification permission: $notificationStatus');
  debugPrint('⏰ Exact alarm permission: $alarmStatus');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicineViewModel()),
      ],
      child: const MedicineReminderApp(),
    ),
  );
}