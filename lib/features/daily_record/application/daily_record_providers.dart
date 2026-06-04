import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../shared/providers/firebase_providers.dart';
import '../../credit_book/application/credit_book_providers.dart';
import '../../credit_book/data/credit_sale_repository.dart';
import '../../credit_book/domain/credit_reconciler.dart';
import '../../credit_book/domain/credit_sale.dart';
import '../data/daily_record_repository.dart';
import '../data/firestore_daily_record_repository.dart';
import '../domain/daily_record.dart';
import '../domain/daily_record_calculator.dart';

final dailyRecordRepositoryProvider = Provider<DailyRecordRepository>((ref) {
  return FirestoreDailyRecordRepository(ref.watch(firestoreProvider));
});

final dailyRecordControllerProvider =
    AsyncNotifierProvider<DailyRecordController, void>(DailyRecordController.new);

class DailyRecordController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  DailyRecordRepository get _dailyRepo =>
      ref.read(dailyRecordRepositoryProvider);
  CreditSaleRepository get _creditRepo =>
      ref.read(creditSaleRepositoryProvider);

  /// Günlük kaydı kaydeder (upsert), veresiyeyi `creditSales`'e yansıtır.
  /// Patron masrafı kasayı etkilemez (DailyRecordCalculator).
  Future<void> saveRecord({
    required DateTime date,
    required int revenue,
    required int creditCard,
    required int tips,
    required int ownerExpenses,
    required int cashExpenses,
    required int creditSales,
    required String creditCustomerName,
    required int previousDayCash,
    required List<String> workingStaffIds,
    required String notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final day = DateTime(date.year, date.month, date.day);
      final key = dayKey(day);

      final existing = await _dailyRepo.getByDay(key);
      final linkedId = await _syncCreditSale(
        existingLinkedId: existing?.linkedCreditSaleId,
        day: day,
        key: key,
        creditSales: creditSales,
        customerName: creditCustomerName,
      );

      final daily = DailyRecordCalculator.dailyCash(
        revenue: revenue,
        creditCard: creditCard,
        tips: tips,
        cashExpenses: cashExpenses,
        creditSales: creditSales,
      );
      final total = DailyRecordCalculator.totalCash(previousDayCash, daily);

      await _dailyRepo.save(DailyRecord(
        id: key,
        date: day,
        revenue: revenue,
        creditCard: creditCard,
        tips: tips,
        ownerExpenses: ownerExpenses,
        cashExpenses: cashExpenses,
        creditSales: creditSales,
        creditCustomerName: creditCustomerName,
        previousDayCash: previousDayCash,
        dailyCash: daily,
        totalCash: total,
        workingStaffIds: workingStaffIds,
        linkedCreditSaleId: linkedId,
        notes: notes,
      ));
    });
  }

  /// Bağlı veresiyeyi oluşturur/mutabık kılar; güncel `linkedCreditSaleId` döner.
  Future<String?> _syncCreditSale({
    required String? existingLinkedId,
    required DateTime day,
    required String key,
    required int creditSales,
    required String customerName,
  }) async {
    if (creditSales > 0) {
      if (existingLinkedId != null) {
        final sale = await _creditRepo.getById(existingLinkedId);
        if (sale != null) {
          final updated = CreditReconciler.reconcile(
            sale.copyWith(customerName: customerName),
            newTotal: creditSales,
          );
          await _creditRepo.update(updated);
          return existingLinkedId;
        }
      }
      // yeni veresiye dokümanı
      return _creditRepo.add(CreditSale(
        id: '',
        customerName: customerName,
        totalAmount: creditSales,
        remainingAmount: creditSales,
        date: day,
        status: CreditStatus.pending,
        linkedDailyRecordId: key,
      ));
    }

    // creditSales == 0: bağlı kayıt varsa
    if (existingLinkedId != null) {
      final sale = await _creditRepo.getById(existingLinkedId);
      if (sale != null) {
        if (sale.payments.isEmpty) {
          // Yanlış girilmiş/iptal edilen veresiye → sil ("ödendi" yapma, BUG-01).
          await _creditRepo.delete(existingLinkedId);
          return null;
        }
        // Ödeme geçmişi varsa koru: paid/0'a mutabık kıl (silme yok).
        await _creditRepo.update(
          CreditReconciler.reconcile(sale, newTotal: 0),
        );
      }
    }
    return existingLinkedId;
  }
}
