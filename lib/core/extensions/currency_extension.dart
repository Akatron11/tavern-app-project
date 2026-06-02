import '../money/currency_formatter.dart';

/// `int` (kuruş) değerlerini para biçimine çevirmek için kısayol.
///
/// Örn. `100000.toCurrency()` → `'1.000 ₺'`.
extension CurrencyFormatting on int {
  String toCurrency([String locale = 'tr']) =>
      formatCurrency(this, locale: locale);
}
