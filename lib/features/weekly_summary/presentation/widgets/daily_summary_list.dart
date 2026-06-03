import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../daily_record/domain/daily_record.dart';

class DailySummaryList extends StatelessWidget {
  const DailySummaryList({
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
    final days = List.generate(
      7,
      (i) => DateTime(
        weekRange.start.year,
        weekRange.start.month,
        weekRange.start.day + i,
      ),
    );

    return Column(
      children: days.map((day) {
        final key = dayKey(day);
        final record = recordMap[key];
        final dateLabel = intl.DateFormat('d MMM, EEEE', locale).format(day);

        if (record == null) {
          return ListTile(
            dense: true,
            title: Text(
              dateLabel,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            subtitle: const Text('—'),
          );
        }

        return ListTile(
          dense: true,
          title: Text(dateLabel),
          subtitle: Text(
            'Ciro: ${record.revenue.toCurrency(locale)}  |  Kasa: ${record.dailyCash.toCurrency(locale)}',
          ),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () => context.push('/daily', extra: {'date': key}),
        );
      }).toList(),
    );
  }
}
