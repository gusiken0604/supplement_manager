import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/add_supplement.dart';
import 'screens/supplement_detail.dart';
import 'screens/calendar_screen.dart'; // カレンダー画面のインポート
import 'models/supplement.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutterの初期化

  // タイムゾーンの初期化
  tz.initializeTimeZones();
  
  // ローカルタイムゾーンの設定
  tz.setLocalLocation(tz.getLocation('America/Los_Angeles')); // 適切なタイムゾーンに変更してください
  
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

  @override
  void initState() {
    super.initState();
    _loadSupplements();
  }

  Future<void> _saveSupplements() async {
    final prefs = await SharedPreferences.getInstance();
    final supplementList = supplements.map((s) => jsonEncode(s.toMap())).toList();
    await prefs.setStringList('supplements', supplementList);
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(supplements: supplements),
                ),
              );
            },
          ),
        ],
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
                      'カテゴリー: ${supplement.category}, 形状: ${supplement.form}, 残薬数: ${supplement.remaining}'),
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