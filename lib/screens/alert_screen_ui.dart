import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtrack/services/notification_service.dart';
import 'package:medtrack/utils/constants.dart';

class AlarmScreenUI extends StatefulWidget {
  final String medicineName;
  final String dose;
  final String time;
  final int notificationId;

  const AlarmScreenUI({
    super.key,
    required this.medicineName,
    required this.dose,
    required this.time,
    required this.notificationId,
  });

  @override
  State<AlarmScreenUI> createState() => _AlarmScreenUIState();
}

class _AlarmScreenUIState extends State<AlarmScreenUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _stopAlarm() async {
    await NotificationService.cancelAlarm(widget.notificationId);

    if (mounted) {
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 250));
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      }
    }
  }

  Future<void> _snoozeAlarm() async {
    await NotificationService.snoozeAlarm(
      widget.notificationId,
      widget.medicineName,
      widget.dose,
      snoozeMinutes: 10,
    );

    if (mounted) {
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 300));
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      }
      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏰ Snoozed for 10 minutes'),
          duration: Duration(seconds: 2),
        ),
      ); */
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryTeal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing medicine icon
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_controller.value * 0.3),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 28,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(26.0),
                        child: Image.asset('assets/medicine.png'),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),

              Text(
                widget.time,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                widget.medicineName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  widget.dose,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                '💊 Time to take your medicine',
                style: TextStyle(fontSize: 18, color: Colors.white70),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _stopAlarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'I TOOK IT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: _snoozeAlarm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.snooze, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Snooze (10 min)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
