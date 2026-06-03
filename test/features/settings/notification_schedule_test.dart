import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/settings/domain/notification_schedule.dart';

void main() {
  group('nextInstanceOfTime', () {
    test('hedef saat bugün ileride ise bugünü döner', () {
      final now = DateTime(2026, 6, 3, 10, 0);
      final result = nextInstanceOfTime(hour: 21, minute: 0, now: now);
      expect(result, DateTime(2026, 6, 3, 21, 0));
    });

    test('hedef saat bugün geçmişte ise yarını döner', () {
      final now = DateTime(2026, 6, 3, 22, 0);
      final result = nextInstanceOfTime(hour: 21, minute: 0, now: now);
      expect(result, DateTime(2026, 6, 4, 21, 0));
    });

    test('hedef saat tam şu an ise yarını döner (geçmiş sayılır)', () {
      final now = DateTime(2026, 6, 3, 21, 0);
      final result = nextInstanceOfTime(hour: 21, minute: 0, now: now);
      expect(result, DateTime(2026, 6, 4, 21, 0));
    });
  });
}
