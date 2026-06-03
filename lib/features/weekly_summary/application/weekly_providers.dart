import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../shared/providers/firebase_providers.dart';
import '../../daily_record/application/daily_record_providers.dart';
import '../../daily_record/domain/daily_record.dart';
import '../../staff/application/staff_providers.dart';
import '../../staff/domain/staff.dart';
import '../data/firestore_tip_distribution_repository.dart';
import '../data/tip_distribution_repository.dart';
import '../domain/tip_distribution.dart';

/// Hafta navigasyon ofseti: 0 = bu hafta, -1 = geçen hafta, vb.
final weekOffsetProvider =
    NotifierProvider<WeekOffsetNotifier, int>(WeekOffsetNotifier.new);

class WeekOffsetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void previous() => state = state - 1;
  void next() => state = state + 1;
}

/// Offset'e göre hesaplanan haftanın aralığı.
final currentWeekRangeProvider = Provider<DateRange>((ref) {
  final offset = ref.watch(weekOffsetProvider);
  final base = DateTime.now();
  final shifted = DateTime(base.year, base.month, base.day + offset * 7);
  return weekRange(shifted);
});

/// Mevcut haftanın günlük kayıtları.
final weeklyRecordsProvider = FutureProvider<List<DailyRecord>>((ref) async {
  final range = ref.watch(currentWeekRangeProvider);
  return ref.watch(dailyRecordRepositoryProvider).getByDateRange(range);
});

/// Bahşiş dağıtımları repo provider'ı.
final tipDistributionRepositoryProvider =
    Provider<TipDistributionRepository>((ref) {
  return FirestoreTipDistributionRepository(ref.watch(firestoreProvider));
});

/// Tüm bahşiş dağıtımları.
final allTipDistributionsProvider =
    FutureProvider<List<TipDistribution>>((ref) async {
  return ref.watch(tipDistributionRepositoryProvider).getAll();
});

/// Tüm günlük kayıtlar (açık bahşiş hesabı için).
final allDailyRecordsProvider =
    FutureProvider<List<DailyRecord>>((ref) async {
  return ref.watch(dailyRecordRepositoryProvider).getAll();
});

/// Son dağıtımdan bu yana birikmiş bahşiş toplamı.
/// Son dağıtım yoksa tüm kayıtların bahşiş toplamı.
final openTipsProvider = FutureProvider<int>((ref) async {
  final distributions = await ref.watch(allTipDistributionsProvider.future);
  final allRecords = await ref.watch(allDailyRecordsProvider.future);

  if (distributions.isEmpty) {
    return allRecords.fold<int>(0, (s, r) => s + r.tips);
  }

  final lastDistDate = distributions
      .map((d) => d.date)
      .reduce((a, b) => a.isAfter(b) ? a : b);

  return allRecords
      .where((r) => r.date.isAfter(lastDistDate))
      .fold<int>(0, (s, r) => s + r.tips);
});

/// Mevcut haftada çalışan personel ve kaç gün çalıştıkları.
final weeklyStaffDaysProvider =
    FutureProvider<List<({Staff staff, int days})>>((ref) async {
  final records = await ref.watch(weeklyRecordsProvider.future);
  final allStaff = await ref.watch(allStaffProvider.future);

  final dayCounts = <String, int>{};
  for (final record in records) {
    for (final id in record.workingStaffIds) {
      dayCounts[id] = (dayCounts[id] ?? 0) + 1;
    }
  }

  final result = allStaff
      .where((s) => dayCounts.containsKey(s.id))
      .map((s) => (staff: s, days: dayCounts[s.id]!))
      .toList()
    ..sort((a, b) => b.days.compareTo(a.days));

  return result;
});

/// Bahşiş dağıtım controller'ı.
final tipDistributionControllerProvider =
    AsyncNotifierProvider<TipDistributionController, void>(
        TipDistributionController.new);

class TipDistributionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Açık bahşişi dağıtılmış olarak kaydeder.
  Future<void> distribute({
    required int amount,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(tipDistributionRepositoryProvider).add(
            TipDistribution(
              id: '',
              date: DateTime.now(),
              amount: amount,
              periodStart: periodStart,
              periodEnd: periodEnd,
            ),
          );
      ref.invalidate(allTipDistributionsProvider);
      ref.invalidate(allDailyRecordsProvider);
    });
  }
}
