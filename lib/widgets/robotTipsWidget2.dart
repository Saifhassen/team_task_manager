import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class RobotTipsWidget2 extends StatefulWidget {
  const RobotTipsWidget2({super.key});

  @override
  State<RobotTipsWidget2> createState() => _RobotTipsWidget2State();
}

class _RobotTipsWidget2State extends State<RobotTipsWidget2>
    with SingleTickerProviderStateMixin {
  final List<String> tips = [
    '👋 مهندس سيف السلامي يرحب بكم في نظام إدارة المهندسين',
    '📌 هذا النظام مخصص لتنظيم المهام وتسهيل متابعة الإنجازات',
    '🛠 إذا لم تكن من الكادر الهندسي، يمكنك الدخول كـ "زائر" للاطلاع فقط',
    '📞 إذا كنت مهندسًا في وحدة الأجهزة الطبية، يُرجى التواصل مع مسؤول الوحدة لتفعيل حسابك',
  ];

  String currentTip = '';
  Timer? _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    currentTip = _getRandomTip();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _fadeController.reverse();
      setState(() {
        currentTip = _getRandomTip();
      });
      await _fadeController.forward();
    });
  }

  String _getRandomTip() {
    final random = Random();
    String nextTip;
    do {
      nextTip = tips[random.nextInt(tips.length)];
    } while (nextTip == currentTip && tips.length > 1);
    return nextTip;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          currentTip,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: Colors.black45,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
