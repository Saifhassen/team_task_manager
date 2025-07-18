import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:team_task_manager/modes/task.dart';
import 'package:team_task_manager/screens/login_screen.dart';
import 'firebase_options.dart'; // أضف هذا

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  // ✅ تهيئة Firebase مع الخيارات
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ تهيئة Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'NontArabic'),


      home: LoginScreen(),
      // home: Scaffold(
      //  body: Center(
      //  child: Lottie.asset(
      //   'assets/animations/robot_walk_message.json',
      //  width: 200,
      //  height: 200,
      //   fit: BoxFit.contain,
      // repeat: true,
      //       ),
      //   ),
      // ),
    );
  }
}
