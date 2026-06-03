import 'dart:async';

import '../domain/pending_expense.dart';
import '../domain/staff_payment.dart';
import 'payment_repository.dart';

class MockPaymentRepository implements PaymentRepository {
  final Map<String, StaffPayment> staffPayments = {};
  final Map<String, PendingExpense> expenses = {};
  int _nextId = 1;

  final _spController = StreamController<List<StaffPayment>>.broadcast();
  final _expController = StreamController<List<PendingExpense>>.broadcast();

  void _notifySp() => _spController.add(staffPayments.values.toList());
  void _notifyExp() => _expController.add(expenses.values.toList());

  @override
  Stream<List<StaffPayment>> watchStaffPayments() {
    Future.microtask(_notifySp);
    return _spController.stream;
  }

  @override
  Future<String> addStaffPayment(StaffPayment payment) async {
    final id = 'mock_sp_${_nextId++}';
    staffPayments[id] = payment.copyWith(id: id);
    _notifySp();
    return id;
  }

  @override
  Stream<List<PendingExpense>> watchExpenses() {
    Future.microtask(_notifyExp);
    return _expController.stream;
  }

  @override
  Future<PendingExpense?> getExpenseById(String id) async => expenses[id];

  @override
  Future<String> addExpense(PendingExpense expense) async {
    final id = 'mock_exp_${_nextId++}';
    expenses[id] = expense.copyWith(id: id);
    _notifyExp();
    return id;
  }

  @override
  Future<void> updateExpense(PendingExpense expense) async {
    expenses[expense.id] = expense;
    _notifyExp();
  }

  void dispose() {
    _spController.close();
    _expController.close();
  }
}
