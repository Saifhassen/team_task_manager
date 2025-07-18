import 'dart:ui' as ui;
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_task_manager/modes/task.dart';

class InquiryScreen extends StatelessWidget {
  final List<Task> allTasks;
  final String loggedEngineer;
  final Function(Task, int) onExtendDays;

  const InquiryScreen({
    Key? key,
    required this.allTasks,
    required this.loggedEngineer,
    required this.onExtendDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Task> inquiries =
        allTasks
            .where(
              (t) => t.inquiryResponded == true && t.inquirySentToAdmin == true,
            )
            .toList();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('الاستفسارات')),
        body:
            inquiries.isEmpty
                ? Center(child: Text('لا توجد استفسارات حالياً'))
                : ListView.builder(
                  itemCount: inquiries.length,
                  itemBuilder: (context, index) {
                    final task = inquiries[index];
                    final engineer = task.assignedPeople.firstWhere(
                      (p) => p['isDone'] == false,
                      orElse: () => task.assignedPeople.last,
                    );

                    return Card(
                      margin: EdgeInsets.all(12),
                      elevation: 4,
                      color: Colors.grey[900],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📌 ${task.title}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Center(
                              child: Text(
                                '👷 ${engineer['name']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '📅 من ${_formatDate(engineer['startDate'])} إلى ${_formatDate(engineer['endDate'])}',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '📣 سبب التأخير:\n${task.inquiryReply ?? "لم يتم التوضيح"}',
                              style: TextStyle(color: Colors.red[200]),
                            ),
                            if (loggedEngineer == 'سيف') ...[
                              SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showExtendDialog(context, task);
                                },
                                icon: Icon(Icons.access_time),
                                label: Text('تمديد المهمة'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  void _showExtendDialog(BuildContext context, Task task) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('تمديد أيام المهمة'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'أدخل عدد الأيام'),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final days = int.tryParse(controller.text);
                  if (days != null && days > 0) {
                    // تعديل تاريخ المهندس الحالي
                    final engineerIndex = task.assignedPeople.indexWhere(
                      (p) => p['isDone'] == false,
                    );
                    if (engineerIndex != -1) {
                      final person = task.assignedPeople[engineerIndex];
                      final currentEndDate = _parseDate(person['endDate']);
                      if (currentEndDate != null) {
                        final newEndDate = currentEndDate.add(
                          Duration(days: days),
                        );
                        task.assignedPeople[engineerIndex]['endDate'] =
                            newEndDate.toIso8601String();

                        // إضافة سبب التأخير للملاحظات
                        final reason = task.inquiryReply ?? '';
                        task.notes += ' | تأخير: ${person['name']} - $reason';

                        // إلغاء إرسال الاستفسار
                        task.inquirySentToAdmin = false;
                        task.inquiryResponded = false;

                        // حفظ المهمة في Hive
                        final box = await Hive.openBox<Task>('tasks');
                        final index = box.values.toList().indexWhere(
                          (t) =>
                              t.title == task.title &&
                              t.startDate.toIso8601String() ==
                                  task.startDate.toIso8601String(),
                        );
                        if (index != -1) {
                          await box.putAt(index, task);
                        }

                        // إشعار للمستخدم
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✅ تم تمديد المهمة لـ ${person['name']} لمدة $days يوم\nيرجى إكمال المهمة.',
                              textDirection: ui.TextDirection.rtl,
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.of(context).pop(); // إغلاق نافذة التمديد
                        onExtendDays(task, days); // تنبيه التطبيق بحدوث التمديد
                      }
                    }
                  }
                },
                child: Text('تمديد'),
              ),
            ],
          ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'غير محدد';
    if (dateValue is DateTime) {
      return DateFormat('yyyy/MM/dd').format(dateValue);
    }
    if (dateValue is String) {
      final parsed = DateTime.tryParse(dateValue);
      if (parsed != null) {
        return DateFormat('yyyy/MM/dd').format(parsed);
      }
    }
    return 'غير معروف';
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }
}
