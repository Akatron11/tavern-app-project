import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../credit_book/application/credit_book_providers.dart';
import '../../credit_book/domain/credit_sale.dart';
import '../../daily_record/application/daily_record_providers.dart';
import '../../daily_record/domain/daily_record.dart';
import '../../payments/domain/payroll_calculator.dart';
import '../../staff/application/staff_providers.dart';
import '../domain/monthly_report.dart';
import '../domain/monthly_report_calculator.dart';

/// Ay navigasyon ofseti: 0 = bu ay, -1 = geçen ay, vb.
final monthOffsetProvider =
    NotifierProvider<MonthOffsetNotifier, int>(MonthOffsetNotifier.new);

class MonthOffsetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void previous() => state = state - 1;
  void next() => state = state + 1;
}

/// Offset'e göre hesaplanan ayın aralığı.
final currentMonthRangeProvider = Provider<DateRange>((ref) {
  final offset = ref.watch(monthOffsetProvider);
  final base = DateTime.now();
  final shifted = DateTime(base.year, base.month + offset, 1);
  return monthRange(shifted);
});

/// Mevcut ayın günlük kayıtları.
final monthlyRecordsProvider = FutureProvider<List<DailyRecord>>((ref) async {
  final range = ref.watch(currentMonthRangeProvider);
  return ref.watch(dailyRecordRepositoryProvider).getByDateRange(range);
});

/// Mevcut ayın veresiye kayıtları.
final monthlyCreditSalesProvider =
    FutureProvider<List<CreditSale>>((ref) async {
  final range = ref.watch(currentMonthRangeProvider);
  return ref.watch(creditSaleRepositoryProvider).getByDateRange(range);
});

/// Mevcut ay için tüm personelin toplam tahakkuk ücreti.
final monthlyStaffWagesProvider = FutureProvider<int>((ref) async {
  final records = await ref.watch(monthlyRecordsProvider.future);
  final allStaff = await ref.watch(allStaffProvider.future);
  return allStaff.fold<int>(
      0, (sum, s) => sum + PayrollCalculator.accrue(s, records).accruedWage);
});

/// Aylık özet raporu (tüm kartların verisi).
final monthlyReportProvider = FutureProvider<MonthlyReport>((ref) async {
  final records = await ref.watch(monthlyRecordsProvider.future);
  final credits = await ref.watch(monthlyCreditSalesProvider.future);
  final staffWages = await ref.watch(monthlyStaffWagesProvider.future);

  final revenue = records.fold<int>(0, (s, r) => s + r.revenue);
  final creditCard = records.fold<int>(0, (s, r) => s + r.creditCard);
  final cashExpenses = records.fold<int>(0, (s, r) => s + r.cashExpenses);
  final ownerExpenses = records.fold<int>(0, (s, r) => s + r.ownerExpenses);
  final creditSalesTotal =
      credits.fold<int>(0, (s, c) => s + c.totalAmount);
  final uncollectible =
      credits.fold<int>(0, (s, c) => s + c.remainingAmount);

  final profit = MonthlyReportCalculator.monthlyProfit(
    revenue: revenue,
    cashExpenses: cashExpenses,
    ownerExpenses: ownerExpenses,
    staffWages: staffWages,
    uncollectibleCredit: uncollectible,
  );

  return MonthlyReport(
    revenue: revenue,
    creditCard: creditCard,
    cashExpenses: cashExpenses,
    ownerExpenses: ownerExpenses,
    staffWages: staffWages,
    creditSalesTotal: creditSalesTotal,
    uncollectibleCredit: uncollectible,
    profit: profit,
  );
});
