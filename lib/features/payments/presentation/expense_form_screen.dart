import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/money_input_field.dart';
import '../application/payments_providers.dart';
import '../domain/pending_expense.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.expense});
  final PendingExpense? expense;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.expense?.description ?? '');
    _amountCtrl = TextEditingController(
      text: _isEdit
          ? (widget.expense!.totalAmount ~/ 100).toString()
          : '',
    );
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed =
        await showConfirmDialog(context, title: l10n.saveConfirmTitle);
    if (!confirmed) return;

    final amount = MoneyInputField.kurusOf(_amountCtrl);

    if (_isEdit) {
      await ref.read(paymentsControllerProvider.notifier).updateExpense(
            expense: widget.expense!,
            description: _descCtrl.text.trim(),
            totalAmount: amount,
          );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.expenseUpdated)));
        context.pop();
      }
    } else {
      await ref.read(paymentsControllerProvider.notifier).addExpense(
            description: _descCtrl.text.trim(),
            totalAmount: amount,
            date: DateTime.now(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.expenseAdded)));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar:
          AppBar(title: Text(_isEdit ? l10n.editExpense : l10n.addExpense)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _descCtrl,
                  decoration:
                      InputDecoration(labelText: l10n.expenseDescription),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.expenseDescriptionRequired
                      : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                MoneyInputField(
                  controller: _amountCtrl,
                  label: l10n.expenseTotalAmount,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.expenseTotalAmountRequired;
                    }
                    final n = MoneyInputField.liraValue(v);
                    if (n == null || n <= 0) {
                      return l10n.expenseTotalAmountInvalid;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _save(l10n),
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
