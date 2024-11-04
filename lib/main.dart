import 'package:flutter/material.dart';
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

  void updateSupplement(Supplement updatedSupplement) {
    setState(() {
      final index = supplements.indexWhere((s) => s.name == updatedSupplement.name);
      if (index != -1) {
        supplements[index] = updatedSupplement;
      }
    });
  }

  void deleteSupplement(Supplement supplement) {
    setState(() {
      supplements.remove(supplement);
    });
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
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}