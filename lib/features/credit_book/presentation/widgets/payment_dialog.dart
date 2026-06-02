import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/generated/app_localizations.dart';

/// Kısmi ödeme dialog'u.
/// [remainingAmount] kuruş cinsinden maksimum tutardır.
/// Onaylanan tutarı kuruş olarak döndürür; iptal/hata durumunda null.
Future<int?> showPaymentDialog(
  BuildContext context, {
  required int remainingAmount,
}) async {
  final l10n = AppLocalizations.of(context);
  final ctrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final result = await showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.addPayment),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.paymentAmount,
            border: const OutlineInputBorder(),
            suffixText: '₺',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return l10n.paymentAmountRequired;
            }
            final n = int.tryParse(v.trim());
            if (n == null || n <= 0) return l10n.paymentAmountInvalid;
            final kurus = n * 100;
            if (kurus > remainingAmount) {
              return l10n.paymentAmountExceedsRemaining;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(null),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final n = int.parse(ctrl.text.trim());
              Navigator.of(ctx).pop(n * 100);
            }
          },
          child: Text(l10n.confirm),
        ),
      ],
    ),
  );
  ctrl.dispose();
  return result;
}
