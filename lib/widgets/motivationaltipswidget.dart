import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class RobotTips1Widget extends StatefulWidget {
  const RobotTips1Widget({super.key});

  @override
  State<RobotTips1Widget> createState() => _RobotTipsWidgetState();
}

class _RobotTipsWidgetState extends State<RobotTips1Widget>
    with SingleTickerProviderStateMixin {
   final List<String> tips = [
    '🧠 الهندسة ليست حفظًا… بل فهم وتحليل وابتكار!',
    '🔍 كل مشكلة هندسية لها أكثر من حل… ابحث دائماً عن الأفضل.',
    '⏳ إدارة الوقت أهم من المهارة… فكلاهما يصنع الفرق.',
    '📐 التصميم الجيد يوفر نصف الجهد في التنفيذ.',
    '📊 لا تهمل التفاصيل الصغيرة… فهي ما يصنع المشروع الكبير.',
    '🚧 الفشل المرحلي جزء من النجاح الهندسي… تعلّم وواصل.',
    '💡 الإبداع يبدأ عندما تسأل: "هل يمكن تحسين هذا؟"',
    '🛠 الجودة لا تعني التعقيد… بل البساطة الذكية.',
    '🤝 تعاون مع فريقك… لا يوجد مشروع هندسي يُبنى بمجهود فردي فقط.',
    '📚 المهندس الحقيقي لا يتوقف عن التعلم والتجريب.',
    '🔧 استعمل الأدوات المناسبة… لا تبالغ ولا تستهين.',
    '🎯 ضع هدفًا واضحًا لكل مهمة… حتى لا تضيّع وقتك في التفاصيل.',
    '💬 ناقش أفكارك مع زملائك… العصف الذهني يصنع المعجزات.',
    '📎 وثّق كل شيء… اليوم تنسى، والوثائق تتذكر.',
    '🌍 المهندس يؤثر على العالم… اجعل مشاريعك تصنع فرقًا.',
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
