import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/utils/date_utils.dart';
import '../../../daily_record/domain/daily_record.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.records,
    required this.weekRange,
  });

  final List<DailyRecord> records;
  final DateRange weekRange;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final recordMap = {for (final r in records) dayKey(r.date): r};

    final groups = List.generate(7, (i) {
      final day = DateTime(
        weekRange.start.year,
        weekRange.start.month,
        weekRange.start.day + i,
      );
      final key = dayKey(day);
      final revenue = (recordMap[key]?.revenue ?? 0) / 100.0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: revenue,
            color: Theme.of(context).colorScheme.primary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: groups,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}₺',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final day = DateTime(
                    weekRange.start.year,
                    weekRange.start.month,
                    weekRange.start.day + value.toInt(),
                  );
                  final raw = intl.DateFormat('E', locale).format(day);
                  final label =
                      raw.length >= 3 ? raw.substring(0, 3) : raw;
                  return Text(label, style: const TextStyle(fontSize: 11));
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = DateTime(
                  weekRange.start.year,
                  weekRange.start.month,
                  weekRange.start.day + group.x,
                );
                final key = dayKey(day);
                final rev = recordMap[key]?.revenue ?? 0;
                return BarTooltipItem(
                  '${(rev / 100).toStringAsFixed(0)} ₺',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
