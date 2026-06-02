import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/utils/date_utils.dart';

void main() {
  group('isSameDay', () {
    test('aynı gün, farklı saat -> true', () {
      expect(
        isSameDay(DateTime(2026, 6, 2, 9), DateTime(2026, 6, 2, 23, 59)),
        isTrue,
      );
    });
    test('farklı gün -> false', () {
      expect(isSameDay(DateTime(2026, 6, 2), DateTime(2026, 6, 3)), isFalse);
    });
  });

  group('dayKey', () {
    test('yyyy-MM-dd, sıfır dolgulu', () {
      expect(dayKey(DateTime(2026, 6, 2, 14, 30)), '2026-06-02');
      expect(dayKey(DateTime(2026, 12, 9)), '2026-12-09');
    });
  });

  group('weekRange (Pazartesi başlangıç, bitiş hariç)', () {
    test('Salı için o haftanın Pazartesi-gelecek Pazartesi aralığı', () {
      // 2026-06-01 Pazartesi, 2026-06-02 Salı.
      final r = weekRange(DateTime(2026, 6, 2, 15));
      expect(r.start, DateTime(2026, 6, 1));
      expect(r.end, DateTime(2026, 6, 8));
    });
    test('Pazar günü aynı haftaya ait', () {
      // 2026-06-07 Pazar
      final r = weekRange(DateTime(2026, 6, 7, 23, 59));
      expect(r.start, DateTime(2026, 6, 1));
      expect(r.end, DateTime(2026, 6, 8));
    });
    test('Pazartesi günü kendi haftasının başıdır', () {
      final r = weekRange(DateTime(2026, 6, 1));
      expect(r.start, DateTime(2026, 6, 1));
      expect(r.end, DateTime(2026, 6, 8));
    });
  });

  group('monthRange (bitiş hariç)', () {
    test('ay başından gelecek ay başına', () {
      final r = monthRange(DateTime(2026, 6, 15));
      expect(r.start, DateTime(2026, 6, 1));
      expect(r.end, DateTime(2026, 7, 1));
    });
    test('Aralık -> gelecek yıl Ocak', () {
      final r = monthRange(DateTime(2026, 12, 20));
      expect(r.start, DateTime(2026, 12, 1));
      expect(r.end, DateTime(2027, 1, 1));
    });
  });
}
