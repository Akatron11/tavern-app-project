import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tip_distribution.dart';
import 'tip_distribution_repository.dart';

class FirestoreTipDistributionRepository implements TipDistributionRepository {
  FirestoreTipDistributionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('tipDistributions');

  @override
  Future<String> add(TipDistribution dist) async {
    final map = dist.toMap()..remove('id');
    final docRef = await _col.add(map);
    return docRef.id;
  }

  @override
  Future<List<TipDistribution>> getAll() async {
    final snap = await _col.orderBy('date').get();
    return snap.docs
        .map((doc) => TipDistribution.fromMap(doc.id, doc.data()))
        .toList();
  }
}
