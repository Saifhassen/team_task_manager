import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  String notes;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime startDate;

  @HiveField(5)
  final String unitType;

  @HiveField(6)
  final List<Map<String, dynamic>> assignedPeople;

  @HiveField(7)
  final int colorValue; // <-- بدل Color

  Color get color => Color(colorValue); // للحصول عليه عند الاستخدام

  @HiveField(8)
  final DateTime? endDate;

  @HiveField(9)
  final String editorName;

  // ✅ الحقول الجديدة للاستفسار
  @HiveField(10)
  bool inquiryResponded;

  @HiveField(11)
  bool inquirySentToAdmin;

  @HiveField(12)
  String? inquiryReply;

  Task({
    required this.title,
    required this.notes,
    required this.type,
    required this.description,
    required this.startDate,
    required this.unitType,
    required this.assignedPeople,
    required this.colorValue,
    required this.editorName,
    this.endDate,
    this.inquiryResponded = false,
    this.inquirySentToAdmin = false,
    this.inquiryReply,
  });
}
