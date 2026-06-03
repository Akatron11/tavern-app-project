import '../domain/daily_record.dart';

abstract class DailyRecordRepository {
  /// `dayKey` (yyyy-MM-dd) ile o günün kaydını getirir; yoksa `null`.
  Future<DailyRecord?> getByDay(String dayKey);

  /// Kaydı `dayKey` doküman kimliğiyle upsert eder (ekle veya güncelle).
  Future<void> save(DailyRecord record);

  /// Tüm günlük kayıtları getirir (personel tahakkuku hesabı için).
  Future<List<DailyRecord>> getAll();
}
