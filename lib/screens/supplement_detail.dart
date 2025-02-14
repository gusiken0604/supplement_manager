import 'package:flutter/material.dart';
import '../models/supplement.dart';
import 'add_supplement.dart';

class SupplementDetailScreen extends StatefulWidget {
  final Supplement supplement;
  final Function(Supplement) onUpdate;
  final Function(Supplement) onDelete;

  const SupplementDetailScreen({super.key, 
    required this.supplement,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _SupplementDetailScreenState createState() => _SupplementDetailScreenState();
}

class _SupplementDetailScreenState extends State<SupplementDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplement.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedSupplement = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddSupplementScreen(
                    supplement: widget.supplement,
                  ),
                ),
              );
              if (updatedSupplement != null && updatedSupplement is Supplement) {
                widget.onUpdate(updatedSupplement); // 🔹 リストを更新
                setState(() {}); // 🔹 画面をリフレッシュ
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              widget.onDelete(widget.supplement);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            SizedBox(height: 8),
            Text('1日の摂取回数: ${widget.supplement.dailyIntake} 回',
            style: TextStyle(color: Colors.black), 
            ),
            // 文字色を黒に変更
            SizedBox(height: 8),
            Text('残薬数: ${widget.supplement.remaining}',
            style: TextStyle(color: Colors.black), 
            ),
          ],
        ),
      ),
    );
  }
}