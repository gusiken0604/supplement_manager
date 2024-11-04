import 'package:flutter/material.dart';
import '../models/supplement.dart';
import 'add_supplement.dart';

class SupplementDetailScreen extends StatefulWidget {
  final Supplement supplement;
  final Function(Supplement) onUpdate;
  final Function(Supplement) onDelete;

  SupplementDetailScreen({
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
                    initialSupplement: widget.supplement,
                  ),
                ),
              );
              if (updatedSupplement != null) {
                widget.onUpdate(updatedSupplement);
                setState(() {});
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
            Text('カテゴリー: ${widget.supplement.category}'),
            SizedBox(height: 8),
            Text('形状: ${widget.supplement.form}'),
            SizedBox(height: 8),
            Text('1回の摂取量: ${widget.supplement.dose} mg'),
            SizedBox(height: 8),
            Text('1日の摂取回数: ${widget.supplement.dailyIntake} 回'),
          ],
        ),
      ),
    );
  }
}