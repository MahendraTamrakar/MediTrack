import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 0)
class MedicineModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String dose;

  @HiveField(3)
  DateTime scheduledTime;

  @HiveField(4)
  bool isActive;

  MedicineModel({
    required this.id,
    required this.name,
    required this.dose,
    required this.scheduledTime,
    this.isActive = true,
  });

  int compareTo(MedicineModel other) {
    final thisTime = TimeOfDay.fromDateTime(scheduledTime);
    final otherTime = TimeOfDay.fromDateTime(other.scheduledTime);
    
    final thisMinutes = thisTime.hour * 60 + thisTime.minute;
    final otherMinutes = otherTime.hour * 60 + otherTime.minute;
    
    return thisMinutes.compareTo(otherMinutes);
  }
}