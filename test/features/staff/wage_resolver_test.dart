import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/staff/domain/staff.dart';
import 'package:gilanli_meyhane/features/staff/domain/wage_resolver.dart';

void main() {
  group('WageResolver.wageEffectiveOn', () {
    // Başlangıç ücreti (işe alış ücreti = fallback)
    final baseStaff = Staff(
      id: 's1',
      name: 'Ali',
      role: Role.garson,
      dailyWage: 50000, // 500 ₺ — başlangıç/fallback ücreti
      wageHistory: const [],
    );

    test('wageHistory boşsa staff.dailyWage döner', () {
      expect(WageResolver.wageEffectiveOn(baseStaff, DateTime(2024, 1, 15)), 50000);
    });

    test('zam öncesi gün fallback (başlangıç) ücret döner', () {
      // 2024-06-01'de 70000'e zam yapıldı; öncesi hâlâ 50000
      final staff = baseStaff.copyWith(
        wageHistory: [
          WageHistoryEntry(
            effectiveDate: DateTime(2024, 6, 1),
            dailyWage: 70000,
          ),
        ],
      );
      expect(WageResolver.wageEffectiveOn(staff, DateTime(2024, 5, 31)), 50000);
    });

    test('zam günü yeni ücret döner', () {
      final staff = baseStaff.copyWith(
        wageHistory: [
          WageHistoryEntry(
            effectiveDate: DateTime(2024, 6, 1),
            dailyWage: 70000,
          ),
        ],
      );
      expect(WageResolver.wageEffectiveOn(staff, DateTime(2024, 6, 1)), 70000);
    });

    test('zam sonrası gün yeni ücret döner', () {
      final staff = baseStaff.copyWith(
        wageHistory: [
          WageHistoryEntry(
            effectiveDate: DateTime(2024, 6, 1),
            dailyWage: 70000,
          ),
        ],
      );
      expect(WageResolver.wageEffectiveOn(staff, DateTime(2024, 7, 15)), 70000);
    });

    test('birden fazla zamda doğru ücret seçilir', () {
      final staff = baseStaff.copyWith(
        wageHistory: [
          WageHistoryEntry(effectiveDate: DateTime(2024, 3, 1), dailyWage: 60000),
          WageHistoryEntry(effectiveDate: DateTime(2024, 6, 1), dailyWage: 90000),
        ],
      );
      // Ocak 2024: hiç uygun giriş yok → fallback 50000
      expect(WageResolver.wageEffectiveOn(staff, DateTime(2024, 1, 15)), 50000);
      // Nisan 2024: ilk zam geçerli → 60000
      expect(WageResolver.wageEffectiveOn(staff, DateTime(2024, 4, 1)), 60000);
      // Temmuz 2024: ikinci zam geçerli → 90000
      expect(WageResolver.wageEffectiveOn(staff, DateTime(2024, 7, 1)), 90000);
    });

    test('gün içindeki saat farkı sonucu etkilemez', () {
      final staff = baseStaff.copyWith(
        wageHistory: [
          WageHistoryEntry(effectiveDate: DateTime(2024, 6, 1), dailyWage: 70000),
        ],
      );
      // Zam günü saat 23:59 → hâlâ yeni ücret
      expect(WageResolver.wageEffectiveOn(staff, DateTime(2024, 6, 1, 23, 59)), 70000);
    });
  });
}
