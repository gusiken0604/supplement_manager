import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'screens/add_supplement.dart';
import 'screens/supplement_detail.dart';
import 'screens/calendar_screen.dart';
import 'models/supplement.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue, // メインカラー（ブルー）
  ).copyWith(
    primary: const Color(0xFF2196F3), // メインカラー
    secondary: const Color(0xFFBDBDBD), // アクセントカラー
  ),
  scaffoldBackgroundColor: Colors.white, // 背景色
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2196F3), // AppBarの背景色
    foregroundColor: Colors.white, // タイトルやアイコンの色
    elevation: 0, // 影をなくす（必要に応じて）
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFF2196F3), // ボタンの色
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle( // 画面タイトル
      color: Color(0xFF2196F3), 
      fontSize: 22, 
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle( // カテゴリータイトル
      color: Color(0xFF424242), 
      fontSize: 18, 
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle( // メインテキスト（サプリ名など）
      color: Color(0xFF212121), 
      fontSize: 16,
    ),
    bodyMedium: TextStyle( // サブテキスト（補足情報）
      color: Color(0xFF757575), 
      fontSize: 14,
    ),
    labelLarge: TextStyle( // ボタンの文字
      color: Colors.white, 
      fontSize: 16, 
      fontWeight: FontWeight.bold,
    ),
  ),
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const IOSInitializationSettings iosSettings =
      IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidSettings, iOS: iosSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      if (payload != null) {
      }
    },
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supplement Manager',
     
        //primarySwatch: Colors.blue,
        theme: appTheme, 
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Supplement> supplements = [];
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    _loadSupplements();
    _checkAndReduceRemaining();
  }

  void _forceTestNotification() {
    setState(() {
      for (var supplement in supplements) {
        supplement.remaining = 20; // 🔹 残薬を 20 に設定
      }
    });
    _saveSupplements(); // 🔹 データを保存
    print("✅ 残薬数を 20 に変更しました！");
  }

  void _reduceRemaining(int daysElapsed) {
    setState(() {
      for (var supplement in supplements) {
        final previousRemaining = supplement.remaining;
        supplement.remaining =
            (supplement.remaining - (supplement.dailyIntake * daysElapsed))
                .clamp(0, supplement.remaining);

        print("🔍 [${supplement.name}] 残薬: $previousRemaining → ${supplement.remaining}");

        if (previousRemaining > 20 && supplement.remaining <= 20) {
          print("🚨 [${supplement.name}] 残薬が 20 以下になりました！通知を送信します");
          _showNotification(supplement.name, supplement.remaining);
        }
      }
    });
    _saveSupplements();
  }
Future<void> _showNotification(String supplementName, int remaining) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'supplement_channel', // 通知チャンネルID
    'サプリメント通知', // 通知チャンネル名
    'サプリメントの残薬が少なくなった時に通知します', // 🔹 3 番目の引数（チャンネル説明）
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  try {
    await flutterLocalNotificationsPlugin.show(
      0, // 通知ID
      '⚠️ サプリメントの残薬が少なくなっています！',
      '$supplementName の残薬が $remaining になりました。',
      notificationDetails,
    );
    print("✅ 通知を送信しました: $supplementName ($remaining)");
  } catch (e) {
    print("❌ 通知の送信エラー: $e");
  }
}

  DateTime _getDepletionDate(Supplement supplement) {
    int daysUntilEmpty = (supplement.remaining / supplement.dailyIntake).ceil();
    return DateTime.now().add(Duration(days: daysUntilEmpty - 1));
  }

  void _sortSupplements() {
    setState(() {
      supplements.sort((a, b) => isAscending
          ? a.remaining.compareTo(b.remaining)
          : b.remaining.compareTo(a.remaining));
      isAscending = !isAscending;
    });
  }

  Future<void> _checkAndReduceRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckedDateStr = prefs.getString('lastCheckedDate');
    final today = DateTime.now();

    if (lastCheckedDateStr != null) {
      final lastCheckedDate = DateTime.parse(lastCheckedDateStr);
      final differenceInDays = today.difference(lastCheckedDate).inDays;

      if (differenceInDays > 0) {
        _reduceRemaining(differenceInDays);
      }
    }

    await prefs.setString('lastCheckedDate', today.toIso8601String());
  }

  Future<void> _saveSupplements() async {
    final prefs = await SharedPreferences.getInstance();
    final supplementList =
        supplements.map((s) => jsonEncode(s.toMap())).toList();
    await prefs.setStringList('supplements', supplementList);
  }

  Future<void> _loadSupplements() async {
    final prefs = await SharedPreferences.getInstance();
    final supplementList = prefs.getStringList('supplements') ?? [];
    setState(() {
      supplements = supplementList
          .map((s) => Supplement.fromMap(jsonDecode(s)))
          .toList();
      _sortSupplements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('サプリメント管理アプリ'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _sortSupplements,
            tooltip: '残薬数で並び替え',
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CalendarScreen(supplements: supplements),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              print("🚀 通知テストボタンが押されました");
              _showNotification("テストサプリ", 20);
            },
            child: Text("通知テスト"),
          ),
          ElevatedButton(
  onPressed: _forceTestNotification,
  child: Text("残薬を 20 に設定"),
),
Expanded(
  child: supplements.isEmpty
      ? Center(child: Text('サプリメントが登録されていません'))
      : Container(
          height: double.infinity, // 高さを確保
          child: ListView.separated(
            itemCount: supplements.length,
            itemBuilder: (context, index) {
              final supplement = supplements[index];
              final depletionDate = _getDepletionDate(supplement);
              final formattedDepletionDate =
                  '${depletionDate.year}/${depletionDate.month}/${depletionDate.day}';

              return ListTile(
                title: Text(supplement.name),
                subtitle: Text(
                  '残薬数: ${supplement.remaining}\n'
                  '無くなる日: $formattedDepletionDate',
                ),
                onTap: () async {
                  final updatedSupplement = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddSupplementScreen(
                        supplement: supplement, // 既存のサプリメント情報を渡す
                      ),
                    ),
                  );

                  if (updatedSupplement != null) {
                    setState(() {
                      supplements[index] = updatedSupplement; // 変更を反映
                    });
                    _saveSupplements();
                  }
                },
              );
            },
            separatorBuilder: (context, index) => Divider(
              color: Colors.black, // 色を黒に設定
              thickness: 1.0, // 線の太さ
              height: 10, // 間隔
            ),
          ),
        ),
),
          // Expanded(
          //   child: supplements.isEmpty
          //       ? Center(child: Text('サプリメントが登録されていません'))
          //       : ListView.separated(
          //           itemCount: supplements.length,
          //           itemBuilder: (context, index) {
          //             final supplement = supplements[index];
          //             final depletionDate = _getDepletionDate(supplement);
          //             final formattedDepletionDate =
          //                 '${depletionDate.year}/${depletionDate.month}/${depletionDate.day}';

          //             return ListTile(
          //               title: Text(supplement.name),
          //               subtitle: Text(
          //                 //'カテゴリー: ${supplement.category}, 形状: ${supplement.form}\n'
          //                 '残薬数: ${supplement.remaining}\n'
          //                 '無くなる日: $formattedDepletionDate',
          //               ),
          //               onTap: () {
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (context) => SupplementDetailScreen(
          //                       supplement: supplement,
          //                       onUpdate: (updatedSupplement) {
          //                         setState(() {
          //                           final index = supplements.indexWhere(
          //                               (s) => s.name == updatedSupplement.name);
          //                           if (index != -1) {
          //                             supplements[index] = updatedSupplement;
          //                           }
          //                         });
          //                         _saveSupplements();
          //                       },
          //                       onDelete: (deletedSupplement) {
          //                         setState(() {
          //                           supplements.removeWhere(
          //                               (s) => s.name == deletedSupplement.name);
          //                         });
          //                         _saveSupplements();
          //                       },
          //                     ),
          //                   ),
          //                 );
          //               },
          //             );
          //           },
          //           separatorBuilder: (context, index) => const Divider(
          //             color: Colors.black,
          //             thickness: 2.0,
          //             height:10,
          //           ),
          //         ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newSupplement = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSupplementScreen()),
          );
          if (newSupplement != null) {
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