import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/money/money.dart';

/// Tam **lira** girişi alan, yalnızca rakam kabul eden para alanı.
/// Saklama kuruş bazlıdır; [kurusOf] ile kuruş değeri okunur.
class MoneyInputField extends StatelessWidget {
  const MoneyInputField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  /// Alandaki tam lira değerini kuruşa çevirir (boş/eksikse 0).
  static int kurusOf(TextEditingController controller) =>
      liraToKurus(int.tryParse(controller.text.trim()) ?? 0);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: '₺',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: textInputAction,
      onChanged: onChanged,
    );
  }
}
