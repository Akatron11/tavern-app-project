import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/date_utils.dart';
import '../domain/credit_sale.dart';
import 'credit_sale_repository.dart';

class FirestoreCreditSaleRepository implements CreditSaleRepository {
  FirestoreCreditSaleRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('creditSales');

  @override
  Stream<List<CreditSale>> watchAll() => _col
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => CreditSale.fromMap(d.id, d.data()))
          .toList());

  @override
  Future<String> add(CreditSale sale) async {
    final ref = await _col.add(sale.toMap()..remove('id'));
    return ref.id;
  }

  @override
  Future<void> update(CreditSale sale) =>
      _col.doc(sale.id).update(sale.toMap()..remove('id'));

  @override
  Future<CreditSale?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return CreditSale.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<List<CreditSale>> getByDateRange(DateRange range) async {
    final snap = await _col
        .where('date',
            isGreaterThanOrEqualTo: range.start.toIso8601String())
        .where('date', isLessThan: range.end.toIso8601String())
        .get();
    return snap.docs
        .map((d) => CreditSale.fromMap(d.id, d.data()))
        .toList();
  }

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}
