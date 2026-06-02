import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../application/credit_book_providers.dart';
import '../domain/credit_sale.dart';
import 'widgets/credit_sale_tile.dart';
import 'widgets/payment_dialog.dart';

class CreditListScreen extends ConsumerWidget {
  const CreditListScreen({super.key});

  List<CreditSale> _sorted(List<CreditSale> list) {
    const order = {
      CreditStatus.pending: 0,
      CreditStatus.partial: 1,
      CreditStatus.paid: 2,
    };
    final copy = [...list];
    copy.sort((a, b) {
      final s = order[a.status]!.compareTo(order[b.status]!);
      if (s != 0) return s;
      return b.date.compareTo(a.date);
    });
    return copy;
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    CreditSale sale,
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
              title: Text(l10n.editCreditSale),
              onTap: () {
                Navigator.of(ctx).pop();
                context.push('/credit/edit', extra: sale);
              },
            ),
            if (sale.status != CreditStatus.paid) ...[
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(l10n.addPayment),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final amount = await showPaymentDialog(
                    context,
                    remainingAmount: sale.remainingAmount,
                  );
                  if (amount != null && amount > 0) {
                    await ref
                        .read(creditBookControllerProvider.notifier)
                        .addPayment(sale.id, amount);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.paymentAdded)),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(l10n.markAsPaid),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.markAsPaidConfirmTitle,
                  );
                  if (confirmed) {
                    await ref
                        .read(creditBookControllerProvider.notifier)
                        .markPaid(sale.id);
                  }
                },
              ),
            ],
            if (sale.status == CreditStatus.paid)
              ListTile(
                leading: const Icon(Icons.undo),
                title: Text(l10n.undoPaid),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.undoPaidConfirmTitle,
                  );
                  if (confirmed) {
                    await ref
                        .read(creditBookControllerProvider.notifier)
                        .undoPaid(sale.id);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(creditSaleListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.creditBook)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/credit/add'),
        tooltip: l10n.addCreditSale,
        child: const Icon(Icons.add),
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(l10n.noCreditSales));
          }
          final sorted = _sorted(list);
          return ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final sale = sorted[i];
              return CreditSaleTile(
                sale: sale,
                onTap: () => _showActions(ctx, ref, sale, l10n),
              );
            },
          );
        },
      ),
    );
  }
}
