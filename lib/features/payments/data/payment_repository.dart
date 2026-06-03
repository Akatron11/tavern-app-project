import '../domain/pending_expense.dart';
import '../domain/staff_payment.dart';

abstract class PaymentRepository {
  // Staff ödemeleri
  Stream<List<StaffPayment>> watchStaffPayments();
  Future<String> addStaffPayment(StaffPayment payment);

  // Bekleyen giderler
  Stream<List<PendingExpense>> watchExpenses();
  Future<PendingExpense?> getExpenseById(String id);
  Future<String> addExpense(PendingExpense expense);
  Future<void> updateExpense(PendingExpense expense);
}
