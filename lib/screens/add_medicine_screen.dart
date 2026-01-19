import 'package:flutter/material.dart';
import 'package:medtrack/utils/helper.dart';
import 'package:medtrack/viewmodels/medicine_viewmodels.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveMedicine() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isSaving = true;
  });

  final viewModel = context.read<MedicineViewModel>();
  final scheduledTime = DateTimeHelper.combineDateAndTime(
    DateTime.now(),
    _selectedTime,
  );

  debugPrint('🕐 Scheduling medicine for: $scheduledTime');
  debugPrint('🕐 Current time: ${DateTime.now()}');
  debugPrint('🕐 Time difference: ${scheduledTime.difference(DateTime.now()).inMinutes} minutes');

  final success = await viewModel.addMedicine(
    name: _nameController.text.trim(),
    dose: _doseController.text.trim(),
    scheduledTime: scheduledTime,
  );

  setState(() {
    _isSaving = false;
  });

  if (success && mounted) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Alarm set for ${_selectedTime.format(context)}',
        ),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Medicine'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                  hintText: 'e.g., Aspirin',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/medicine.png', height: 25, width: 25),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryTeal,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _doseController,
                decoration: InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g., 500mg or 2 tablets',
                 prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/drugs.png', height: 25, width: 25),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryTeal,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/timer.png', height: 30 ,width: 30,),
                      const SizedBox(width: 12),
                      Text(
                        'Time: ${_selectedTime.format(context)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Medicine',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}