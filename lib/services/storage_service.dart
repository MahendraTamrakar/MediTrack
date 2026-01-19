import 'package:hive/hive.dart';
import '../models/medicine_model.dart';

class StorageService {
  static const String _boxName = 'medicines';

  Box<MedicineModel> get _box => Hive.box<MedicineModel>(_boxName);

  // Get all medicines
  Future<List<MedicineModel>> getAllMedicines() async {
    return _box.values.toList();
  }

  // Save medicine
  Future<void> saveMedicine(MedicineModel medicine) async {
    await _box.put(medicine.id, medicine);
  }

  // Update medicine
  Future<void> updateMedicine(MedicineModel medicine) async {
    await medicine.save();
  }

  // Delete medicine
  Future<void> deleteMedicine(String id) async {
    await _box.delete(id);
  }

  // Clear all medicines
  Future<void> clearAll() async {
    await _box.clear();
  }
}