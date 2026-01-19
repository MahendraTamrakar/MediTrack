import 'package:flutter/material.dart';
import 'package:medtrack/core/theme.dart';
import 'package:medtrack/screens/home_screen.dart';

class MedicineReminderApp extends StatefulWidget {
  const MedicineReminderApp({super.key});

  @override
  State<MedicineReminderApp> createState() => _MedicineReminderAppState();
}

class _MedicineReminderAppState extends State<MedicineReminderApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}