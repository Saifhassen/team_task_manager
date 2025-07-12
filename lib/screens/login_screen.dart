import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:team_task_manager/screens/home_screen.dart';
import 'package:team_task_manager/widgets/allpeople.dart'; // استيراد المتغيرات والوظائف

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = true;

  final Color _primaryColor = Color(0xFFFF5722);
  final Color _successColor = Color(0xFF39D98A);

  @override
  void initState() {
    super.initState();
    _loadDataAndCheckAutoLogin();
  }

  Future<void> _loadDataAndCheckAutoLogin() async {
    await initPeopleFromHive(); // تحميل المهندسين وكلمات السر من allpeople.dart
    _checkAutoLogin();
    setState(() {
      _isLoading = false;
    });
  }

  void _checkAutoLogin() async {
    final box = await Hive.openBox('login');
    final savedName = box.get('username');
    if (savedName != null && savedName is String) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(loggedEngineer: savedName, allTasks: []),
        ),
      );
    }
  }

  void _login() async {
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (engineersPasswords.containsKey(name) &&
        engineersPasswords[name] == password) {
      if (!allRegisteredPeople.contains(name)) {
        allRegisteredPeople.add(name);
        await savePeopleToHive(); // تحديث البيانات في Hive
      }

      final box = await Hive.openBox('login');
      await box.put('username', name);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(loggedEngineer: name, allTasks: []),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'اسم أو كلمة السر غير صحيحة';
      });
    }
  }

  void _loginAsGuest() async {
    final box = await Hive.openBox('login');
    await box.put('username', 'زائر');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(loggedEngineer: 'زائر', allTasks: []),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
      );
    }

    // باقي كود البناء الخاص بك كما هو تماماً من دون تغيير
    // ...
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: _successColor,
                      child: Icon(
                        Icons.engineering,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'تسجيل دخول المهندسين',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: _nameController,

                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'اسم المهندس',
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.person, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'كلمة السر',
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.lock, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _login,
                      icon: Icon(Icons.login),
                      label: Text('دخول كمهندس'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loginAsGuest,
                      icon: Icon(Icons.visibility),
                      label: Text('دخول كزائر'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white30),
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
