import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../daily_record/domain/daily_record.dart';

/// Bir aydaki günlük ciro bar grafiği (fl_chart).
/// Alt etiketlerde 1, 5, 10, 15, 20, 25, 30/31 gösterilir.
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    super.key,
    required this.records,
    required this.monthRange,
  });

  final List<DailyRecord> records;
  final DateRange monthRange;

  @override
  Widget build(BuildContext context) {
    final recordMap = {for (final r in records) dayKey(r.date): r};
    final lastDay = monthRange.end.subtract(const Duration(days: 1));
    final daysInMonth = lastDay.day;

    final groups = List.generate(daysInMonth, (i) {
      final day = DateTime(
        monthRange.start.year,
        monthRange.start.month,
        i + 1,
      );
      final revenue = (recordMap[dayKey(day)]?.revenue ?? 0) / 100.0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: revenue,
            color: Theme.of(context).colorScheme.primary,
            width: 8,
            borderRadius: BorderRadius.circular(2),
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
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
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
                  final d = value.toInt() + 1;
                  if (d == 1 || d % 5 == 0) {
                    return Text('$d',
                        style: const TextStyle(fontSize: 10));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = DateTime(
                  monthRange.start.year,
                  monthRange.start.month,
                  group.x + 1,
                );
                final rev = recordMap[dayKey(day)]?.revenue ?? 0;
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
