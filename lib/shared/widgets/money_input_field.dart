import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/money/money.dart';

/// Tam **lira** girişi alan, binlik ayraçlı (yerel biçim) para alanı.
///
/// Saklama kuruş bazlıdır; [kurusOf] ile kuruş değeri okunur (ayraçlar yok
/// sayılır). Hem kullanıcı yazarken hem de programatik olarak (örn. düzenlemede
/// yüklenen) ayarlanan değerler yerel binlik ayracıyla gruplanır (BUG-15).
class MoneyInputField extends StatefulWidget {
  const MoneyInputField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  /// Yalnızca rakamları alıp kuruşa çevirir (binlik ayraçları yok sayar).
  static int kurusOf(TextEditingController controller) {
    final digits = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    return liraToKurus(int.tryParse(digits) ?? 0);
  }

  /// Validator yardımcısı: ayraçlı metni lira tamsayısına çevirir
  /// (örn. "6.000" → 6000). Boş/geçersizse `null`.
  /// Validator'lar ham `int.tryParse(v)` yapmamalı (ayraç parse'ı bozar).
  static int? liraValue(String? text) {
    final digits = (text ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  @override
  State<MoneyInputField> createState() => _MoneyInputFieldState();
}

class _MoneyInputFieldState extends State<MoneyInputField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_reformat);
    // İlk frame sonrası mevcut (programatik) değeri grupla.
    WidgetsBinding.instance.addPostFrameCallback((_) => _reformat());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_reformat);
    super.dispose();
  }

  /// Controller metnindeki rakamları yerel binlik ayracıyla yeniden gruplar.
  /// Sonuç mevcut metinle aynıysa hiçbir şey yapmaz (özyineleme önlenir).
  void _reformat() {
    if (!mounted) return;
    final text = widget.controller.text;
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    final grouped = digits.isEmpty
        ? ''
        : NumberFormat.decimalPattern(
                Localizations.localeOf(context).toString())
            .format(int.parse(digits));
    if (grouped != text) {
      widget.controller.value = TextEditingValue(
        text: grouped,
        selection: TextSelection.collapsed(offset: grouped.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixText: '₺',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
