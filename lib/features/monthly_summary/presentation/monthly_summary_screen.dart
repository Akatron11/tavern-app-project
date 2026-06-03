import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/l10n/generated/app_localizations.dart';
import '../application/monthly_providers.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/monthly_credit_table.dart';
import 'widgets/summary_cards_section.dart';

class MonthlySummaryScreen extends ConsumerWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final monthRange = ref.watch(currentMonthRangeProvider);
    final offset = ref.watch(monthOffsetProvider);
    final recordsAsync = ref.watch(monthlyRecordsProvider);
    final creditsAsync = ref.watch(monthlyCreditSalesProvider);
    final reportAsync = ref.watch(monthlyReportProvider);

    final monthLabel =
        intl.DateFormat('MMMM y', locale).format(monthRange.start);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.openMonthlySummary),
        actions: [
          IconButton(
            tooltip: l10n.prevMonth,
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                ref.read(monthOffsetProvider.notifier).previous(),
          ),
          IconButton(
            tooltip: l10n.nextMonth,
            icon: const Icon(Icons.chevron_right),
            onPressed: offset >= 0
                ? null
                : () => ref.read(monthOffsetProvider.notifier).next(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              monthLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Özet kartlar
            reportAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (report) => SummaryCardsSection(report: report),
            ),
            const SizedBox(height: 16),

            // Günlük ciro bar grafiği
            Text(
              l10n.monthlyRevenue,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            recordsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (records) => records.isEmpty
                  ? Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 24),
                        child: Text(l10n.noRecordsThisMonth),
                      ),
                    )
                  : MonthlyBarChart(
                      records: records, monthRange: monthRange),
            ),
            const SizedBox(height: 16),

            // Veresiye tablosu
            Text(
              l10n.monthlyCreditSalesTable,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            creditsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('$e'),
              data: (credits) => MonthlyCreditTable(credits: credits),
            ),
          ],
        ),
      ),
    );
  }
}
