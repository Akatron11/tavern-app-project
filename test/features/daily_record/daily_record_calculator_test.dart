import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record_calculator.dart';

void main() {
  group('DailyRecordCalculator.dailyCash', () {
    test('spec örneği: karışık değerler (patron masrafı hariç)', () {
      final cash = DailyRecordCalculator.dailyCash(
        revenue: 1000000,
        creditCard: 300000,
        tips: 50000,
        cashExpenses: 30000,
        creditSales: 100000,
      );
      expect(cash, 620000);
    });

    test('tüm değerler sıfır -> 0', () {
      expect(
        DailyRecordCalculator.dailyCash(
          revenue: 0,
          creditCard: 0,
          tips: 0,
          cashExpenses: 0,
          creditSales: 0,
        ),
        0,
      );
    });

    test('kredi kartı ciroyu aşarsa günlük kasa negatif olabilir', () {
      expect(
        DailyRecordCalculator.dailyCash(
          revenue: 500000,
          creditCard: 600000,
          tips: 0,
          cashExpenses: 0,
          creditSales: 0,
        ),
        -100000,
      );
    });

    test('formül patron masrafını içermez; yalnızca kasa masrafı düşülür', () {
      // ownerExpenses bilinçli olarak parametre DEĞİL.
      final cash = DailyRecordCalculator.dailyCash(
        revenue: 500000,
        creditCard: 0,
        tips: 0,
        cashExpenses: 10000,
        creditSales: 0,
      );
      expect(cash, 490000);
    });

    test('bahşiş günlük kasaya eklenir', () {
      expect(
        DailyRecordCalculator.dailyCash(
          revenue: 100000,
          creditCard: 0,
          tips: 25000,
          cashExpenses: 0,
          creditSales: 0,
        ),
        125000,
      );
    });

    test('veresiye günlük kasadan düşülür', () {
      expect(
        DailyRecordCalculator.dailyCash(
          revenue: 100000,
          creditCard: 0,
          tips: 0,
          cashExpenses: 0,
          creditSales: 40000,
        ),
        60000,
      );
    });
  });

  group('DailyRecordCalculator.totalCash', () {
    test('dünden kalan + günlük kasa', () {
      expect(DailyRecordCalculator.totalCash(200000, 620000), 820000);
    });

    test('negatif günlük kasa ile toplam', () {
      expect(DailyRecordCalculator.totalCash(0, -100000), -100000);
    });
  });

  group('DailyRecordCalculator.totalExpensesDisplay', () {
    test('kasa + patron masrafı toplamı (yalnızca gösterim)', () {
      expect(DailyRecordCalculator.totalExpensesDisplay(20000, 30000), 50000);
    });
  });
}
