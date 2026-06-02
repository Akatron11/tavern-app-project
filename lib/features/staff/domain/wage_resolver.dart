import 'staff.dart';

class WageResolver {
  WageResolver._();

  /// [staff] için [day] tarihinde geçerli günlük ücreti döner (kuruş).
  ///
  /// wageHistory içinde effectiveDate <= day olan en güncel girdi kullanılır.
  /// Hiç uygun girdi yoksa staff.dailyWage (başlangıç ücreti) döner.
  static int wageEffectiveOn(Staff staff, DateTime day) {
    final dayOnly = DateTime(day.year, day.month, day.day);

    WageHistoryEntry? best;
    for (final entry in staff.wageHistory) {
      final entryDay = DateTime(
        entry.effectiveDate.year,
        entry.effectiveDate.month,
        entry.effectiveDate.day,
      );
      if (!entryDay.isAfter(dayOnly)) {
        if (best == null ||
            entryDay.isAfter(DateTime(
              best.effectiveDate.year,
              best.effectiveDate.month,
              best.effectiveDate.day,
            ))) {
          best = entry;
        }
      }
    }

    return best?.dailyWage ?? staff.dailyWage;
  }
}
