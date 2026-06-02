import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/staff.dart';
import 'staff_repository.dart';

class FirestoreStaffRepository implements StaffRepository {
  FirestoreStaffRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('staff');

  @override
  Stream<List<Staff>> watchAll() => _col.snapshots().map(
        (s) => s.docs.map((d) => Staff.fromMap(d.id, d.data())).toList(),
      );

  @override
  Stream<List<Staff>> watchActive() => _col
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Staff.fromMap(d.id, d.data())).toList());

  @override
  Future<Staff?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Staff.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> add(Staff staff) async {
    final map = staff.toMap()..remove('id');
    final ref = await _col.add(map);
    return ref.id;
  }

  @override
  Future<void> update(Staff staff) =>
      _col.doc(staff.id).update(staff.toMap()..remove('id'));

  @override
  Future<void> deactivate(String id) =>
      _col.doc(id).update({'isActive': false});

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}
