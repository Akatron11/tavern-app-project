import 'dart:async';

import '../domain/staff.dart';
import 'staff_repository.dart';

class MockStaffRepository implements StaffRepository {
  final Map<String, Staff> _store = {};
  final _controller = StreamController<List<Staff>>.broadcast();
  int _nextId = 1;

  List<Staff> get _all => _store.values.toList();

  void _notify() => _controller.add(_all);

  @override
  Stream<List<Staff>> watchAll() {
    Future.microtask(_notify);
    return _controller.stream;
  }

  @override
  Stream<List<Staff>> watchActive() =>
      watchAll().map((list) => list.where((s) => s.isActive).toList());

  @override
  Future<Staff?> getById(String id) async => _store[id];

  @override
  Future<String> add(Staff staff) async {
    final id = 'mock_${_nextId++}';
    _store[id] = staff.copyWith(id: id);
    _notify();
    return id;
  }

  @override
  Future<void> update(Staff staff) async {
    _store[staff.id] = staff;
    _notify();
  }

  @override
  Future<void> deactivate(String id) async {
    final s = _store[id];
    if (s != null) {
      _store[id] = s.copyWith(isActive: false);
      _notify();
    }
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
    _notify();
  }

  void dispose() => _controller.close();
}
