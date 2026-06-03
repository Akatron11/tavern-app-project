import '../../../core/utils/date_utils.dart';
import '../domain/daily_record.dart';
import 'daily_record_repository.dart';

class MockDailyRecordRepository implements DailyRecordRepository {
  final Map<String, DailyRecord> store = {};

  @override
  Future<DailyRecord?> getByDay(String dayKey) async => store[dayKey];

  @override
  Future<void> save(DailyRecord record) async {
    store[record.id] = record;
  }

  @override
  Future<List<DailyRecord>> getAll() async => store.values.toList();

  @override
  Future<List<DailyRecord>> getByDateRange(DateRange range) async {
    return store.values
        .where((r) =>
            !r.date.isBefore(range.start) && r.date.isBefore(range.end))
        .toList();
  }
}
