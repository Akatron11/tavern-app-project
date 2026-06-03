import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../daily_record/application/daily_record_providers.dart';
import '../../daily_record/domain/daily_record.dart';

/// Bugünün günlük kaydını çeker; yoksa `null` döner.
final todayRecordProvider = FutureProvider<DailyRecord?>((ref) {
  final repo = ref.watch(dailyRecordRepositoryProvider);
  return repo.getByDay(dayKey(DateTime.now()));
});
