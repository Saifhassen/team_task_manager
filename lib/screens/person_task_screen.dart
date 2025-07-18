import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:team_task_manager/modes/task.dart';
import 'package:team_task_manager/screens/add_task_screen.dart';
import 'package:team_task_manager/screens/inquiry_screen.dart';
import 'package:team_task_manager/screens/later_task_screen.dart';
import 'package:team_task_manager/screens/home_screen.dart';
import 'package:team_task_manager/widgets/WelcomeBanner.dart';
import 'package:team_task_manager/widgets/motivationaltipswidget.dart';
import 'package:team_task_manager/widgets/robotTipsWidget.dart';

class PersonTaskScreen extends StatefulWidget {
  final List<String> allPeople;
  final String personName;
  final String? loggedEngineer;
  final List<Task> allTasks;
  final Function(Task? oldTask, Task? newTask)? onUpdateTask;

  const PersonTaskScreen({
    Key? key,
    required this.personName,
    required this.allTasks,
    required this.allPeople,
    this.onUpdateTask,
    required this.loggedEngineer,
  }) : super(key: key);

  @override
  State<PersonTaskScreen> createState() => _PersonTaskScreenState();
}

class _PersonTaskScreenState extends State<PersonTaskScreen> {
  late List<Task> personTasks;
  final TextEditingController _replyController = TextEditingController();
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    _filterTasks();
    Future.delayed(Duration.zero, _checkAndShowInquiryDialogs);
  }

  void _filterTasks() {
    personTasks =
        widget.allTasks.where((task) {
          return task.assignedPeople.any(
            (person) =>
                person['name'] == widget.personName &&
                person['hideFromPersonScreen'] != true,
          );
        }).toList();
  }

  void _checkAndShowInquiryDialogs() {
    for (var task in personTasks) {
      final person = task.assignedPeople.firstWhere(
        (p) => p['name'] == widget.personName,
        orElse: () => {},
      );
      if (person.isEmpty) continue;

      final rawEndDate = person['endDate'];
      final endDate =
          rawEndDate is DateTime
              ? rawEndDate
              : (rawEndDate is String ? DateTime.tryParse(rawEndDate) : null);

      final isLate =
          endDate != null &&
          DateTime.now().isAfter(endDate) &&
          person['isDone'] != true;

      if (isLate && task.inquiryResponded != true) {
        isBlocked = true;
        _showInquiryDialog(task);
        break;
      } else if (isLate &&
          task.inquiryResponded == true &&
          task.inquirySentToAdmin == true) {
        isBlocked = true;
      }
    }
  }

  void _showInquiryDialog(Task task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Text('استفسار عن تأخير المهمة'),
            content: TextField(
              controller: _replyController,
              maxLines: 3,
              decoration: InputDecoration(hintText: 'اكتب سبب التأخير هنا...'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (_replyController.text.isNotEmpty) {
                    setState(() {
                      task.inquiryReply = _replyController.text;
                      task.inquiryResponded = true;
                      task.inquirySentToAdmin = true;
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('إرسال'),
              ),
            ],
          ),
    );
  }

  void _openEditTask(Task task) async {
    if (isBlocked) return;

    final updatedTask = await Navigator.push<Task?>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddTaskScreen(
              existingTask: task,
              allPeople: widget.allPeople,
              loggedEngineer: widget.loggedEngineer,
            ),
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
      _filterTasks();
      _checkAndShowInquiryDialogs(); // ✅ تأكد من وجوده
    });
  }

  void _openAddTask() async {
    if (isBlocked) return;

    final newTask = await Navigator.push<Task?>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddTaskScreen(
              allPeople: widget.allPeople,
              loggedEngineer: widget.loggedEngineer,
            ),
      ),
    );

    if (newTask != null) {
      widget.onUpdateTask?.call(null, newTask);
      setState(() {
        _filterTasks();
        _checkAndShowInquiryDialogs(); // ✅ أضف هذا السطر هنا
      });
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder:
            (_) => HomeScreen(
              loggedEngineer: widget.loggedEngineer,
              allTasks: widget.allTasks,
            ),
      ),
      (route) => false,
    );
  }

  Widget _buildSummaryCard() {
    int total = personTasks.length;
    int completed = 0;
    int late = 0;

    for (var task in personTasks) {
      final person = task.assignedPeople.firstWhere(
        (p) => p['name'] == widget.personName,
        orElse: () => {},
      );

      final isCompleted = person['hideFromPersonScreen'] == true;
      final rawEndDate = person['endDate'];
      final DateTime? endDate =
          rawEndDate is DateTime
              ? rawEndDate
              : (rawEndDate is String ? DateTime.tryParse(rawEndDate) : null);
      final isLate =
          endDate != null && endDate.isBefore(DateTime.now()) && !isCompleted;

      if (isCompleted) completed++;
      if (isLate) late++;
    }

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 4,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatusItem("الكل", total, Colors.white),
            _buildStatusItem("منجز", completed, Color(0xFF39D98A)),
            _buildStatusItem("متأخر", late, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, Color color) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text('مهام ${widget.personName}'),
        centerTitle: true,
        backgroundColor: Color(0xFFFF5722),
      ),
      endDrawer: Drawer(
        backgroundColor: Color(0xFF1C1C1C),
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFFF5722)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحبًا ${widget.personName}',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text('صفحة المهندس', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text(
                'الصفحة الرئيسية',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context, widget.allTasks);
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: Colors.white),

              title: Text(
                'المهام المتأخرة',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => LateTasksScreen(
                          allTasks: widget.allTasks,
                          allPeople: widget.allPeople,
                          onUpdateTask: widget.onUpdateTask,
                        ),
                  ),
                );
              },
            ),
            if (widget.loggedEngineer == 'سيف')
              ListTile(
                leading: Icon(Icons.question_answer, color: Colors.orange),
                title: Text(
                  'الاستفسارات',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => InquiryScreen(
                            allTasks: widget.allTasks,
                            loggedEngineer: widget.loggedEngineer ?? '',
                            onExtendDays: (task, days) {
                              final person = task.assignedPeople.firstWhere(
                                (p) => p['isDone'] == false,
                                orElse: () => task.assignedPeople.last,
                              );
                              person['endDate'] = person['endDate'].add(
                                Duration(days: days),
                              );
                              task.notes +=
                                  '\nتم التمديد بـ $days يوم بسبب: ${task.inquiryReply ?? ""}';
                              task.inquirySentToAdmin = false;
                              setState(() {});
                            },
                          ),
                    ),
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.white),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
      floatingActionButton:
          isBlocked
              ? null
              : FloatingActionButton(
                backgroundColor: Color(0xFF39D98A),
                onPressed: _openAddTask,
                child: Icon(Icons.add),
                tooltip: "إضافة مهمة",
              ),
      body: Column(
        children: [
          if (isBlocked)
            Container(
              width: double.infinity,
              color: Colors.red[900],
              padding: EdgeInsets.all(12),
              child: Text(
                '❗ لا يمكنك متابعة العمل حتى يتم الرد من الإدارة على سبب التأخير',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          _buildSummaryCard(),
          Expanded(
            child:
                personTasks.isEmpty
                    ? Center(
                      child: Text(
                        'لا توجد مهام مخصصة لـ ${widget.personName}',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                    : ListView.builder(
                      itemCount: personTasks.length,
                      itemBuilder: (context, index) {
                        final task = personTasks[index];
                        final person = task.assignedPeople.firstWhere(
                          (p) => p['name'] == widget.personName,
                          orElse: () => {},
                        );
                        final rawEndDate = person['endDate'];
                        final DateTime? endDate =
                            rawEndDate is DateTime
                                ? rawEndDate
                                : (rawEndDate is String
                                    ? DateTime.tryParse(rawEndDate)
                                    : null);
                        final isCompleted =
                            person['hideFromPersonScreen'] == true;
                        final isLate =
                            endDate != null &&
                            endDate.isBefore(DateTime.now()) &&
                            !isCompleted;
                        final taskRole = person['taskRole'] ?? '';
                        return Card(
                          color: task.color.withOpacity(0.2),
                          margin: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 10,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap:
                                        isBlocked
                                            ? null
                                            : () => _openEditTask(task),
                                    child: CircleAvatar(
                                      backgroundColor: task.color,
                                      radius: 20,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (task.unitType.isNotEmpty)
                                          Text(
                                            "الوحدة: ${task.unitType}",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        Text(
                                          "من: ${DateFormat('yyyy-MM-dd').format(task.startDate)}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        if (endDate != null)
                                          Text(
                                            "إلى: ${DateFormat('yyyy-MM-dd').format(endDate)}",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),

                                        Text(
                                          "نوع العمل: $taskRole",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        if (isLate)
                                          Text(
                                            "⚠️ متأخر",
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        if (isCompleted)
                                          Text(
                                            "✅ منجز",
                                            style: TextStyle(
                                              color: Color(0xFF39D98A),
                                            ),
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

          Positioned(bottom: 0, left: 0, right: 0, child: RobotTips1Widget()),
        ],
      ),
    );
  }
}
