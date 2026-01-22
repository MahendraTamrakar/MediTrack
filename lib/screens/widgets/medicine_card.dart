import 'package:flutter/material.dart';
import 'package:medtrack/utils/helper.dart';
import '../../models/medicine_model.dart';
import '../../utils/constants.dart';

class MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(72, 0, 128, 128),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset('assets/medicine.png', fit:BoxFit.contain ,)
        ),
        title: Text(
          medicine.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: medicine.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Dose: ${medicine.dose}'),
            Text(
              'Time: ${DateTimeHelper.formatTime(medicine.scheduledTime)}',
              style: const TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _daysDisplay(medicine.days),
              style: const TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: medicine.isActive,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primaryTeal,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Medicine'),
                    content: Text('Delete ${medicine.name}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          onDelete();
                          Navigator.pop(context);
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  // Helper to display days as string
  String _daysDisplay(List<int> days) {
    if (days.length == 7) return 'Every Day';
    if (_isWeekdays(days)) return 'Weekdays';
    if (_isWeekends(days)) return 'Weekends';
    const abbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = List<int>.from(days)..sort();
    return sortedDays
        .map((d) => abbr[d - 1])
        .join(', ');
  }

  bool _isWeekdays(List<int> days) => days.toSet().containsAll([1,2,3,4,5]) && days.length == 5;
  bool _isWeekends(List<int> days) => days.toSet().containsAll([6,7]) && days.length == 2;
}