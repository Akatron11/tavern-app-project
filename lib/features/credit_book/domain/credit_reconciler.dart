import 'dart:math' as math;

import 'credit_sale.dart';

/// Veresiye mutabakatı (saf fonksiyon, §3.4).
///
/// `remaining = max(0, newTotal − Σpayments)`; durum yeniden hesaplanır:
/// - `remaining == 0` → paid
/// - payments boş & `remaining == newTotal` → pending
/// - aksi halde → partial
class CreditReconciler {
  const CreditReconciler._();

  static CreditSale reconcile(CreditSale sale, {required int newTotal}) {
    final paid = sale.payments.fold<int>(0, (sum, p) => sum + p.amount);
    final remaining = math.max(0, newTotal - paid);

    final CreditStatus status;
    if (remaining == 0) {
      status = CreditStatus.paid;
    } else if (sale.payments.isEmpty && remaining == newTotal) {
      status = CreditStatus.pending;
    } else {
      status = CreditStatus.partial;
    }

    return sale.copyWith(
      totalAmount: newTotal,
      remainingAmount: remaining,
      status: status,
    );
  }
}
