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
    allRegisteredPeople = ['محمد', 'سارة', 'فاطمة', 'سيف'];
    engineersPasswords = {
      'محمد': '1234',
      'سارة': '5678',
      'فاطمة': '1111',
      'سيف': '0000',
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