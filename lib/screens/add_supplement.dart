import 'package:flutter/material.dart';
import '../models/supplement.dart';

class AddSupplementScreen extends StatefulWidget {
  @override
  _AddSupplementScreenState createState() => _AddSupplementScreenState();
}

class _AddSupplementScreenState extends State<AddSupplementScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String category = '';
  String form = '';
  int dose = 0;
  int dailyIntake = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('サプリメント登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'サプリメント名'),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'サプリメント名を入力してください';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'カテゴリー'),
                onChanged: (value) {
                  setState(() {
                    category = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '形状'),
                items: ['錠剤', 'カプセル', '粉末']
                    .map((form) => DropdownMenuItem(
                          value: form,
                          child: Text(form),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    form = value ?? '';
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '1回の摂取量（mg）'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    dose = int.tryParse(value) ?? 0;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '1日の摂取回数'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    dailyIntake = int.tryParse(value) ?? 1;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newSupplement = Supplement(
                      name: name,
                      category: category,
                      form: form,
                      dose: dose,
                      dailyIntake: dailyIntake,
                    );
                    // 登録したデータを保存する処理を追加
                    Navigator.pop(context, newSupplement);
                  }
                },
                child: Text('登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}