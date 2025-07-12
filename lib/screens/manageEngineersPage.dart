import 'package:flutter/material.dart';
import 'package:team_task_manager/widgets/allpeople.dart';

class ManageEngineersPage extends StatefulWidget {
  @override
  _ManageEngineersPageState createState() => _ManageEngineersPageState();
}

class _ManageEngineersPageState extends State<ManageEngineersPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? selectedEngineer;

  @override
  void initState() {
    super.initState();
    selectedEngineer = _getFirstSelectableEngineer();
  }

  String? _getFirstSelectableEngineer() {
    final filtered = allRegisteredPeople.where((e) => e != 'سيف').toList();
    return filtered.isNotEmpty ? filtered.first : null;
  }

  void _refreshList() {
    setState(() {
      selectedEngineer = _getFirstSelectableEngineer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        allRegisteredPeople.where((name) => name != 'سيف').toList();

    return Scaffold(
      appBar: AppBar(title: Text('إدارة المهندسين')),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'اسم المهندس الجديد',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black26,
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'كلمة السر',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black26,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF5722),
                ),
                onPressed: () async {
                  final name = nameController.text.trim();
                  final pass = passwordController.text.trim();
                  if (name.isEmpty || pass.isEmpty) return;

                  if (engineersPasswords.containsKey(name)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('المهندس موجود مسبقاً')),
                    );
                  } else {
                    engineersPasswords[name] = pass;
                    allRegisteredPeople.add(name);
                    await savePeopleToHive();
                    _refreshList();
                    nameController.clear();
                    passwordController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تمت إضافة المهندس $name')),
                    );
                  }
                },
                child: Text('إضافة المهندس'),
              ),
              Divider(color: Colors.white24),
              if (filtered.isNotEmpty)
                Column(
                  children: [
                    Text('حذف مهندس:', style: TextStyle(color: Colors.white70)),
                    DropdownButton<String>(
                      dropdownColor: Colors.grey[850],
                      value: selectedEngineer,
                      items:
                          filtered.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() => selectedEngineer = val);
                      },
                    ),

                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        if (selectedEngineer == null) return;

                        engineersPasswords.remove(selectedEngineer);
                        allRegisteredPeople.remove(selectedEngineer);
                        await savePeopleToHive();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم حذف المهندس $selectedEngineer'),
                          ),
                        );
                        _refreshList();
                      },
                      child: Text(
                        'حذف المهندس',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
