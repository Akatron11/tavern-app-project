import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/extensions/currency_extension.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../application/weekly_providers.dart';
import 'widgets/daily_summary_list.dart';
import 'widgets/staff_days_table.dart';
import 'widgets/weekly_bar_chart.dart';

class WeeklySummaryScreen extends ConsumerWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final weekRange = ref.watch(currentWeekRangeProvider);
    final offset = ref.watch(weekOffsetProvider);
    final recordsAsync = ref.watch(weeklyRecordsProvider);
    final openTipsAsync = ref.watch(openTipsProvider);
    final staffDaysAsync = ref.watch(weeklyStaffDaysProvider);

    final startLabel =
        intl.DateFormat('d MMM', locale).format(weekRange.start);
    final endLabel = intl.DateFormat('d MMM y', locale).format(
      weekRange.end.subtract(const Duration(days: 1)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.openWeeklySummary),
        actions: [
          IconButton(
            tooltip: l10n.prevWeek,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(weekOffsetProvider.notifier).previous(),
          ),
          IconButton(
            tooltip: l10n.nextWeek,
            icon: const Icon(Icons.chevron_right),
            onPressed: offset >= 0
                ? null
                : () => ref.read(weekOffsetProvider.notifier).next(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '$startLabel – $endLabel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Bar grafik
            recordsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(l10n.genericError),
              data: (records) => records.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(l10n.noRecordsThisWeek),
                      ),
                    )
                  : WeeklyBarChart(
                      records: records, weekRange: weekRange),
            ),
            const SizedBox(height: 16),

            // Açık bahşiş + Dağıtıldı butonu
            openTipsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text(l10n.genericError),
              data: (openTips) => _OpenTipsSection(
                openTips: openTips,
                locale: locale,
                weekRange: weekRange,
              ),
            ),
            const SizedBox(height: 16),

            // Günlük özet listesi
            Text(
              l10n.dailyRecord,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            recordsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text(l10n.genericError),
              data: (records) =>
                  DailySummaryList(records: records, weekRange: weekRange),
            ),
            const SizedBox(height: 16),

            // Personel günleri tablosu
            Text(
              l10n.staffDaysTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            staffDaysAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text(l10n.genericError),
              data: (staffDays) => StaffDaysTable(staffDays: staffDays),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenTipsSection extends ConsumerWidget {
  const _OpenTipsSection({
    required this.openTips,
    required this.locale,
    required this.weekRange,
  });

  final int openTips;
  final String locale;
  final ({DateTime start, DateTime end}) weekRange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ctrl = ref.read(tipDistributionControllerProvider.notifier);
    final ctrlState = ref.watch(tipDistributionControllerProvider);

    if (openTips <= 0) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: Text(l10n.noOpenTips),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.openTips,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    openTips.toCurrency(locale),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: ctrlState.isLoading
                  ? null
                  : () async {
                      final confirmed = await showConfirmDialog(
                        context,
                        title: l10n.distributeTipsConfirmTitle,
                        body: l10n.distributeTipsConfirmBody(
                            openTips.toCurrency(locale)),
                        confirmLabel: l10n.distributeTips,
                      );
                      if (confirmed != true) return;
                      await ctrl.distribute(
                        amount: openTips,
                        periodStart: weekRange.start,
                        periodEnd: DateTime.now(),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.tipsDistributed)),
                        );
                      }
                    },
              child: Text(l10n.distributeTips),
            ),
          ],
        ),
      ),
    );
  }
}
