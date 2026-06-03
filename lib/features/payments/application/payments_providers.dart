import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/daily_record/application/daily_record_providers.dart';
import '../../../features/daily_record/domain/daily_record.dart';
import '../../../features/staff/application/staff_providers.dart';
import '../../../shared/providers/firebase_providers.dart';
import '../data/firestore_payment_repository.dart';
import '../data/payment_repository.dart';
import '../domain/payroll_calculator.dart';
import '../domain/payroll_summary.dart';
import '../domain/pending_expense.dart';
import '../domain/staff_payment.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return FirestorePaymentRepository(ref.watch(firestoreProvider));
});

final staffPaymentsStreamProvider = StreamProvider<List<StaffPayment>>((ref) {
  return ref.watch(paymentRepositoryProvider).watchStaffPayments();
});

final expensesStreamProvider = StreamProvider<List<PendingExpense>>((ref) {
  return ref.watch(paymentRepositoryProvider).watchExpenses();
});

/// Tüm günlük kayıtları bir kez çeker (payroll hesabı için).
final allDailyRecordsProvider = FutureProvider<List<DailyRecord>>((ref) {
  return ref.watch(dailyRecordRepositoryProvider).getAll();
});

/// Aktif personel için tahakkuk + ödeme satırlarını hesaplar.
final staffPayrollRowsProvider =
    FutureProvider<List<StaffPayrollRow>>((ref) async {
  final staffAsync = ref.watch(activeStaffProvider);
  final staff = staffAsync.asData?.value ?? [];

  final records = await ref.watch(allDailyRecordsProvider.future);

  final paymentsAsync = ref.watch(staffPaymentsStreamProvider);
  final payments = paymentsAsync.asData?.value ?? [];

  return staff.map((s) {
    final summary = PayrollCalculator.accrue(s, records);
    final paid = payments
        .where((p) => p.staffId == s.id)
        .fold(0, (sum, p) => sum + p.amount);
    final remaining = summary.accruedWage - paid;
    return StaffPayrollRow(
      staffId: s.id,
      staffName: s.name,
      workedDays: summary.workedDays,
      accruedWage: summary.accruedWage,
      totalPaid: paid,
      remaining: remaining < 0 ? 0 : remaining,
    );
  }).toList();
});

// ---------------------------------------------------------------------------
// PaymentsController
// ---------------------------------------------------------------------------

final paymentsControllerProvider =
    AsyncNotifierProvider<PaymentsController, void>(PaymentsController.new);

class PaymentsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  PaymentRepository get _repo => ref.read(paymentRepositoryProvider);

  Future<void> addStaffPayment({
    required String staffId,
    required int amount,
    required DateTime date,
    String notes = '',
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.addStaffPayment(StaffPayment(
          id: '',
          staffId: staffId,
          amount: amount,
          date: date,
          notes: notes,
        )));
  }

  Future<void> addExpense({
    required String description,
    required int totalAmount,
    required DateTime date,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.addExpense(PendingExpense(
          id: '',
          description: description,
          totalAmount: totalAmount,
          remainingAmount: totalAmount,
          status: ExpenseStatus.pending,
          date: date,
        )));
  }

  Future<void> addExpensePayment(String expenseId, int amount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final expense = await _repo.getExpenseById(expenseId);
      if (expense == null) throw Exception('Gider bulunamadı: $expenseId');
      final payment = ExpensePayment(amount: amount, date: DateTime.now());
      final withPayment =
          expense.copyWith(payments: [...expense.payments, payment]);
      final newPaid =
          withPayment.payments.fold(0, (s, p) => s + p.amount);
      final newRemaining = withPayment.totalAmount - newPaid;
      final remaining = newRemaining < 0 ? 0 : newRemaining;
      final status = remaining == 0
          ? ExpenseStatus.paid
          : withPayment.payments.isEmpty
              ? ExpenseStatus.pending
              : ExpenseStatus.partial;
      await _repo.updateExpense(
          withPayment.copyWith(remainingAmount: remaining, status: status));
    });
  }

  Future<void> markExpensePaid(String expenseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final expense = await _repo.getExpenseById(expenseId);
      if (expense == null) throw Exception('Gider bulunamadı: $expenseId');
      if (expense.remainingAmount <= 0) return;
      final payment =
          ExpensePayment(amount: expense.remainingAmount, date: DateTime.now());
      final updated = expense.copyWith(
        payments: [...expense.payments, payment],
        remainingAmount: 0,
        status: ExpenseStatus.paid,
      );
      await _repo.updateExpense(updated);
    });
  }

  Future<void> undoExpensePaid(String expenseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final expense = await _repo.getExpenseById(expenseId);
      if (expense == null || expense.payments.isEmpty) return;
      final trimmed = expense.payments.sublist(0, expense.payments.length - 1);
      final newPaid = trimmed.fold(0, (s, p) => s + p.amount);
      final newRemaining = expense.totalAmount - newPaid;
      final status = newRemaining == expense.totalAmount
          ? ExpenseStatus.pending
          : newRemaining == 0
              ? ExpenseStatus.paid
              : ExpenseStatus.partial;
      await _repo.updateExpense(expense.copyWith(
        payments: trimmed,
        remainingAmount: newRemaining,
        status: status,
      ));
    });
  }
}
