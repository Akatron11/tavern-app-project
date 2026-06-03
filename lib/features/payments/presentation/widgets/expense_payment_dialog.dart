import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/money_input_field.dart';

/// Gidere kısmi ödeme tutarı girmek için dialog.
/// Onaylanırsa int kuruş döner; iptal edilirse null.
Future<int?> showExpensePaymentDialog(
  BuildContext context, {
  required int remainingAmount,
}) async {
  final l10n = AppLocalizations.of(context);
  final ctrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.addPayment),
      content: Form(
        key: formKey,
        child: MoneyInputField(
          controller: ctrl,
          label: l10n.paymentAmount,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return l10n.paymentAmountRequired;
            final n = int.tryParse(v.trim());
            if (n == null || n <= 0) return l10n.paymentAmountInvalid;
            if (MoneyInputField.kurusOf(ctrl) > remainingAmount) {
              return l10n.paymentAmountExceedsRemaining;
            }
            return null;
          },
          textInputAction: TextInputAction.done,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(ctx).pop(MoneyInputField.kurusOf(ctrl));
            }
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}
