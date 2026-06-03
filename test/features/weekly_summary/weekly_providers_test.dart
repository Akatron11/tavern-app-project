import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/utils/date_utils.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record_calculator.dart';

DailyRecord _makeRecord(DateTime date, {int revenue = 100000}) {
  final daily = DailyRecordCalculator.dailyCash(
    revenue: revenue,
    creditCard: 0,
    tips: 0,
    cashExpenses: 0,
    creditSales: 0,
  );
  return DailyRecord(
    id: dayKey(date),
    date: date,
    revenue: revenue,
    creditCard: 0,
    tips: 0,
    ownerExpenses: 0,
    cashExpenses: 0,
    creditSales: 0,
    previousDayCash: 0,
    dailyCash: daily,
    totalCash: daily,
  );
}

void main() {
  group('MockDailyRecordRepository.getByDateRange', () {
    late MockDailyRecordRepository repo;

    setUp(() {
      repo = MockDailyRecordRepository();
    });

    test('aralık içindeki kayıtları döner', () async {
      final r1 = _makeRecord(DateTime(2026, 6, 2)); // Pazartesi
      final r2 = _makeRecord(DateTime(2026, 6, 3)); // Salı
      final r3 = _makeRecord(DateTime(2026, 6, 9)); // Gelecek Pazartesi (hariç)
      repo.store[r1.id] = r1;
      repo.store[r2.id] = r2;
      repo.store[r3.id] = r3;

      final range = (
        start: DateTime(2026, 6, 2),
        end: DateTime(2026, 6, 9),
      );
      final result = await repo.getByDateRange(range);

      expect(result.length, 2);
      expect(result.any((r) => r.id == r1.id), isTrue);
      expect(result.any((r) => r.id == r2.id), isTrue);
      expect(result.any((r) => r.id == r3.id), isFalse);
    });

    test('aralık öncesindeki kayıtları döndürmez', () async {
      final r1 = _makeRecord(DateTime(2026, 6, 1)); // aralık öncesi
      repo.store[r1.id] = r1;

      final range = (
        start: DateTime(2026, 6, 2),
        end: DateTime(2026, 6, 9),
      );
      final result = await repo.getByDateRange(range);

      expect(result, isEmpty);
    });

    test('boş store için boş liste döner', () async {
      final range = (
        start: DateTime(2026, 6, 2),
        end: DateTime(2026, 6, 9),
      );
      final result = await repo.getByDateRange(range);
      expect(result, isEmpty);
    });
  });
}
