import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/date_utils.dart';
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

  @override
  Future<List<DailyRecord>> getAll() async {
    final snap = await _col.get();
    return snap.docs
        .map((doc) => DailyRecord.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<DailyRecord>> getByDateRange(DateRange range) async {
    final startKey = dayKey(range.start);
    final endKey = dayKey(range.end);
    final snap = await _col
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
        .where(FieldPath.documentId, isLessThan: endKey)
        .get();
    return snap.docs
        .map((doc) => DailyRecord.fromMap(doc.id, doc.data()))
        .toList();
  }
}
