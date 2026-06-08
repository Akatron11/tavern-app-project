import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/utils/date_utils.dart';
import 'package:gilanli_meyhane/features/credit_book/application/credit_book_providers.dart';
import 'package:gilanli_meyhane/features/credit_book/data/mock_credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';
import 'package:gilanli_meyhane/features/daily_record/application/daily_record_providers.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record_calculator.dart';
import 'package:gilanli_meyhane/features/monthly_summary/application/monthly_providers.dart';
import 'package:gilanli_meyhane/features/staff/application/staff_providers.dart';
import 'package:gilanli_meyhane/features/staff/data/mock_staff_repository.dart';

DailyRecord _makeRecord(DateTime date,
    {int revenue = 100000,
    int creditCard = 0,
    int cashExpenses = 0,
    int ownerExpenses = 0}) {
  final daily = DailyRecordCalculator.dailyCash(
    revenue: revenue,
    creditCard: creditCard,
    tips: 0,
    cashExpenses: cashExpenses,
    creditSales: 0,
  );
  return DailyRecord(
    id: dayKey(date),
    date: date,
    revenue: revenue,
    creditCard: creditCard,
    tips: 0,
    ownerExpenses: ownerExpenses,
    cashExpenses: cashExpenses,
    creditSales: 0,
    previousDayCash: 0,
    dailyCash: daily,
    totalCash: daily,
  );
}

ProviderContainer _makeContainer({
  MockDailyRecordRepository? dailyRepo,
  MockCreditSaleRepository? creditRepo,
  MockStaffRepository? staffRepo,
}) {
  return ProviderContainer(overrides: [
    dailyRecordRepositoryProvider
        .overrideWithValue(dailyRepo ?? MockDailyRecordRepository()),
    creditSaleRepositoryProvider
        .overrideWithValue(creditRepo ?? MockCreditSaleRepository()),
    staffRepositoryProvider
        .overrideWithValue(staffRepo ?? MockStaffRepository()),
  ]);
}

void main() {
  group('MonthOffsetNotifier', () {
    test('başlangıç değeri 0', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      expect(c.read(monthOffsetProvider), 0);
    });

    test('previous() → -1', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      c.read(monthOffsetProvider.notifier).previous();
      expect(c.read(monthOffsetProvider), -1);
    });

    test('previous() + next() → 0', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      c.read(monthOffsetProvider.notifier).previous();
      c.read(monthOffsetProvider.notifier).next();
      expect(c.read(monthOffsetProvider), 0);
    });
  });

  group('monthlyReportProvider', () {
    test('kayıt yoksa tüm değerler 0', () async {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final report = await c.read(monthlyReportProvider.future);
      expect(report.revenue, 0);
      expect(report.profit, 0);
    });

    test('ay içindeki kayıtlar doğru toplanır', () async {
      final dailyRepo = MockDailyRecordRepository();
      final now = DateTime.now();
      final rec = _makeRecord(
        DateTime(now.year, now.month, 1),
        revenue: 500000,
        creditCard: 100000,
        cashExpenses: 30000,
        ownerExpenses: 20000,
      );
      dailyRepo.store[rec.id] = rec;

      final c = _makeContainer(dailyRepo: dailyRepo);
      addTearDown(c.dispose);

      final report = await c.read(monthlyReportProvider.future);
      expect(report.revenue, 500000);
      expect(report.creditCard, 100000);
      expect(report.cashExpenses, 30000);
      expect(report.ownerExpenses, 20000);
      // profit (BUG-09, kredi kartı düşülmez): 500000 - (30000 + 20000) - 0 - 0 = 450000
      expect(report.profit, 450000);
    });
  });

  group('BUG-10/11 — tahsil bekleyen + reaktivite', () {
    test('outstandingCredit yalnızca pending+partial sayar (paid hariç)',
        () async {
      final creditRepo = MockCreditSaleRepository();
      final now = DateTime.now();
      DateTime d(int day) => DateTime(now.year, now.month, day);
      await creditRepo.add(CreditSale(
          id: '',
          customerName: 'P',
          totalAmount: 100000,
          remainingAmount: 100000,
          date: d(2),
          status: CreditStatus.pending));
      await creditRepo.add(CreditSale(
          id: '',
          customerName: 'Q',
          totalAmount: 60000,
          remainingAmount: 20000,
          date: d(3),
          status: CreditStatus.partial));
      await creditRepo.add(CreditSale(
          id: '',
          customerName: 'R',
          totalAmount: 50000,
          remainingAmount: 0,
          date: d(4),
          status: CreditStatus.paid));

      final c = _makeContainer(creditRepo: creditRepo);
      addTearDown(c.dispose);

      final report = await c.read(monthlyReportProvider.future);
      expect(report.outstandingCredit, 160000); // pending+partial; paid hariç
      expect(report.uncollectibleCredit, 120000); // Σ remaining
    });

    test('BUG-10: tam ödeme sonrası tahsil bekleyen reaktif 0 olur', () async {
      final creditRepo = MockCreditSaleRepository();
      final now = DateTime.now();
      final id = await creditRepo.add(CreditSale(
          id: '',
          customerName: 'A',
          totalAmount: 100000,
          remainingAmount: 100000,
          date: DateTime(now.year, now.month, 5),
          status: CreditStatus.pending));

      final c = _makeContainer(creditRepo: creditRepo);
      addTearDown(c.dispose);
      final sub = c.listen(monthlyReportProvider, (_, _) {});
      addTearDown(sub.close);

      var report = await c.read(monthlyReportProvider.future);
      expect(report.outstandingCredit, 100000);

      await c.read(creditBookControllerProvider.notifier).markPaid(id);
      await pumpEventQueue();

      report = await c.read(monthlyReportProvider.future);
      expect(report.outstandingCredit, 0);
    });
  });
}
