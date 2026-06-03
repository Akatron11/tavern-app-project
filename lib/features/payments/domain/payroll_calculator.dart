import '../../daily_record/domain/daily_record.dart';
import '../../staff/domain/staff.dart';
import '../../staff/domain/wage_resolver.dart';
import 'payroll_summary.dart';

class PayrollCalculator {
  PayrollCalculator._();

  /// [staff] için [records] listesindeki çalışma tahakkukunu hesaplar.
  /// workedDays = staff.id'nin workingStaffIds içinde olduğu kayıt sayısı.
  /// accruedWage = o günlere ait wageEffectiveOn toplamı.
  static PayrollSummary accrue(Staff staff, List<DailyRecord> records) {
    int days = 0;
    int wage = 0;
    for (final r in records) {
      if (r.workingStaffIds.contains(staff.id)) {
        days++;
        wage += WageResolver.wageEffectiveOn(staff, r.date);
      }
    }
    return PayrollSummary(
      staffId: staff.id,
      staffName: staff.name,
      workedDays: days,
      accruedWage: wage,
    );
  }
}
