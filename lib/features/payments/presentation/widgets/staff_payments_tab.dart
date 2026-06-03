import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../application/payments_providers.dart';
import '../../domain/payroll_summary.dart';
import 'staff_payment_dialog.dart';

class StaffPaymentsTab extends ConsumerWidget {
  const StaffPaymentsTab({super.key});

  Future<void> _recordPayment(
    BuildContext context,
    WidgetRef ref,
    StaffPayrollRow row,
    AppLocalizations l10n,
  ) async {
    final amount =
        await showStaffPaymentDialog(context, staffName: row.staffName);
    if (amount == null || amount <= 0) return;
    if (!context.mounted) return;

    final confirmed = await showConfirmDialog(
      context,
      title: l10n.paymentToStaffConfirmTitle,
    );
    if (!confirmed) return;

    await ref.read(paymentsControllerProvider.notifier).addStaffPayment(
          staffId: row.staffId,
          amount: amount,
          date: DateTime.now(),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.staffPaymentAdded)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rowsAsync = ref.watch(staffPayrollRowsProvider);
    final locale = Localizations.localeOf(context).toString();

    return rowsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (rows) {
        if (rows.isEmpty) {
          return Center(child: Text(l10n.noStaffForPayments));
        }
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, index) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final row = rows[i];
            return ListTile(
              title: Text(
                row.staffName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${l10n.workedDays}: ${row.workedDays} · '
                '${l10n.accruedWage}: ${row.accruedWage.toCurrency(locale)} · '
                '${l10n.totalPaid}: ${row.totalPaid.toCurrency(locale)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    row.remaining.toCurrency(locale),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: row.remaining > 0
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_card_outlined),
                    tooltip: l10n.addPaymentToStaff,
                    onPressed: row.remaining > 0
                        ? () => _recordPayment(ctx, ref, row, l10n)
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
