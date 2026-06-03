import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/monthly_summary/domain/monthly_report_calculator.dart';

void main() {
  group('MonthlyReportCalculator.monthlyProfit', () {
    test('normal kâr hesabı', () {
      final result = MonthlyReportCalculator.monthlyProfit(
        revenue: 1000000,
        creditCard: 300000,
        cashExpenses: 50000,
        ownerExpenses: 20000,
        staffWages: 200000,
        uncollectibleCredit: 100000,
      );
      // 1_000_000 − 300_000 − (50_000 + 20_000) − 200_000 − 100_000 = 330_000
      expect(result, 330000);
    });

    test('tüm sıfır → 0', () {
      expect(
        MonthlyReportCalculator.monthlyProfit(
          revenue: 0,
          creditCard: 0,
          cashExpenses: 0,
          ownerExpenses: 0,
          staffWages: 0,
          uncollectibleCredit: 0,
        ),
        0,
      );
    });

    test('zarar durumu — negatif sonuç döner', () {
      final result = MonthlyReportCalculator.monthlyProfit(
        revenue: 100000,
        creditCard: 0,
        cashExpenses: 50000,
        ownerExpenses: 20000,
        staffWages: 100000,
        uncollectibleCredit: 50000,
      );
      // 100_000 − 0 − (50_000 + 20_000) − 100_000 − 50_000 = −120_000
      expect(result, -120000);
    });

    test('patron masrafı kâra dahil edilir (günlük kasadan farklı)', () {
      final withoutOwner = MonthlyReportCalculator.monthlyProfit(
        revenue: 500000,
        creditCard: 0,
        cashExpenses: 0,
        ownerExpenses: 0,
        staffWages: 0,
        uncollectibleCredit: 0,
      );
      final withOwner = MonthlyReportCalculator.monthlyProfit(
        revenue: 500000,
        creditCard: 0,
        cashExpenses: 0,
        ownerExpenses: 100000,
        staffWages: 0,
        uncollectibleCredit: 0,
      );
      expect(withoutOwner, 500000);
      expect(withOwner, 400000);
    });

    test('tahsil edilemeyen veresiye kârdan düşülür', () {
      final result = MonthlyReportCalculator.monthlyProfit(
        revenue: 500000,
        creditCard: 0,
        cashExpenses: 0,
        ownerExpenses: 0,
        staffWages: 0,
        uncollectibleCredit: 200000,
      );
      expect(result, 300000);
    });
  });
}
