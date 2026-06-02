import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/money/currency_formatter.dart';
import '../../domain/daily_record_calculator.dart';

/// Girilen değerlerden günlük/toplam kasayı **canlı** hesaplayıp gösterir.
/// Hesaplama tek kaynak: [DailyRecordCalculator] (patron masrafı kasayı
/// etkilemez; iki masraf kalemi ayrı gösterilir).
class LiveTotalsCard extends StatelessWidget {
  const LiveTotalsCard({
    super.key,
    required this.revenue,
    required this.creditCard,
    required this.tips,
    required this.ownerExpenses,
    required this.cashExpenses,
    required this.creditSales,
    required this.previousDayCash,
  });

  final int revenue;
  final int creditCard;
  final int tips;
  final int ownerExpenses;
  final int cashExpenses;
  final int creditSales;
  final int previousDayCash;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final daily = DailyRecordCalculator.dailyCash(
      revenue: revenue,
      creditCard: creditCard,
      tips: tips,
      cashExpenses: cashExpenses,
      creditSales: creditSales,
    );
    final total = DailyRecordCalculator.totalCash(previousDayCash, daily);
    final totalExpense =
        DailyRecordCalculator.totalExpensesDisplay(ownerExpenses, cashExpenses);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.liveTotals,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.spaceSm),
            _row(context, l10n.ownerExpense,
                formatCurrency(ownerExpenses, locale: locale),
                rowKey: const Key('ownerExpenseValue')),
            _row(context, l10n.cashExpense,
                formatCurrency(cashExpenses, locale: locale),
                rowKey: const Key('cashExpenseValue')),
            _row(context, l10n.totalExpense,
                formatCurrency(totalExpense, locale: locale),
                rowKey: const Key('totalExpenseValue')),
            const Divider(),
            _row(context, l10n.dailyCash,
                formatCurrency(daily, locale: locale),
                rowKey: const Key('dailyCashValue'), emphasize: true),
            _row(context, l10n.totalCash,
                formatCurrency(total, locale: locale),
                rowKey: const Key('totalCashValue'), emphasize: true),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {required Key rowKey, bool emphasize = false}) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, key: rowKey, style: style),
        ],
      ),
    );
  }
}
