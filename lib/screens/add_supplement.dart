import 'package:flutter/material.dart';
import '../models/supplement.dart';



class AddSupplementScreen extends StatefulWidget {
  //final Supplement? initialSupplement;
  final Supplement? supplement; // 追加: 既存のサプリメント情報を受け取る

  const AddSupplementScreen({Key? key, this.supplement}) : super(key: key);


  // コンストラクタに initialSupplement パラメータを追加
  //AddSupplementScreen({this.initialSupplement});

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
  late int remaining; // 残薬数のフィールド

  @override
  // void initState() {
  //   super.initState();
  //   // initialSupplementがある場合はその値を使用し、ない場合はデフォルト値を設定
    
  //   name = widget.initialSupplement?.name ?? '';
  //   category = widget.initialSupplement?.category ?? '';
  //   form = widget.initialSupplement?.form ?? '';
  //   dose = widget.initialSupplement?.dose ?? 0; // デフォルト値0を設定
  //   dailyIntake = widget.initialSupplement?.dailyIntake ?? 1; // デフォルト値1を設定
  //   remaining = widget.initialSupplement?.remaining ?? 0; // デフォルト値0を設定
  // }
    void initState() {
    super.initState();
    // `widget.supplement` からデータを取得し、編集可能な状態にする
    name = widget.supplement?.name ?? '';
    category = widget.supplement?.category ?? '';
    form = widget.supplement?.form ?? '';
    dose = widget.supplement?.dose ?? 0;
    dailyIntake = widget.supplement?.dailyIntake ?? 1;
    remaining = widget.supplement?.remaining ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text(widget.initialSupplement == null ? 'サプリメント登録' : 'サプリメント編集'),
        title: Text(widget.supplement == null ? 'サプリメント登録' : 'サプリメント編集'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'サプリメント名',
                floatingLabelBehavior: FloatingLabelBehavior.always, // ラベルを最初から上に表示
                   border: OutlineInputBorder(), 
                    ),
                
                onChanged: (value) => name = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'サプリメント名を入力してください' : null,
              ),

              TextFormField(
                initialValue: remaining.toString(),
                decoration: InputDecoration(labelText: '残薬数'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  remaining = int.tryParse(value) ?? 0; // nullの場合に0を設定
                },
              ),
              TextFormField(
                initialValue: dailyIntake.toString(),
                decoration: InputDecoration(labelText: '1日の摂取回数'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  dailyIntake = int.tryParse(value) ?? 1; // nullの場合に1を設定
                },
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
                      remaining: remaining, // remainingを追加
                    );
                    Navigator.pop(context, updatedSupplement);
                  }
                },
                //child: Text(widget.initialSupplement == null ? '登録' : '更新'),
                child: Text(widget.supplement == null ? '登録' : '更新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
