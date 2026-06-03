import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/pending_expense.dart';
import '../domain/staff_payment.dart';
import 'payment_repository.dart';

class FirestorePaymentRepository implements PaymentRepository {
  FirestorePaymentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('payments');

  @override
  Stream<List<StaffPayment>> watchStaffPayments() {
    return _col
        .where('type', isEqualTo: 'staff')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => StaffPayment.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<String> addStaffPayment(StaffPayment payment) async {
    final doc = await _col.add(payment.toMap());
    return doc.id;
  }

  @override
  Stream<List<PendingExpense>> watchExpenses() {
    return _col
        .where('type', isEqualTo: 'expense')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PendingExpense.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<PendingExpense?> getExpenseById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return PendingExpense.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> addExpense(PendingExpense expense) async {
    final doc = await _col.add(expense.toMap());
    return doc.id;
  }

  @override
  Future<void> updateExpense(PendingExpense expense) =>
      _col.doc(expense.id).set(expense.toMap()..remove('id'));
}
