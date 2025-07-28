// AddTaskScreen.dart
import 'package:hive/hive.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_task_manager/modes/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Function(Task)? onAddTask;
  final Task? existingTask;
  final List<String> allPeople;
  final String? loggedEngineer;

  AddTaskScreen({
    Key? key,
    this.onAddTask,
    this.existingTask,
    required this.allPeople,
    this.loggedEngineer,
  }) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final DateTime _startDate = DateTime.now();
  String? _selectedType;
  String? _selectedUnit;
  Color _selectedColor = Colors.deepOrange;
  List<Map<String, dynamic>> _assignedPeople = [];
  List<TextEditingController> _noteControllers = [];

  final List<String> taskTypes = [
    "وحدة الاجهزة الطبية",
    "المخزن",
    "جذور 1",
    "الترميم",
    "الجذور 2",
    "الاطفال",
    "الجراحة",
    "العلميات",
    "التقويم",
    "م.الصناعة",
    "اللثة",
    "الصناعة",
    "م.التقويم",
    "الجذور الخاص",
    "التقويم الخاص",
    "العمليات الخاص",
    "الاشعة",
    "الفحص",
  ];

  final List<String> unitTypes = ["اداري", "فني"];

  final List<String> personalTaskTypes = [
    "توزيع مهام",
    "صيانة",
    "طباعة كتاب",
    "تسليم مواد احتياطية",
    "ارشفة",
    "جرد",
    "متابعة",
    "لجنة",
    "سجل الصيانة",
    "كارت صيانة",
    "اخرى",
  ];

  final List<Color> _availableColors = [
    Color(0xFFE9453A),
    Color(0xFF39D98A),
    Color(0xFF349BF0),
    Color(0xFFF2F53F),
    Color(0xFFDE42FA),
    Color(0xFF42F8E6),
    Color(0xFFF539B6),
    Color(0xFF86EC26),
    Color(0xFF5348EE),
    Color(0xFFE99E57),
    Color(0xFFA044F7),
    Color(0xFF3F7FF5),
  ];

  bool get isEditor => widget.loggedEngineer == 'سيف';
  bool get isNewTask => widget.existingTask == null;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      final t = widget.existingTask!;
      _titleController.text = t.title;
      _descriptionController.text = t.description;
      _selectedType = t.type;
      _selectedUnit = t.unitType;
      _selectedColor = t.color;
      _assignedPeople =
          t.assignedPeople
              .map(
                (p) => {
                  'name': p['name'],
                  'endDate':
                      DateTime.tryParse(p['endDate'] ?? '') ?? DateTime.now(),
                  'taskRole': p['taskRole'],
                  'hideFromPersonScreen': p['hideFromPersonScreen'] ?? false,
                  'isDone': p['isDone'] ?? false,
                  'doneText': p['doneText'],
                  'days': p['days'] ?? 2,
                },
              )
              .toList();

      _noteControllers = [];
      if (t.notes.trim().isNotEmpty) {
        for (var note in t.notes.split(" | ")) {
          final ctrl = TextEditingController(text: note);
          _noteControllers.add(ctrl);
        }
      }
    }
  }

  bool isFieldEditable(String field, int index) {
    if (isEditor || isNewTask) return true;
    if (field == 'checkbox') return true;
    if (field == 'person')
      return index >= (widget.existingTask?.assignedPeople.length ?? 0);
    return false;
  }

  void _submitTask() async {
    if (_titleController.text.isEmpty ||
        _selectedUnit == null ||
        _selectedType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يرجى تعبئة كل الحقول الأساسية')));
      return;
    }

    for (int i = 0; i < _assignedPeople.length; i++) {
      _assignedPeople[i]['hideFromPersonScreen'] = i == 0 ? false : true;
    }

    final assignedList =
        _assignedPeople.map((p) {
          return {
            'name': p['name'],
            'endDate': p['endDate']?.toIso8601String(),
            'taskRole': p['taskRole'],
            'hideFromPersonScreen': p['hideFromPersonScreen'] ?? false,
            'isDone': p['isDone'] ?? false,
            'doneText': p['doneText'],
            'days': p['days'] ?? 2,
          };
        }).toList();

    final allNotes = _noteControllers
        .map((c) => c.text.trim())
        .where((n) => n.isNotEmpty)
        .join(" | ");

    final task = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType!,
      unitType: _selectedUnit!,
      startDate: _startDate,
      assignedPeople: assignedList,
      colorValue: _selectedColor.value,
      notes: allNotes,
      endDate: null,
      editorName: widget.loggedEngineer ?? 'غير معروف',
    );

    // ✅ تخزين المهمة في Hive
    final box = await Hive.openBox<Task>('tasks');
    await box.add(task);

    print('تم حفظ المهمة بنجاح');
    Navigator.pop(context, task);
  }

  InputDecoration _darkInputDecoration(String label, {bool enabled = true}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange),
        borderRadius: BorderRadius.circular(10),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 8,
      children:
          _availableColors
              .map(
                (c) => GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: CircleAvatar(
                    backgroundColor: c,
                    radius: 16,
                    child:
                        _selectedColor == c
                            ? Icon(Icons.check, color: Colors.white)
                            : null,
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildPersonField(int index) {
    final person = _assignedPeople[index];
    final bool isExistingPerson =
        widget.existingTask != null &&
        index < widget.existingTask!.assignedPeople.length;

    bool isFieldEnabled = isEditor || isNewTask || !isExistingPerson;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: person['name'],
                  dropdownColor: Colors.grey[900],
                  decoration: _darkInputDecoration('الاسم'),
                  style: TextStyle(color: Colors.white),
                  items:
                      widget.allPeople
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                p,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                  selectedItemBuilder:
                      (context) =>
                          widget.allPeople
                              .map(
                                (p) => Text(
                                  p,
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                              .toList(),
                  onChanged:
                      isFieldEnabled
                          ? (v) => setState(() => person['name'] = v)
                          : null,
                ),
              ),
              SizedBox(width: 8),
              index == 0
                  ? TextButton(
                    onPressed:
                        isFieldEnabled
                            ? () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    person['endDate'] ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => person['endDate'] = picked);
                              }
                            }
                            : null,
                    child: Text(
                      person['endDate'] == null
                          ? "اختر تاريخ"
                          : DateFormat('MM/dd').format(person['endDate']),
                      style: TextStyle(color: Colors.orangeAccent),
                    ),
                  )
                  : Container(
                    width: 65,
                    child: TextFormField(
                      initialValue: person['days'].toString(),
                      decoration: _darkInputDecoration('أيام'),
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      enabled: isFieldEnabled,
                      onChanged: (v) {
                        final days = int.tryParse(v);
                        if (days != null) {
                          setState(() {
                            person['days'] = days;
                            person['endDate'] = _startDate.add(
                              Duration(days: days),
                            );
                          });
                        }
                      },
                    ),
                  ),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: person['taskRole'],
                  dropdownColor: Colors.grey[900],
                  decoration: _darkInputDecoration('العمل'),
                  style: TextStyle(color: Colors.white),
                  items:
                      personalTaskTypes
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                  selectedItemBuilder:
                      (context) =>
                          personalTaskTypes
                              .map(
                                (r) => Text(
                                  r,
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                              .toList(),
                  onChanged:
                      isFieldEnabled
                          ? (v) => setState(() => person['taskRole'] = v)
                          : null,
                ),
              ),
              SizedBox(width: 8),
              Column(
                children: [
                  Text("✓", style: TextStyle(color: Colors.white)),
                  Checkbox(
                    value: person['isDone'] ?? false,
                    onChanged: (v) {
                      setState(() {
                        person['isDone'] = v ?? false;

                        if (v == true) {
                          person['doneText'] =
                              'تم الإنجاز بواسطة: ${person['name']} في ${DateFormat('MM/dd').format(DateTime.now())}';
                          person['hideFromPersonScreen'] = true;

                          // إظهار المهمة للمهندس التالي فقط
                          for (int i = 0; i < _assignedPeople.length; i++) {
                            if ((_assignedPeople[i]['isDone'] ?? false) ==
                                false) {
                              _assignedPeople[i]['hideFromPersonScreen'] =
                                  false;
                              break;
                            }
                          }

                          // إرجاع المهمة المحدثة
                          final updatedTask = Task(
                            title: _titleController.text,
                            description: _descriptionController.text,
                            type: _selectedType!,
                            unitType: _selectedUnit!,
                            startDate: _startDate,
                            assignedPeople:
                                _assignedPeople
                                    .map(
                                      (p) => {
                                        'name': p['name'],
                                        'endDate':
                                            p['endDate']?.toIso8601String(),
                                        'taskRole': p['taskRole'],
                                        'hideFromPersonScreen':
                                            p['hideFromPersonScreen'] ?? false,
                                        'isDone': p['isDone'] ?? false,
                                        'doneText': p['doneText'],
                                      },
                                    )
                                    .toList(),
                            colorValue: _selectedColor.value,
                            notes: _noteControllers
                                .map((c) => c.text.trim())
                                .where((n) => n.isNotEmpty)
                                .join(" | "),
                            endDate: null,
                            editorName: widget.loggedEngineer ?? 'غير معروف',
                          );
                          Navigator.pop(context, updatedTask);
                        }
                      });
                    },
                  ),
                ],
              ),
              if (isFieldEnabled)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed:
                      () => setState(() => _assignedPeople.removeAt(index)),
                ),
            ],
          ),
          if (person['doneText'] != null)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                person['doneText'],
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
        ],
      ),
    );
  }

  void _addNote() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text("إضافة ملاحظة", style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: controller,
              style: TextStyle(color: Colors.white),
              decoration: _darkInputDecoration("أدخل ملاحظة"),
            ),
            actions: [
              TextButton(
                child: Text("إلغاء", style: TextStyle(color: Colors.redAccent)),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  "إضافة",
                  style: TextStyle(color: Colors.greenAccent),
                ),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() => _noteControllers.add(controller));
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void _showAddTaskTypeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              "إضافة نوع مهمة",
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: controller,
              style: TextStyle(color: Colors.white),
              decoration: _darkInputDecoration("أدخل الوحدة الجديدة"),
            ),
            actions: [
              TextButton(
                child: Text("إلغاء", style: TextStyle(color: Colors.redAccent)),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  "إضافة",
                  style: TextStyle(color: Colors.greenAccent),
                ),
                onPressed: () {
                  final newType = controller.text.trim();
                  if (newType.isNotEmpty && !taskTypes.contains(newType)) {
                    setState(() {
                      taskTypes.add(newType);
                      _selectedType = newType;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text('إضافة مهمة'),
          actions: [
            IconButton(icon: Icon(Icons.check), onPressed: _submitTask),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              if (widget.loggedEngineer != null)
                Text(
                  'المحرر: ${widget.loggedEngineer}',
                  style: TextStyle(color: Colors.white70),
                ),
              SizedBox(height: 8),
              TextField(
                controller: _titleController,
                enabled: isEditor || isNewTask,
                style: TextStyle(color: Colors.white),
                decoration: _darkInputDecoration('اسم المهمة'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                enabled: isEditor || isNewTask,
                style: TextStyle(color: Colors.white),
                decoration: _darkInputDecoration('الوصف'),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                dropdownColor: Colors.grey[900],
                decoration: _darkInputDecoration('نوع المهمة'),
                style: TextStyle(color: Colors.white),
                items:
                    unitTypes
                        .map(
                          (u) => DropdownMenuItem(
                            value: u,
                            child: Text(
                              u,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                selectedItemBuilder:
                    (context) =>
                        unitTypes
                            .map(
                              (u) => Text(
                                u,
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                            .toList(),
                onChanged:
                    (isEditor || isNewTask)
                        ? (v) => setState(() => _selectedUnit = v)
                        : null,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      dropdownColor: Colors.grey[900],
                      decoration: _darkInputDecoration('الوحدة'),
                      style: TextStyle(color: Colors.white),
                      items:
                          taskTypes
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                    t,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                      selectedItemBuilder:
                          (context) =>
                              taskTypes
                                  .map(
                                    (t) => Text(
                                      t,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                  .toList(),
                      onChanged:
                          (isEditor || isNewTask)
                              ? (v) => setState(() => _selectedType = v)
                              : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  if (isEditor || isNewTask)
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.greenAccent),
                      onPressed: _showAddTaskTypeDialog,
                    ),
                ],
              ),
              Divider(color: Colors.orangeAccent.withOpacity(0.5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "الملاحظات",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.greenAccent),
                    onPressed: _addNote,
                  ),
                ],
              ),
              ..._noteControllers.map(
                (c) => Container(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    c.text.trim(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 8),
              _buildColorSelector(),
              Divider(color: Colors.orangeAccent.withOpacity(0.5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "المهندسون",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _assignedPeople.add({
                          'name': null,
                          'endDate': DateTime.now(),
                          'taskRole': null,
                          'hideFromPersonScreen': false,
                          'isDone': false,
                          'days': 2,
                        });
                      });
                    },
                    icon: Icon(Icons.person_add),
                    label: Text('إضافة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 146, 233, 47),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ..._assignedPeople
                  .asMap()
                  .entries
                  .map((e) => _buildPersonField(e.key))
                  .toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitTask,
                child: Text('حفظ المهمة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
