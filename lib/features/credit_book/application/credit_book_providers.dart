import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/firebase_providers.dart';
import '../data/credit_sale_repository.dart';
import '../data/firestore_credit_sale_repository.dart';
import '../domain/credit_reconciler.dart';
import '../domain/credit_sale.dart';

final creditSaleRepositoryProvider = Provider<CreditSaleRepository>((ref) {
  return FirestoreCreditSaleRepository(ref.watch(firestoreProvider));
});

final creditSaleListProvider = StreamProvider<List<CreditSale>>((ref) {
  return ref.watch(creditSaleRepositoryProvider).watchAll();
});

final creditBookControllerProvider =
    AsyncNotifierProvider<CreditBookController, void>(
        CreditBookController.new);

class CreditBookController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  CreditSaleRepository get _repo => ref.read(creditSaleRepositoryProvider);

  /// Manuel (günlük kayda bağlı olmayan) yeni veresiye ekler.
  Future<void> addSale({
    required String customerName,
    required int totalAmount,
    required DateTime date,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.add(CreditSale(
          id: '',
          customerName: customerName,
          totalAmount: totalAmount,
          remainingAmount: totalAmount,
          date: date,
          status: CreditStatus.pending,
        )));
  }

  /// Mevcut veresiyeyi günceller (müşteri adı + toplam → mutabakat).
  Future<void> updateSale(
    CreditSale sale, {
    required String customerName,
    required int totalAmount,
    DateTime? date,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final updated = CreditReconciler.reconcile(
        sale.copyWith(customerName: customerName, date: date ?? sale.date),
        newTotal: totalAmount,
      );
      return _repo.update(updated);
    });
  }

  /// Kısmi ödeme ekler; amount > 0 && amount <= remaining olmalı.
  Future<void> addPayment(String saleId, int amount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sale = await _repo.getById(saleId);
      if (sale == null) throw Exception('Veresiye bulunamadı: $saleId');
      final payment = CreditPayment(amount: amount, date: DateTime.now());
      final withPayment = sale.copyWith(
          payments: [...sale.payments, payment]);
      final reconciled =
          CreditReconciler.reconcile(withPayment, newTotal: sale.totalAmount);
      await _repo.update(reconciled);
    });
  }

  /// Kalan tutarı sıfırlar; payments listesine tam-ödeme kaydı ekler.
  Future<void> markPaid(String saleId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sale = await _repo.getById(saleId);
      if (sale == null) throw Exception('Veresiye bulunamadı: $saleId');
      if (sale.remainingAmount <= 0) return;
      final payment =
          CreditPayment(amount: sale.remainingAmount, date: DateTime.now());
      final withPayment =
          sale.copyWith(payments: [...sale.payments, payment]);
      final reconciled = CreditReconciler.reconcile(
          withPayment, newTotal: sale.totalAmount);
      await _repo.update(reconciled);
    });
  }

  /// Son ödemeyi siler; status/remaining yeniden hesaplanır.
  Future<void> undoPaid(String saleId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sale = await _repo.getById(saleId);
      if (sale == null || sale.payments.isEmpty) return;
      final trimmed = sale.payments.sublist(0, sale.payments.length - 1);
      final withoutLast = sale.copyWith(payments: trimmed);
      final reconciled = CreditReconciler.reconcile(
          withoutLast, newTotal: sale.totalAmount);
      await _repo.update(reconciled);
    });
  }
}
