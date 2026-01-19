import 'package:flutter/material.dart';
import 'package:medtrack/services/notification_service.dart';
import 'package:medtrack/services/storage_service.dart';
import '../models/medicine_model.dart';

class MedicineViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<MedicineModel> _medicines = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MedicineModel> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MedicineViewModel() {
    loadMedicines();
  }

  int _getSafeNotificationId(String id) {
    return int.parse(id) % 2147483647;
  }

  // ---------------- LOAD ----------------
  Future<void> loadMedicines() async {
    try {
      _isLoading = true;
      notifyListeners();

      _medicines = await _storageService.getAllMedicines();
      _medicines.sort((a, b) => a.compareTo(b));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load medicines: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- ADD ----------------
  Future<bool> addMedicine({
    required String name,
    required String dose,
    required DateTime scheduledTime,
  }) async {
    try {
      final randomId =
          DateTime.now().microsecondsSinceEpoch % 2147483647;

      final medicine = MedicineModel(
        id: randomId.toString(),
        name: name,
        dose: dose,
        scheduledTime: scheduledTime,
      );

      await _storageService.saveMedicine(medicine);

      await NotificationService.scheduleMedicineAlarm(
        id: _getSafeNotificationId(medicine.id),
        title: 'Medicine Reminder',
        body: '${medicine.name} - ${medicine.dose}',
        dateTime: medicine.scheduledTime,
      );

      await loadMedicines();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add medicine: $e';
      notifyListeners();
      return false;
    }
  }

  // ---------------- DELETE ----------------
  Future<void> deleteMedicine(String id) async {
    try {
      await _storageService.deleteMedicine(id);

      await NotificationService.cancelAlarm(
        _getSafeNotificationId(id),
      );

      await loadMedicines();
    } catch (e) {
      _errorMessage = 'Failed to delete medicine: $e';
      notifyListeners();
    }
  }

  // ---------------- TOGGLE ----------------
  Future<void> toggleMedicine(String id) async {
    try {
      final medicine = _medicines.firstWhere((m) => m.id == id);
      medicine.isActive = !medicine.isActive;

      await _storageService.updateMedicine(medicine);

      if (medicine.isActive) {
        await NotificationService.scheduleMedicineAlarm(
          id: _getSafeNotificationId(medicine.id),
          title: 'Medicine Reminder',
          body: '${medicine.name} - ${medicine.dose}',
          dateTime: medicine.scheduledTime,
        );
      } else {
        await NotificationService.cancelAlarm(
          _getSafeNotificationId(medicine.id),
        );
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to toggle medicine: $e';
      notifyListeners();
    }
  }

  // ---------------- SNOOZE ----------------
  Future<void> snoozeMedicine(String id, {int snoozeMinutes = 10}) async {
    try {
      final medicine = _medicines.firstWhere((m) => m.id == id);

      final snoozeTime =
          DateTime.now().add(Duration(minutes: snoozeMinutes));

      final snoozeId =
          DateTime.now().microsecondsSinceEpoch % 2147483647;

      await NotificationService.scheduleMedicineAlarm(
        id: snoozeId,
        title: 'Snoozed Medicine',
        body: '${medicine.name} - ${medicine.dose}',
        dateTime: snoozeTime,
      );
    } catch (e) {
      debugPrint('❌ Snooze error: $e');
    }
  }

  // ---------------- TEST ALARM ----------------
  Future<void> testAlarm() async {
    final testTime = DateTime.now().add(const Duration(seconds: 5));

    await NotificationService.scheduleMedicineAlarm(
      id: DateTime.now().microsecondsSinceEpoch % 2147483647,
      title: 'Test Alarm',
      body: 'This is a test alarm',
      dateTime: testTime,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
