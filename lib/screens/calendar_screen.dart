import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/supplement.dart';

class CalendarScreen extends StatelessWidget {
  final List<Supplement> supplements;

  CalendarScreen({required this.supplements});

  // 残薬が無くなる日を計算するメソッド
  DateTime _getDepletionDate(Supplement supplement) {
    int daysUntilEmpty = (supplement.remaining / supplement.dailyIntake).ceil();
    final tzDepletionDate = tz.TZDateTime.now(tz.local).add(Duration(days: daysUntilEmpty));
    return DateTime(tzDepletionDate.year, tzDepletionDate.month, tzDepletionDate.day).toLocal();
  }

  // 各サプリメントの残薬切れ予測日を収集するメソッド
  Map<DateTime, List<String>> _getDepletionDates() {
    Map<DateTime, List<String>> depletionDates = {};

    for (var supplement in supplements) {
      DateTime depletionDate = _getDepletionDate(supplement);
      if (depletionDates.containsKey(depletionDate)) {
        depletionDates[depletionDate]!.add(supplement.name);
      } else {
        depletionDates[depletionDate] = [supplement.name];
      }
    }
    return depletionDates;
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
        eventLoader: (date) {
          // カレンダーの日付とdepletionDatesの日付をisSameDayで一致させる
          return depletionDates.keys
              .where((d) => isSameDay(d, date))
              .expand((d) => depletionDates[d]!)
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