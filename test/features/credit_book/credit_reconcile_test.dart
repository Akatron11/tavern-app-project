import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_reconciler.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';

CreditSale base({
  int total = 100000,
  int remaining = 100000,
  CreditStatus status = CreditStatus.pending,
  List<CreditPayment> payments = const [],
}) =>
    CreditSale(
      id: 'cs1',
      customerName: 'Ahmet',
      totalAmount: total,
      remainingAmount: remaining,
      date: DateTime(2026, 6, 3),
      status: status,
      payments: payments,
      linkedDailyRecordId: '2026-06-03',
    );

void main() {
  group('CreditReconciler.reconcile', () {
    test('payments boş & remaining==newTotal -> pending', () {
      final r = CreditReconciler.reconcile(base(), newTotal: 80000);
      expect(r.totalAmount, 80000);
      expect(r.remainingAmount, 80000);
      expect(r.status, CreditStatus.pending);
    });

    test('kısmi ödeme varken 0<remaining<newTotal -> partial', () {
      final sale = base(payments: [
        CreditPayment(amount: 30000, date: DateTime(2026, 6, 4)),
      ]);
      final r = CreditReconciler.reconcile(sale, newTotal: 100000);
      expect(r.remainingAmount, 70000);
      expect(r.status, CreditStatus.partial);
    });

    test('ödemeler toplamı newTotal\'a eşit -> paid, remaining 0', () {
      final sale = base(payments: [
        CreditPayment(amount: 100000, date: DateTime(2026, 6, 4)),
      ]);
      final r = CreditReconciler.reconcile(sale, newTotal: 100000);
      expect(r.remainingAmount, 0);
      expect(r.status, CreditStatus.paid);
    });

    test('newTotal=0 (veresiye sıfırlandı) & payments boş -> paid, remaining 0', () {
      final r = CreditReconciler.reconcile(base(), newTotal: 0);
      expect(r.totalAmount, 0);
      expect(r.remainingAmount, 0);
      expect(r.status, CreditStatus.paid);
    });

    test('fazla ödeme (sum>newTotal) remaining 0\'a kırpılır -> paid', () {
      final sale = base(payments: [
        CreditPayment(amount: 120000, date: DateTime(2026, 6, 4)),
      ]);
      final r = CreditReconciler.reconcile(sale, newTotal: 100000);
      expect(r.remainingAmount, 0);
      expect(r.status, CreditStatus.paid);
    });
  });
}
