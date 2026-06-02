import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/credit_sale.dart';
import 'credit_sale_repository.dart';

class FirestoreCreditSaleRepository implements CreditSaleRepository {
  FirestoreCreditSaleRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('creditSales');

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
}
