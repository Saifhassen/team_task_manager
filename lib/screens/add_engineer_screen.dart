import 'package:flutter/material.dart';

class AddEngineerScreen extends StatefulWidget {
  const AddEngineerScreen({super.key});

  @override
  State<AddEngineerScreen> createState() => _AddEngineerScreenState();
}

class _AddEngineerScreenState extends State<AddEngineerScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _gender = 'ذكر';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('إضافة مهندس جديد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'اسم المهندس'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'كلمة السر'),
            obscureText: true,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text('الجنس:'),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: _gender,
                items: ['ذكر', 'أنثى'].map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('إلغاء'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text('إضافة'),
          onPressed: () {
            final name = _nameController.text.trim();
            final password = _passwordController.text;
            if (name.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('يرجى إدخال كل الحقول')),
              );
              return;
            }

            Navigator.pop(context, {
              'name': name,
              'password': password,
              'gender': _gender,
            });
          },
        ),
      ],
    );
  }
}