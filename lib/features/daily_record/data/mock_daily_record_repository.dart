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
}
