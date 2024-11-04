import 'package:flutter/material.dart';
import 'dart:convert'; // JSONエンコード/デコードのために追加
import 'package:shared_preferences/shared_preferences.dart'; // shared_preferencesのインポート
import 'screens/add_supplement.dart';
import 'screens/supplement_detail.dart';
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
  List<Supplement> supplements = [];

    // 1. アプリ起動時にデータをロード
  @override
  void initState() {
    super.initState();
    _loadSupplements();
  }

  // 2. サプリメントデータの保存処理
  Future<void> _saveSupplements() async {
    final prefs = await SharedPreferences.getInstance();
    final supplementList = supplements.map((s) => jsonEncode(s.toMap())).toList();
    await prefs.setStringList('supplements', supplementList);
  }

  // 3. サプリメントデータの読み込み処理
  Future<void> _loadSupplements() async {
    final prefs = await SharedPreferences.getInstance();
    final supplementList = prefs.getStringList('supplements') ?? [];
    setState(() {
      supplements = supplementList.map((s) => Supplement.fromMap(jsonDecode(s))).toList();
    });
  }


  void updateSupplement(Supplement updatedSupplement) {
    setState(() {
      final index = supplements.indexWhere((s) => s.name == updatedSupplement.name);
      if (index != -1) {
        supplements[index] = updatedSupplement;
      }
    });
    _saveSupplements();
  }

  void deleteSupplement(Supplement supplement) {
    setState(() {
      supplements.remove(supplement);
    });
    _saveSupplements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('サプリメント管理アプリ'),
      ),
      body: supplements.isEmpty
          ? Center(child: Text('サプリメントが登録されていません'))
          : ListView.builder(
              itemCount: supplements.length,
              itemBuilder: (context, index) {
                final supplement = supplements[index];
                return ListTile(
                  title: Text(supplement.name),
                  subtitle: Text(
                      'カテゴリー: ${supplement.category}, 形状: ${supplement.form}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SupplementDetailScreen(
                          supplement: supplement,
                          onUpdate: updateSupplement,
                          onDelete: deleteSupplement,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newSupplement = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSupplementScreen()),
          );
          if (newSupplement != null && newSupplement is Supplement) {
            setState(() {
              supplements.add(newSupplement);
            });
            _saveSupplements();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}