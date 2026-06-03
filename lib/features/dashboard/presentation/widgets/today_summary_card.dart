import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../application/dashboard_providers.dart';

class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(todayRecordProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
          data: (record) {
            if (record == null) {
              return Text(
                l10n.noRecordToday,
                style: Theme.of(context).textTheme.bodyMedium,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.todaySummary,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.dailyCash),
                    Text(record.dailyCash.toCurrency(locale)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.workingStaffCountLabel),
                    Text('${record.workingStaffIds.length}'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
