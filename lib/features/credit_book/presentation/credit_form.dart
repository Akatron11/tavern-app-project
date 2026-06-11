import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/money_input_field.dart';
import '../application/credit_book_providers.dart';
import '../domain/credit_sale.dart';

class CreditForm extends ConsumerStatefulWidget {
  const CreditForm({super.key, this.sale});

  /// Düzenleme modunda dolu gelir; eklemede null.
  final CreditSale? sale;

  @override
  ConsumerState<CreditForm> createState() => _CreditFormState();
}

class _CreditFormState extends ConsumerState<CreditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late DateTime _date;

  bool get _isEdit => widget.sale != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.sale?.customerName ?? '');
    final amountLira = widget.sale != null
        ? (widget.sale!.totalAmount ~/ 100).toString()
        : '';
    _amountCtrl = TextEditingController(text: amountLira);
    _date = widget.sale?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);

    final confirmed = await showConfirmDialog(
      context,
      title: l10n.saveConfirmTitle,
    );
    if (!confirmed) return;

    final customerName = _nameCtrl.text.trim();
    final totalKurus = MoneyInputField.kurusOf(_amountCtrl);

    if (_isEdit) {
      await ref.read(creditBookControllerProvider.notifier).updateSale(
            widget.sale!,
            customerName: customerName,
            totalAmount: totalKurus,
            date: _date,
          );
    } else {
      await ref.read(creditBookControllerProvider.notifier).addSale(
            customerName: customerName,
            totalAmount: totalKurus,
            date: _date,
          );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            _isEdit ? l10n.creditSaleUpdated : l10n.creditSaleAdded),
      ));
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editCreditSale : l10n.addCreditSale),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.creditCustomer,
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.creditCustomerRequired
                      : null,
                ),
                const SizedBox(height: 16),
                MoneyInputField(
                  controller: _amountCtrl,
                  label: l10n.creditTotalAmount,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.creditTotalAmountRequired;
                    }
                    final n = MoneyInputField.liraValue(v);
                    if (n == null || n <= 0) return l10n.creditTotalAmountInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(l10n.date),
                  subtitle: Text(DateFormat('dd.MM.yyyy').format(_date)),
                  trailing: const Icon(Icons.edit),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _submit,
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
