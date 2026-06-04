import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/generated/app_localizations.dart';

/// Kısmi ödeme dialog'u.
/// [remainingAmount] kuruş cinsinden maksimum tutardır.
/// Onaylanan tutarı kuruş olarak döndürür; iptal/hata durumunda null.
///
/// Controller, dialog içeriğini barındıran [_PaymentDialog] State'inde yönetilir;
/// böylece `dispose` route tamamen kaldırıldıktan sonra çalışır (BUG-04: `await
/// showDialog` sonrası erken dispose `_dependents.isEmpty` assertion'ına yol açıyordu).
Future<int?> showPaymentDialog(
  BuildContext context, {
  required int remainingAmount,
}) {
  return showDialog<int>(
    context: context,
    builder: (ctx) => _PaymentDialog(remainingAmount: remainingAmount),
  );
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.remainingAmount});

  final int remainingAmount;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final n = int.parse(_ctrl.text.trim());
      Navigator.of(context).pop(n * 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.addPayment),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.paymentAmount,
            border: const OutlineInputBorder(),
            suffixText: '₺',
            // BUG-07: uzun hata mesajı (kalandan fazla) tek satıra sığmıyordu.
            errorMaxLines: 3,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return l10n.paymentAmountRequired;
            }
            final n = int.tryParse(v.trim());
            if (n == null || n <= 0) return l10n.paymentAmountInvalid;
            final kurus = n * 100;
            if (kurus > widget.remainingAmount) {
              return l10n.paymentAmountExceedsRemaining;
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
