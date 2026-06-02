import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/firebase_providers.dart';
import '../data/firestore_staff_repository.dart';
import '../data/staff_repository.dart';
import '../domain/staff.dart';
import '../domain/wage_resolver.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return FirestoreStaffRepository(ref.watch(firestoreProvider));
});

/// Tüm personel (aktif + pasif)
final allStaffProvider = StreamProvider<List<Staff>>((ref) {
  return ref.watch(staffRepositoryProvider).watchAll();
});

/// Yalnızca aktif personel (günlük kayıt ekranı için)
final activeStaffProvider = StreamProvider<List<Staff>>((ref) {
  return ref.watch(staffRepositoryProvider).watchActive();
});

/// Tek bir personel (id ile)
final staffByIdProvider = FutureProvider.family<Staff?, String>((ref, id) {
  return ref.watch(staffRepositoryProvider).getById(id);
});

// ---------------------------------------------------------------------------
// StaffController — ekle / düzenle / pasifle / sil
// ---------------------------------------------------------------------------

final staffControllerProvider =
    AsyncNotifierProvider<StaffController, void>(StaffController.new);

class StaffController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  StaffRepository get _repo => ref.read(staffRepositoryProvider);

  Future<void> addStaff(Staff staff) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.add(staff));
  }

  /// Ücret değişmişse wageHistory'ye yeni giriş ekler.
  Future<void> updateStaff(Staff updated, Staff original) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      Staff toSave = updated;
      if (updated.dailyWage != original.dailyWage) {
        final entry = WageHistoryEntry(
          effectiveDate: DateTime.now(),
          dailyWage: updated.dailyWage,
        );
        toSave = updated.copyWith(
          wageHistory: [...original.wageHistory, entry],
        );
      }
      await _repo.update(toSave);
    });
  }

  Future<void> deactivateStaff(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.deactivate(id));
  }

  Future<void> deleteStaff(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.delete(id));
  }
}

/// Belirli bir tarih için personelin günlük ücretini hesaplar
int resolveWage(Staff staff, DateTime day) =>
    WageResolver.wageEffectiveOn(staff, day);
