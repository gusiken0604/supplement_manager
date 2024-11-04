import 'package:flutter/material.dart';
import '../models/supplement.dart';

class AddSupplementScreen extends StatefulWidget {
  final Supplement? initialSupplement;

  // コンストラクタに initialSupplement パラメータを追加
  AddSupplementScreen({this.initialSupplement});

  @override
  _AddSupplementScreenState createState() => _AddSupplementScreenState();
}

class _AddSupplementScreenState extends State<AddSupplementScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String category;
  late String form;
  late int dose;
  late int dailyIntake;

  @override
  void initState() {
    super.initState();
    // initialSupplementがある場合はその値を使用し、ない場合はデフォルト値を設定
    name = widget.initialSupplement?.name ?? '';
    category = widget.initialSupplement?.category ?? '';
    form = widget.initialSupplement?.form ?? '';
    dose = widget.initialSupplement?.dose ?? 0;
    dailyIntake = widget.initialSupplement?.dailyIntake ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialSupplement == null ? 'サプリメント登録' : 'サプリメント編集'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'サプリメント名'),
                onChanged: (value) => name = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'サプリメント名を入力してください' : null,
              ),
              // 他の入力フィールドも初期値を設定
              // カテゴリー
              TextFormField(
                initialValue: category,
                decoration: InputDecoration(labelText: 'カテゴリー'),
                onChanged: (value) => category = value,
              ),
              // 形状
              DropdownButtonFormField<String>(
                value: form.isNotEmpty ? form : null,
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
              // 摂取量
              TextFormField(
                initialValue: dose.toString(),
                decoration: InputDecoration(labelText: '1回の摂取量（mg）'),
                keyboardType: TextInputType.number,
                onChanged: (value) => dose = int.tryParse(value) ?? 0,
              ),
              // 摂取回数
              TextFormField(
                initialValue: dailyIntake.toString(),
                decoration: InputDecoration(labelText: '1日の摂取回数'),
                keyboardType: TextInputType.number,
                onChanged: (value) => dailyIntake = int.tryParse(value) ?? 1,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedSupplement = Supplement(
                      name: name,
                      category: category,
                      form: form,
                      dose: dose,
                      dailyIntake: dailyIntake,
                    );
                    Navigator.pop(context, updatedSupplement);
                  }
                },
                child: Text(widget.initialSupplement == null ? '登録' : '更新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}