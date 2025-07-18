import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:team_task_manager/modes/task.dart';
import 'package:team_task_manager/screens/add_task_screen.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(Task oldTask, Task? newTask)? onUpdateTask;
  final List<String> allPeople;
  final String? loggedEngineer;

  TaskItem({
    required this.task,
    this.onUpdateTask,
    required this.allPeople,
    this.loggedEngineer,
    required void Function(Task? oldTask, Task? newTask) onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final String firstTaskRole =
        task.assignedPeople.isNotEmpty
            ? (task.assignedPeople.first['taskRole'] ?? '')
            : '';

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Card(
        color: task.color.withOpacity(0.2),
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    final updatedTask = await Navigator.push<Task?>(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => AddTaskScreen(
                              existingTask: task,
                              allPeople: allPeople,
                              loggedEngineer: loggedEngineer,
                            ),
                      ),
                    );

                    if (updatedTask == null) {
                      onUpdateTask?.call(task, null);
                    } else {
                      final isAllDone =
                          updatedTask.assignedPeople.isEmpty ||
                          updatedTask.assignedPeople.every(
                            (p) => p['hideFromPersonScreen'] == true,
                          );

                      onUpdateTask?.call(task, isAllDone ? null : updatedTask);

                      // ✅ تحديث Hive
                      final box = await Hive.openBox<Task>('tasks');
                      final index = box.values.toList().indexWhere(
                        (t) =>
                            t.title == task.title &&
                            t.startDate.toIso8601String() ==
                                task.startDate.toIso8601String(),
                      );
                      if (index != -1) {
                        if (isAllDone) {
                          await box.deleteAt(index);
                        } else {
                          await box.putAt(index, updatedTask);
                        }
                      }
                    }
                  },
                  child: CircleAvatar(backgroundColor: task.color, radius: 12),
                ),

                SizedBox(width: 10),

                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (task.description.isNotEmpty)
                        Text(
                          task.description,
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                    ],
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (task.unitType.isNotEmpty)
                        Text(
                          "الوحدة: ${task.unitType}",
                          style: TextStyle(color: Colors.white),
                        ),
                      Text(
                        "من: ${DateFormat('yyyy-MM-dd').format(task.startDate)}",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "الأشخاص المرتبطون:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                      ...task.assignedPeople.map((person) {
                        final String name = person['name'] ?? '';
                        DateTime? parseDateSafely(dynamic value) {
                          if (value == null) return null;
                          if (value is DateTime) return value;
                          if (value is String) return DateTime.tryParse(value);
                          return null;
                        }

                        final DateTime? date = parseDateSafely(
                          person['endDate'],
                        );

                        final isCompleted =
                            person['hideFromPersonScreen'] == true;
                        final isLate =
                            date != null &&
                            date.isBefore(DateTime.now()) &&
                            !isCompleted;

                        Icon? icon;
                        if (isCompleted) {
                          icon = Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          );
                        } else if (isLate) {
                          icon = Icon(
                            Icons.warning,
                            color: Colors.red,
                            size: 16,
                          );
                        }

                        return Row(
                          children: [
                            if (icon != null) ...[icon, SizedBox(width: 4)],
                            Text(
                              "- $name : ${date != null ? DateFormat('yyyy-MM-dd').format(date) : 'غير محدد'}",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),

                Container(
                  width: 32,
                  color: task.color,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Center(
                      child: Text(
                        task.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Container(
                  width: 32,
                  color: task.color,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Center(
                      child: Text(
                        firstTaskRole,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
