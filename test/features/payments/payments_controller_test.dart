import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/payments/application/payments_providers.dart';
import 'package:gilanli_meyhane/features/payments/data/mock_payment_repository.dart';
import 'package:gilanli_meyhane/features/payments/domain/pending_expense.dart';

void main() {
  late MockPaymentRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockPaymentRepository();
    container = ProviderContainer(overrides: [
      paymentRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
  });

  PaymentsController ctrl() =>
      container.read(paymentsControllerProvider.notifier);

  test('addStaffPayment kayıt oluşturur', () async {
    await ctrl().addStaffPayment(
      staffId: 'staff1',
      amount: 500000,
      date: DateTime(2026, 6, 1),
      notes: 'Test',
    );
    expect(repo.staffPayments.length, 1);
    final p = repo.staffPayments.values.first;
    expect(p.staffId, 'staff1');
    expect(p.amount, 500000);
  });

  test('addExpense pending kayıt oluşturur', () async {
    await ctrl().addExpense(
      description: 'Elektrik',
      totalAmount: 200000,
      date: DateTime(2026, 6, 1),
    );
    expect(repo.expenses.length, 1);
    final e = repo.expenses.values.first;
    expect(e.description, 'Elektrik');
    expect(e.totalAmount, 200000);
    expect(e.remainingAmount, 200000);
    expect(e.status, ExpenseStatus.pending);
  });

  test('addExpensePayment remaining azaltır ve partial olur', () async {
    await ctrl().addExpense(
        description: 'Su', totalAmount: 300000, date: DateTime(2026, 6, 1));
    final id = repo.expenses.keys.first;

    await ctrl().addExpensePayment(id, 100000);

    final e = repo.expenses[id]!;
    expect(e.remainingAmount, 200000);
    expect(e.status, ExpenseStatus.partial);
    expect(e.payments.length, 1);
  });

  test('markExpensePaid remaining=0 ve status=paid yapar', () async {
    await ctrl().addExpense(
        description: 'Kira', totalAmount: 400000, date: DateTime(2026, 6, 1));
    final id = repo.expenses.keys.first;
    await ctrl().addExpensePayment(id, 100000);

    await ctrl().markExpensePaid(id);

    final e = repo.expenses[id]!;
    expect(e.remainingAmount, 0);
    expect(e.status, ExpenseStatus.paid);
    expect(e.payments.length, 2);
    expect(e.payments.last.amount, 300000);
  });

  test('undoExpensePaid son ödemeyi kaldırır ve status/remaining yeniden hesaplanır',
      () async {
    await ctrl().addExpense(
        description: 'Bakım', totalAmount: 250000, date: DateTime(2026, 6, 1));
    final id = repo.expenses.keys.first;
    await ctrl().markExpensePaid(id);

    await ctrl().undoExpensePaid(id);

    final e = repo.expenses[id]!;
    expect(e.remainingAmount, 250000);
    expect(e.status, ExpenseStatus.pending);
    expect(e.payments, isEmpty);
  });
}
