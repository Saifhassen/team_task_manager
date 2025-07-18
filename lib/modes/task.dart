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
  final int colorValue; // بدل Color

  Color get color => Color(colorValue); // للحصول عليه عند الاستخدام

  @HiveField(8)
  final DateTime? endDate;

  @HiveField(9)
  final String editorName;

  // الحقول الجديدة للاستفسار
  @HiveField(10)
  bool inquiryResponded;

  @HiveField(11)
  bool inquirySentToAdmin;

  @HiveField(12)
  String? inquiryReply;

  @HiveField(13)
  String? firebaseId; // ID من Firebase

  @HiveField(14)
  bool isSynced; // هل تم رفع المهمة إلى Firebase؟

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
    this.firebaseId,
    this.isSynced = false,
  });

  // تحويل كائن Task إلى خريطة (Map) للاستخدام في Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'notes': notes,
      'type': type,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'unitType': unitType,
      'assignedPeople': assignedPeople,
      'colorValue': colorValue,
      'editorName': editorName,
      'endDate': endDate?.toIso8601String(),
      'inquiryResponded': inquiryResponded,
      'inquirySentToAdmin': inquirySentToAdmin,
      'inquiryReply': inquiryReply,
      'firebaseId': firebaseId,
      'isSynced': isSynced,
    };
  }

  // إنشاء كائن Task من خريطة (Map) مستلمة من Firebase
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] ?? '',
      notes: map['notes'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      unitType: map['unitType'] ?? '',
      assignedPeople: List<Map<String, dynamic>>.from(map['assignedPeople'] ?? []),
      colorValue: map['colorValue'] ?? 0,
      editorName: map['editorName'] ?? '',
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      inquiryResponded: map['inquiryResponded'] ?? false,
      inquirySentToAdmin: map['inquirySentToAdmin'] ?? false,
      inquiryReply: map['inquiryReply'],
      firebaseId: map['firebaseId'],
      isSynced: map['isSynced'] ?? false,
    );
  }
}
