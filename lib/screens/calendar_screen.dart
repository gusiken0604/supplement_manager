import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/supplement.dart';

class CalendarScreen extends StatefulWidget {
  final List<Supplement> supplements;

  CalendarScreen({required this.supplements});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selectedDay;
  
  // 残薬が無くなる日を計算するメソッド
  DateTime _getDepletionDate(Supplement supplement) {
    int daysUntilEmpty = (supplement.remaining / supplement.dailyIntake).ceil();
    final tzDepletionDate = tz.TZDateTime.now(tz.local).add(Duration(days: daysUntilEmpty));
    return DateTime(tzDepletionDate.year, tzDepletionDate.month, tzDepletionDate.day);
  }

  // 各サプリメントの残薬切れ予測日を収集するメソッド
  Map<DateTime, List<String>> _getDepletionDates() {
    Map<DateTime, List<String>> depletionDates = {};

    for (var supplement in widget.supplements) {
      DateTime depletionDate = _getDepletionDate(supplement);
      if (depletionDates.containsKey(depletionDate)) {
        depletionDates[depletionDate]!.add(supplement.name);
      } else {
        depletionDates[depletionDate] = [supplement.name];
      }
    }
    return depletionDates;
  }

  // 日付をタップしたときにサプリメント名を表示するメソッド
  void _onDaySelected(BuildContext context, DateTime day, List<String> events) {
    if (events.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("サプリメント残薬切れ予定"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: events.map((event) => Text(event)).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("閉じる"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final depletionDates = _getDepletionDates();

    return Scaffold(
      appBar: AppBar(
        title: Text('残薬カレンダー'),
      ),
      body: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(Duration(days: 365)),
        focusedDay: DateTime.now(),
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
          });
          final events = depletionDates.entries
              .where((entry) => isSameDay(entry.key, selectedDay))
              .expand((entry) => entry.value)
              .toList();
          print('Selected Day: $selectedDay, Events: $events'); // デバッグ出力
          _onDaySelected(context, selectedDay, events);
        },
        eventLoader: (date) {
          return depletionDates.entries
              .where((entry) => isSameDay(entry.key, date))
              .expand((entry) => entry.value)
              .toList();
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red, // 残薬が無くなる日を赤で表示
                  ),
                ),
              );
            }
            return null;
          },
        ),
        calendarStyle: CalendarStyle(
          markersAlignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}