import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';
import 'package:gilanli_meyhane/features/payments/domain/payroll_calculator.dart';
import 'package:gilanli_meyhane/features/staff/domain/staff.dart';

DailyRecord _rec(String id, DateTime date, List<String> staffIds) => DailyRecord(
      id: id,
      date: date,
      revenue: 0,
      creditCard: 0,
      tips: 0,
      ownerExpenses: 0,
      cashExpenses: 0,
      creditSales: 0,
      previousDayCash: 0,
      dailyCash: 0,
      totalCash: 0,
      workingStaffIds: staffIds,
    );

Staff _staff(String id, int wage, {List<WageHistoryEntry> history = const []}) =>
    Staff(id: id, name: 'Test $id', role: Role.garson, dailyWage: wage, wageHistory: history);

void main() {
  group('PayrollCalculator.accrue', () {
    test('kayıt yoksa workedDays=0 ve accruedWage=0', () {
      final s = _staff('s1', 100000);
      final result = PayrollCalculator.accrue(s, []);
      expect(result.workedDays, 0);
      expect(result.accruedWage, 0);
      expect(result.staffId, 's1');
      expect(result.staffName, 'Test s1');
    });

    test('3 kayıtta çalışmış personel için 3 günlük ücret', () {
      final s = _staff('s1', 150000);
      final records = [
        _rec('r1', DateTime(2026, 6, 1), ['s1', 's2']),
        _rec('r2', DateTime(2026, 6, 2), ['s1']),
        _rec('r3', DateTime(2026, 6, 3), ['s1', 's3']),
      ];
      final result = PayrollCalculator.accrue(s, records);
      expect(result.workedDays, 3);
      expect(result.accruedWage, 450000); // 3 × 150000
    });

    test('personel çalışmadığı günler sayılmaz', () {
      final s = _staff('s1', 200000);
      final records = [
        _rec('r1', DateTime(2026, 6, 1), ['s2']),
        _rec('r2', DateTime(2026, 6, 2), ['s1']),
        _rec('r3', DateTime(2026, 6, 3), ['s2', 's3']),
      ];
      final result = PayrollCalculator.accrue(s, records);
      expect(result.workedDays, 1);
      expect(result.accruedWage, 200000);
    });

    test('ücret zammı aralığın ortasındaysa öncesi eski, sonrası yeni ücret', () {
      // Zam 4 Haziran'dan itibaren geçerli
      final history = [WageHistoryEntry(effectiveDate: DateTime(2026, 6, 4), dailyWage: 200000)];
      final s = _staff('s1', 100000, history: history);
      final records = [
        _rec('r1', DateTime(2026, 6, 1), ['s1']), // 100000 (eski)
        _rec('r2', DateTime(2026, 6, 3), ['s1']), // 100000 (zam öncesi)
        _rec('r3', DateTime(2026, 6, 4), ['s1']), // 200000 (zam günü)
        _rec('r4', DateTime(2026, 6, 5), ['s1']), // 200000 (zam sonrası)
      ];
      final result = PayrollCalculator.accrue(s, records);
      expect(result.workedDays, 4);
      expect(result.accruedWage, 600000); // 2×100000 + 2×200000
    });

    test('boş workingStaffIds olan kayıt sayılmaz', () {
      final s = _staff('s1', 100000);
      final records = [
        _rec('r1', DateTime(2026, 6, 1), []),
        _rec('r2', DateTime(2026, 6, 2), ['s2']),
      ];
      final result = PayrollCalculator.accrue(s, records);
      expect(result.workedDays, 0);
      expect(result.accruedWage, 0);
    });
  });
}
