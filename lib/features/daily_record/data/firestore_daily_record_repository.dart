import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/daily_record.dart';
import 'daily_record_repository.dart';

class FirestoreDailyRecordRepository implements DailyRecordRepository {
  FirestoreDailyRecordRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('dailyRecords');

  @override
  Future<DailyRecord?> getByDay(String dayKey) async {
    final doc = await _col.doc(dayKey).get();
    if (!doc.exists || doc.data() == null) return null;
    return DailyRecord.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> save(DailyRecord record) =>
      _col.doc(record.id).set(record.toMap()..remove('id'));
}
