import 'package:flutter/material.dart';
import 'package:medtrack/viewmodels/medicine_viewmodels.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';

class AlarmTestScreen extends StatelessWidget {
  const AlarmTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MedicineViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('🧪 Alarm Testing'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.primaryTeal.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 8),
                        Text(
                          'Alarm Testing',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Use these buttons to test alarm notifications.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // -------- TEST NOW --------
            _TestButton(
              icon: Icons.notifications_active,
              label: 'Test Alarm Now',
              description: 'Triggers alarm after 5 seconds',
              color: AppColors.accentOrange,
              onPressed: () async {
                await viewModel.testAlarm();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🚨 Test alarm will ring in 5 seconds'),
                      backgroundColor: AppColors.primaryTeal,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 12),

            // -------- SCHEDULE 1 MIN --------
            _TestButton(
              icon: Icons.schedule,
              label: 'Schedule Test (1 min)',
              description: 'Schedules an alarm for 1 minute later',
              color: AppColors.primaryTeal,
              onPressed: () async {
                final scheduledTime =
                    DateTime.now().add(const Duration(minutes: 1));

                final success = await viewModel.addMedicine(
                  name: 'Test Scheduled Alarm',
                  dose: '1 tablet',
                  scheduledTime: scheduledTime,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '⏰ Alarm scheduled for 1 minute!'
                            : '❌ Failed to schedule alarm',
                      ),
                      backgroundColor:
                          success ? AppColors.primaryTeal : Colors.red,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 12),

            // -------- INFO --------
            _TestButton(
              icon: Icons.info,
              label: 'Check Logs',
              description: 'See console logs for scheduled alarms',
              color: Colors.blue,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📋 Check console logs for alarms'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onPressed;

  const _TestButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
