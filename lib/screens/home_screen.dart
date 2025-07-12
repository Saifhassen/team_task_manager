import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:team_task_manager/modes/task.dart';
import 'package:team_task_manager/screens/add_task_screen.dart';
import 'package:team_task_manager/screens/inquiry_screen.dart';
import 'package:team_task_manager/screens/login_screen.dart';
import 'package:team_task_manager/screens/manageEngineersPage.dart';
import 'package:team_task_manager/screens/person_task_screen.dart';
import 'package:team_task_manager/widgets/WelcomeBanner.dart';
import 'package:team_task_manager/widgets/allpeople.dart';
import 'package:team_task_manager/widgets/robotTipsWidget.dart';
import 'package:team_task_manager/widgets/task_item.dart';
import 'package:team_task_manager/screens/add_engineer_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? loggedEngineer;
  final List<Task> allTasks;

  HomeScreen({Key? key, this.loggedEngineer, required this.allTasks})
    : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    _loadTasksFromHive();
  }

  void _loadTasksFromHive() async {
    final box = await Hive.openBox<Task>('tasks');
    final storedTasks = box.values.toList();

    setState(() {
      _tasks = storedTasks;
    });
  }

  void _editTask(Task? oldTask, Task? newTask) {
    setState(() {
      if (oldTask == null && newTask != null) {
        _addOrReplaceTask(newTask);
      } else if (oldTask != null && newTask == null) {
        _tasks.removeWhere(
          (t) =>
              t.title == oldTask.title &&
              t.startDate.toIso8601String() ==
                  oldTask.startDate.toIso8601String(),
        );
      } else if (oldTask != null && newTask != null) {
        final allDone = newTask.assignedPeople.every(
          (p) => p['hideFromPersonScreen'] == true,
        );
        _tasks.removeWhere(
          (t) =>
              t.title == oldTask.title &&
              t.startDate.toIso8601String() ==
                  oldTask.startDate.toIso8601String(),
        );
        if (!allDone) {
          _addOrReplaceTask(newTask);
        }
      }
    });
  }

  void _addOrReplaceTask(Task newTask) {
    final index = _tasks.indexWhere(
      (t) =>
          t.title == newTask.title &&
          t.startDate.toIso8601String() == newTask.startDate.toIso8601String(),
    );
    if (index != -1) {
      _tasks[index] = newTask;
    } else {
      _tasks.add(newTask);
    }
  }

  void _openPersonTasks(String personName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PersonTaskScreen(
              personName: personName,
              allTasks: _tasks,
              allPeople: allRegisteredPeople,
              onUpdateTask: _editTask,
              loggedEngineer: widget.loggedEngineer,
            ),
      ),
    );
    if (result is List<Task>) {
      setState(() {
        _tasks = result;
      });
    }
  }

  void _openAddTaskScreen() async {
    final newTask = await Navigator.push<Task?>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddTaskScreen(
              allPeople: allRegisteredPeople,
              loggedEngineer: widget.loggedEngineer,
            ),
      ),
    );
    if (newTask != null) {
      setState(() {
        _addOrReplaceTask(newTask);
      });
    }
  }

  Widget _buildPeopleTaskSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Color(0xFF1E1E1E),
      height: 140,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                allRegisteredPeople.map((person) {
                  final personTasks =
                      _tasks.where((task) {
                        return task.assignedPeople.any(
                          (p) =>
                              p['name'] == person &&
                              p['hideFromPersonScreen'] != true,
                        );
                      }).toList();

                  final taskCount = personTasks.length;
                  Color color;
                  if (taskCount == 0) {
                    color = Colors.grey;
                  } else if (taskCount <= 2) {
                    color = Color(0xFF39D98A);
                  } else if (taskCount <= 5) {
                    color = Colors.orangeAccent;
                  } else {
                    color = Colors.redAccent;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (widget.loggedEngineer == 'سيف' ||
                          widget.loggedEngineer == person) {
                        _openPersonTasks(person);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('غير مصرح لك بعرض صفحة هذا المهندس'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: color,
                            child: Text(
                              '$taskCount',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            person,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks =
        _tasks.where((task) {
          final title = task.title.toLowerCase();
          final desc = task.description.toLowerCase();
          final unit = task.unitType.toLowerCase();
          final people = task.assignedPeople
              .map((p) => p['name']?.toLowerCase() ?? '')
              .join(', ');
          return title.contains(_searchQuery) ||
              desc.contains(_searchQuery) ||
              unit.contains(_searchQuery) ||
              people.contains(_searchQuery);
        }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFF121212),
        appBar: AppBar(
          title: Text('كل المهام'),
          backgroundColor: Color(0xFFFF5722),
        ),
        drawer: Drawer(
          backgroundColor: Color(0xFF1E1E1E),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFFFF5722)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحبًا ${widget.loggedEngineer ?? ''}',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'إدارة المهام',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title: Text('صفحتي', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _openPersonTasks(widget.loggedEngineer!);
                },
              ),

              // ✅ تظهر فقط لسيف
              if (widget.loggedEngineer == 'سيف') ...[
                ListTile(
                  leading: Icon(Icons.engineering, color: Colors.white70),
                  title: Text(
                    'إدارة المهندسين',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ManageEngineersPage()),
                    ).then((_) async {
                      await initPeopleFromHive();
                      setState(() {});
                    });
                  },
                ),
              ],

              // باقي عناصر القائمة...
              if (widget.loggedEngineer == 'سيف')
                ListTile(
                  leading: Icon(Icons.question_answer, color: Colors.orange),
                  title: Text(
                    'الاستفسارات',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => InquiryScreen(
                              allTasks: _tasks,
                              loggedEngineer: widget.loggedEngineer!,
                              onExtendDays: (task, days) {
                                final person = task.assignedPeople.firstWhere(
                                  (p) => p['isDone'] == false,
                                  orElse: () => task.assignedPeople.last,
                                );

                                person['endDate'] = person['endDate'].add(
                                  Duration(days: days),
                                );

                                task.notes =
                                    (task.notes.isNotEmpty ? task.notes : '') +
                                    '\nتم التمديد بـ $days يوم بسبب: ${task.inquiryReply ?? ""}';

                                task.inquirySentToAdmin = false;

                                // إذا كنت تحفظ إلى قاعدة بيانات، أضف حفظ هنا
                              },
                            ),
                      ),
                    );
                  },
                ),

              ListTile(
                leading: Icon(Icons.logout, color: Colors.white70),
                title: Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  // افتح الصندوق مرة واحدة فقط
                  final box = await Hive.openBox('login');

                  // تأكد أنه تم المسح فعلاً
                  await box.clear();

                  // بعد التأكد من مسح البيانات، انتقل إلى LoginScreen
                  Future.delayed(Duration(milliseconds: 300), () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                    );
                  });
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddTaskScreen,
          backgroundColor: Color(0xFFFF5722),
          child: Icon(Icons.add),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _buildPeopleTaskSummary(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن مهمة أو وصف أو وحدة أو مهندس...',
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Color(0xFF2C2C2C),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                    ),
                  ),
                ),
                Expanded(
                  child:
                      filteredTasks.isEmpty
                          ? Center(
                            child: Text(
                              'لا توجد مهام بعد',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                          : ListView.builder(
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return TaskItem(
                                task: task,
                                allPeople: allRegisteredPeople,
                                loggedEngineer: widget.loggedEngineer,
                                onUpdate: _editTask,
                              );
                            },
                          ),
                ),
              ],
            ),

            Positioned(bottom: 0, left: 0, right: 0, child: WelcomeBanner()),
          ],
        ),
      ),
    );
  }
}
