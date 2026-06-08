import 'package:flutter/material.dart';

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/monthly_report.dart';

/// Aylık özet istatistik kartları (Wrap grid).
class SummaryCardsSection extends StatelessWidget {
  const SummaryCardsSection({super.key, required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatCard(
          label: l10n.monthlyRevenue,
          value: report.revenue.toCurrency(locale),
          color: cs.primary,
        ),
        _StatCard(
          label: l10n.monthlyCreditCard,
          value: report.creditCard.toCurrency(locale),
          color: cs.error,
        ),
        _StatCard(
          label: l10n.monthlyCashExpenses,
          value: report.cashExpenses.toCurrency(locale),
          color: cs.error,
        ),
        _StatCard(
          label: l10n.monthlyOwnerExpenses,
          value: report.ownerExpenses.toCurrency(locale),
          color: cs.error,
        ),
        _StatCard(
          label: l10n.monthlyStaffWages,
          value: report.staffWages.toCurrency(locale),
          color: cs.error,
        ),
        _StatCard(
          label: l10n.monthlyOutstandingCredit,
          value: report.outstandingCredit.toCurrency(locale),
        ),
        _StatCard(
          label: l10n.monthlyUncollectible,
          value: report.uncollectibleCredit.toCurrency(locale),
          color: cs.error,
        ),
        _StatCard(
          label: l10n.monthlyProfitLabel,
          value: report.profit.toCurrency(locale),
          color: report.profit >= 0 ? cs.primary : cs.error,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
