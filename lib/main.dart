import 'package:flutter/material.dart';
import 'screens/add_supplement.dart';
import 'models/supplement.dart';

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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // サプリメント情報を保持するリスト
  List<Supplement> supplements = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('サプリメント管理アプリ'),
      ),
      body: supplements.isEmpty
          ? Center(
              child: Text('サプリメントが登録されていません'),
            )
          : ListView.builder(
              itemCount: supplements.length,
              itemBuilder: (context, index) {
                final supplement = supplements[index];
                return ListTile(
                  title: Text(supplement.name),
                  subtitle: Text(
                      'カテゴリー: ${supplement.category}, 形状: ${supplement.form}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // サプリメント登録画面へ遷移し、登録されたサプリメント情報を受け取る
          final newSupplement = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSupplementScreen()),
          );
          if (newSupplement != null && newSupplement is Supplement) {
            setState(() {
              supplements.add(newSupplement);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}