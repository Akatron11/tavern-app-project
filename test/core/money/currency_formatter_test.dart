import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/money/currency_formatter.dart';
import 'package:gilanli_meyhane/core/extensions/currency_extension.dart';

void main() {
  group('formatCurrency (Türkçe varsayılan)', () {
    test('binlik ayracı nokta, sonuna ₺', () {
      expect(formatCurrency(1250000), '12.500 ₺'); // 12500 ₺
      expect(formatCurrency(100000), '1.000 ₺'); // 1000 ₺
      expect(formatCurrency(0), '0 ₺');
    });

    test('negatif tutar işareti korur', () {
      expect(formatCurrency(-100000), '-1.000 ₺');
    });

    test('kuruş artığı gösterilmez (tam lira)', () {
      expect(formatCurrency(100050), '1.000 ₺');
    });
  });

  group('formatCurrency (İngilizce)', () {
    test('binlik ayracı virgül', () {
      expect(formatCurrency(100000, locale: 'en'), '1,000 ₺');
      expect(formatCurrency(1250000, locale: 'en'), '12,500 ₺');
    });
  });

  group('int.toCurrency uzantısı', () {
    test('formatCurrency ile aynı sonucu verir', () {
      expect(100000.toCurrency(), '1.000 ₺');
      expect(100000.toCurrency('en'), '1,000 ₺');
    });
  });
}
