import 'package:flutter/material.dart';

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../credit_book/domain/credit_sale.dart';

/// Ay içindeki veresiye kayıtları tablosu.
class MonthlyCreditTable extends StatelessWidget {
  const MonthlyCreditTable({super.key, required this.credits});

  final List<CreditSale> credits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    if (credits.isEmpty) {
      return Text(l10n.noCreditSales);
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          children: [
            _header(l10n.creditCustomer),
            _header(l10n.creditTotalAmount),
            _header(l10n.creditRemainingAmount),
          ],
        ),
        ...credits.map(
          (c) => TableRow(
            children: [
              _cell(c.customerName),
              _cell(c.totalAmount.toCurrency(locale)),
              _cell(c.remainingAmount.toCurrency(locale)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      );

  Widget _cell(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      );
}
