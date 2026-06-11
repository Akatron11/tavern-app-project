import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/money/currency_formatter.dart';
import '../../domain/credit_sale.dart';

class CreditSaleTile extends StatelessWidget {
  const CreditSaleTile({
    super.key,
    required this.sale,
    required this.onTap,
  });

  final CreditSale sale;
  final VoidCallback onTap;

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (sale.status) {
      CreditStatus.pending => cs.error,
      CreditStatus.partial => cs.tertiary,
      CreditStatus.paid => cs.primary,
    };
  }

  String _statusLabel(AppLocalizations l10n) => switch (sale.status) {
        CreditStatus.pending => l10n.creditStatusPending,
        CreditStatus.partial => l10n.creditStatusPartial,
        CreditStatus.paid => l10n.creditStatusPaid,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final color = _statusColor(context);

    return ListTile(
      title: Text(sale.customerName,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${DateFormat('dd.MM.yyyy').format(sale.date)} · '
        '${l10n.creditRemainingAmount}: ${formatCurrency(sale.remainingAmount, locale: locale)} / ${formatCurrency(sale.totalAmount, locale: locale)}',
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Chip(
        label: Text(
          _statusLabel(l10n),
          style: TextStyle(
              color: color, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        backgroundColor: color.withAlpha(26),
        side: BorderSide.none,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
      onTap: onTap,
    );
  }
}
