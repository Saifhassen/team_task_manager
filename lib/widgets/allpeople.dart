import 'package:hive/hive.dart';

// قائمة المهندسين المسجلين وأسماءهم
List<String> allRegisteredPeople = [];

// خريطة كلمات السر لكل مهندس (الاسم -> كلمة السر)
Map<String, String> engineersPasswords = {};

// تهيئة البيانات من Hive أو إدخال بيانات أولية عند التشغيل لأول مرة
Future<void> initPeopleFromHive() async {
  final box = await Hive.openBox('peopleBox');

  if (box.isEmpty) {
    // بيانات أولية افتراضية
    allRegisteredPeople = [
      'سيف',
      'منتظر',
      'فاضل',
      'غفران',
      'الاء',
      'نور',
      'محمد',
      'فاطمة',
    ];
    engineersPasswords = {
      'سيف': '1991',
      'منتظر': '1991',
      'فاضل': '1968',
      'غفران': '1992',
      'الاء': '1997',
      'نور': '2000',
      'محمد': '2001',
      'فاطمة': '2001',
    };

    // تخزين البيانات في Hive
    await box.put('registered', allRegisteredPeople);
    await box.put('passwords', engineersPasswords);
  } else {
    // تحميل البيانات من Hive عند إعادة تشغيل التطبيق
    allRegisteredPeople = List<String>.from(
      box.get('registered', defaultValue: []),
    );
    engineersPasswords = Map<String, String>.from(
      box.get('passwords', defaultValue: {}),
    );
  }
}

// لحفظ البيانات (مثل الإضافة أو الحذف) إلى Hive لاحقاً
Future<void> savePeopleToHive() async {
  final box = await Hive.openBox('peopleBox');
  await box.put('registered', allRegisteredPeople);
  await box.put('passwords', engineersPasswords);
}
