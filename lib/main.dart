import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/add_supplement.dart';
import 'screens/supplement_detail.dart';
import 'screens/calendar_screen.dart';
import 'models/supplement.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Tokyo')); // 日本のタイムゾーンに設定

  // タイムゾーン設定確認用のデバッグ出力
  final now = tz.TZDateTime.now(tz.local);
  print('Current Time in JST: $now'); // 日本時間の現在時刻を出力

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
    print('Calling _checkAndReduceRemaining'); // デバッグ出力追加
    _checkAndReduceRemaining();
  }

  // 最後の起動日をチェックし、日付が変わっていたら残薬を減少させるメソッド
  Future<void> _checkAndReduceRemaining() async {
    final prefs = await SharedPreferences.getInstance();

      final yesterday = DateTime.now().subtract(Duration(days: 1));
  await prefs.setString('lastCheckedDate', yesterday.toIso8601String());
  print('Set lastCheckedDate to yesterday for testing: $yesterday');

    // 最後に残薬をチェックした日付を取得
    final lastCheckedDateStr = prefs.getString('lastCheckedDate');
    final today = DateTime.now();
    print('Today\'s Date (JST): $today'); // 今日の日付を出力

    if (lastCheckedDateStr != null) {
      final lastCheckedDate = DateTime.parse(lastCheckedDateStr);
      print('Last Checked Date: $lastCheckedDate'); // 最後にチェックした日付を出力

      // 経過日数の計算
      final differenceInDays = today.difference(lastCheckedDate).inDays;
      print('Difference in Days: $differenceInDays'); // 日数の差を出力

      if (differenceInDays > 0) {
        final daysElapsed = differenceInDays;
        print('Days Elapsed Since Last Check: $daysElapsed'); // 経過日数を出力
        _reduceRemaining(daysElapsed);
      }
    } else {
      print('No lastCheckedDate found, saving today\'s date.');
    }

    // 今日の日付を保存
    await prefs.setString('lastCheckedDate', today.toIso8601String());
  }

  // 残薬を指定日数分減らすメソッド
void _reduceRemaining(int daysElapsed) {
  setState(() {
    for (var supplement in supplements) {
      final previousRemaining = supplement.remaining;
      supplement.remaining = (supplement.remaining - (supplement.dailyIntake * daysElapsed)).clamp(0, supplement.remaining);
      print('Supplement: ${supplement.name}, Previous Remaining: $previousRemaining, New Remaining: ${supplement.remaining}');
    }
  });
  _saveSupplements(); // 残薬の更新を保存
  print('Remaining reduced and saved'); // 残薬が保存されたことを確認
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