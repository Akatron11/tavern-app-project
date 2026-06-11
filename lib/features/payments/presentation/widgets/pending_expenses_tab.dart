import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../application/payments_providers.dart';
import '../../domain/pending_expense.dart';
import 'expense_payment_dialog.dart';

class PendingExpensesTab extends ConsumerWidget {
  const PendingExpensesTab({super.key});

  Color _statusColor(BuildContext context, ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.paid:
        return Theme.of(context).colorScheme.primary;
      case ExpenseStatus.partial:
        return Colors.orange;
      case ExpenseStatus.pending:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _statusLabel(AppLocalizations l10n, ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.paid:
        return l10n.expenseStatusPaid;
      case ExpenseStatus.partial:
        return l10n.expenseStatusPartial;
      case ExpenseStatus.pending:
        return l10n.expenseStatusPending;
    }
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    PendingExpense expense,
    AppLocalizations l10n,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.editExpense),
              onTap: () {
                Navigator.of(ctx).pop();
                context.push('/payments/expense/edit', extra: expense);
              },
            ),
            if (expense.status != ExpenseStatus.paid) ...[
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(l10n.addPayment),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final amount = await showExpensePaymentDialog(
                    context,
                    remainingAmount: expense.remainingAmount,
                  );
                  if (amount != null && amount > 0) {
                    await ref
                        .read(paymentsControllerProvider.notifier)
                        .addExpensePayment(expense.id, amount);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.expensePaymentAdded)));
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(l10n.expenseMarkAsPaid),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.expenseMarkAsPaidConfirmTitle,
                  );
                  if (confirmed) {
                    await ref
                        .read(paymentsControllerProvider.notifier)
                        .markExpensePaid(expense.id);
                  }
                },
              ),
            ],
            if (expense.status == ExpenseStatus.paid) ...[
              ListTile(
                leading: const Icon(Icons.undo),
                title: Text(l10n.expenseUndoPaid),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.expenseUndoPaidConfirmTitle,
                  );
                  if (confirmed) {
                    await ref
                        .read(paymentsControllerProvider.notifier)
                        .undoExpensePaid(expense.id);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                title: Text(l10n.deleteExpense),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.deleteExpenseConfirmTitle,
                    destructive: true,
                  );
                  if (confirmed) {
                    await ref
                        .read(paymentsControllerProvider.notifier)
                        .deleteExpense(expense.id);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(expensesStreamProvider);
    final locale = Localizations.localeOf(context).toString();

    return Stack(
      children: [
        listAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (list) {
            if (list.isEmpty) {
              return Center(child: Text(l10n.noExpenses));
            }
            final sorted = [...list]
              ..sort((a, b) {
                const order = {
                  ExpenseStatus.pending: 0,
                  ExpenseStatus.partial: 1,
                  ExpenseStatus.paid: 2,
                };
                final s = order[a.status]!.compareTo(order[b.status]!);
                return s != 0 ? s : b.date.compareTo(a.date);
              });
            return ListView.separated(
              itemCount: sorted.length,
              separatorBuilder: (_, index) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final e = sorted[i];
                return ListTile(
                  title: Text(e.description),
                  subtitle: Text(
                    '${e.totalAmount.toCurrency(locale)} · '
                    '${l10n.creditRemainingAmount}: ${e.remainingAmount.toCurrency(locale)}',
                  ),
                  trailing: Chip(
                    label: Text(
                      _statusLabel(l10n, e.status),
                      style: const TextStyle(fontSize: 14),
                    ),
                    backgroundColor:
                        _statusColor(context, e.status).withValues(alpha: 0.15),
                    labelStyle:
                        TextStyle(color: _statusColor(context, e.status)),
                    side: BorderSide.none,
                  ),
                  onTap: () => _showActions(ctx, ref, e, l10n),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'addExpenseFab',
            onPressed: () => context.push('/payments/expense/add'),
            tooltip: l10n.addExpense,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
