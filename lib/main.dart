import 'package:flutter/material.dart';
import 'screens/add_supplement.dart'; // インポート文を追加

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supplement Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class AddSupplementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('サプリメント登録'),
      ),
      body: Center(
        child: Text('サプリメント登録画面'),
      ),
    );
  }
  }

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('サプリメント管理アプリ'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final newSupplement = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddSupplementScreen()),
            );
            // 新しいサプリメント情報をリストに追加する処理を実装
          },
          child: Text('サプリメントを登録する'),
        ),
      ),
    );
  }
}