import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/payments/domain/pending_expense.dart';

void main() {
  final payment = ExpensePayment(amount: 50000, date: DateTime(2026, 6, 2));
  final expense = PendingExpense(
    id: 'e1',
    description: 'Elektrik faturası',
    totalAmount: 200000,
    remainingAmount: 150000,
    payments: [payment],
    status: ExpenseStatus.partial,
    date: DateTime(2026, 6, 1),
  );

  test('toMap / fromMap roundtrip', () {
    final map = expense.toMap();
    final restored = PendingExpense.fromMap('e1', map);
    expect(restored, expense);
  });

  test('toMap type alanı "expense" olmalı', () {
    expect(expense.toMap()['type'], 'expense');
  });

  test('payments listesi roundtrip', () {
    final map = expense.toMap();
    final restored = PendingExpense.fromMap('e1', map);
    expect(restored.payments.length, 1);
    expect(restored.payments.first.amount, 50000);
  });

  test('copyWith description değiştirir', () {
    final c = expense.copyWith(description: 'Su faturası');
    expect(c.description, 'Su faturası');
    expect(c.totalAmount, 200000);
  });

  test('boş payments ile pending durumunda oluşturulabilir', () {
    final e = PendingExpense(
      id: '',
      description: 'Bakkal',
      totalAmount: 100000,
      remainingAmount: 100000,
      status: ExpenseStatus.pending,
      date: DateTime(2026, 6, 1),
    );
    expect(e.payments, isEmpty);
    expect(e.status, ExpenseStatus.pending);
  });
}
