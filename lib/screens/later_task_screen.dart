import 'dart:ui' as ui;
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_task_manager/modes/task.dart';
import 'package:team_task_manager/screens/add_task_screen.dart';

class LateTasksScreen extends StatefulWidget {
  final List<Task> allTasks;
  final List<String> allPeople;
  final Function(Task? oldTask, Task? newTask)? onUpdateTask;

  const LateTasksScreen({
    Key? key,
    required this.allTasks,
    required this.allPeople,
    this.onUpdateTask,
  }) : super(key: key);

  @override
  State<LateTasksScreen> createState() => _LateTasksScreenState();
}

class _LateTasksScreenState extends State<LateTasksScreen> {
  late List<Task> lateTasks;

  @override
  void initState() {
    super.initState();
    _filterLateTasks();
  }

  void _filterLateTasks() {
    final now = DateTime.now();
    lateTasks =
        widget.allTasks.where((task) {
          return task.assignedPeople.any((person) {
            final DateTime? endDate = _parseDate(person['endDate']);
            final bool isHidden = person['hideFromPersonScreen'] == true;
            return endDate != null && endDate.isBefore(now) && !isHidden;
          });
        }).toList();
  }

  DateTime? _parseDate(dynamic date) {
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  void _openEditTask(Task task) async {
    final updatedTask = await Navigator.push<Task?>(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                AddTaskScreen(existingTask: task, allPeople: widget.allPeople),
      ),
    );

    if (updatedTask == null) {
      widget.onUpdateTask?.call(task, null);
    } else {
      final allCompleted = updatedTask.assignedPeople.every(
        (p) => p['hideFromPersonScreen'] == true,
      );
      widget.onUpdateTask?.call(task, allCompleted ? null : updatedTask);

      // 🟡 حفظ في Hive
      final box = await Hive.openBox<Task>('tasks');
      final index = box.values.toList().indexWhere(
        (t) =>
            t.title == updatedTask.title &&
            t.startDate.toIso8601String() ==
                updatedTask.startDate.toIso8601String(),
      );
      if (index != -1) {
        await box.putAt(index, updatedTask);
      } else {
        await box.add(updatedTask);
      }
    }

    setState(() {
      _filterLateTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFF121212),
        appBar: AppBar(
          title: Text("المهام المتأخرة"),
          backgroundColor: Colors.red.shade700,
        ),
        body:
            lateTasks.isEmpty
                ? Center(
                  child: Text(
                    "لا توجد مهام متأخرة",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                : ListView.builder(
                  itemCount: lateTasks.length,
                  itemBuilder: (context, index) {
                    final task = lateTasks[index];

                    final latePeople =
                        task.assignedPeople.where((person) {
                          final DateTime? endDate = _parseDate(
                            person['endDate'],
                          );
                          final bool isHidden =
                              person['hideFromPersonScreen'] == true;
                          return endDate != null &&
                              endDate.isBefore(DateTime.now()) &&
                              !isHidden;
                        }).toList();

                    final firstPerson =
                        latePeople.isNotEmpty
                            ? latePeople.first
                            : (task.assignedPeople.isNotEmpty
                                ? task.assignedPeople.first
                                : {});

                    final taskRole = firstPerson['taskRole'] ?? '';
                    final rawEndDate = firstPerson['endDate'];
                    final DateTime? endDate = _parseDate(rawEndDate);

                    return Card(
                      color: task.color.withOpacity(0.2),
                      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => _openEditTask(task),
                                child: CircleAvatar(
                                  backgroundColor: task.color,
                                  radius: 20,
                                ),
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
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
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
                                    if (endDate != null)
                                      Text(
                                        "إلى: ${DateFormat('yyyy-MM-dd').format(endDate)}",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    Text(
                                      "نوع العمل: $taskRole",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      "⚠️ متأخر",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
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
                                      style: TextStyle(
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
                                      taskRole,
                                      style: TextStyle(
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
                    );
                  },
                ),
      ),
    );
  }
}
