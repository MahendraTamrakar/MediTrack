import 'package:flutter/material.dart';
import 'package:medtrack/screens/add_medicine_screen.dart';
import 'package:medtrack/screens/alarm_screen.dart';
import 'package:medtrack/screens/widgets/empty_state.dart';
import 'package:medtrack/screens/widgets/medicine_card.dart';
import 'package:medtrack/utils/constants.dart';
import 'package:medtrack/viewmodels/medicine_viewmodels.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Medicine Reminder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // Debug/Test button
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Test Alarms',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlarmTestScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MedicineViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryTeal,
              ),
            );
          }

          if (viewModel.medicines.isEmpty) {
            return const EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.medicines.length,
            itemBuilder: (context, index) {
              final medicine = viewModel.medicines[index];
              return MedicineCard(
                medicine: medicine,
                onDelete: () => viewModel.deleteMedicine(medicine.id),
                onToggle: () => viewModel.toggleMedicine(medicine.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          );
        },
        backgroundColor: AppColors.accentOrange,
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
    );
  }
}