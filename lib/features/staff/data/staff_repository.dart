import '../domain/staff.dart';

abstract class StaffRepository {
  Stream<List<Staff>> watchAll();
  Stream<List<Staff>> watchActive();
  Future<Staff?> getById(String id);
  Future<String> add(Staff staff);
  Future<void> update(Staff staff);
  Future<void> deactivate(String id);

  /// Yalnızca hiçbir dailyRecord'da geçmeyen personeli siler.
  Future<void> delete(String id);
}
