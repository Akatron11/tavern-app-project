import 'dart:async';

import '../../../core/utils/date_utils.dart';
import '../domain/credit_sale.dart';
import 'credit_sale_repository.dart';

class MockCreditSaleRepository implements CreditSaleRepository {
  final Map<String, CreditSale> store = {};
  final _controller = StreamController<List<CreditSale>>.broadcast();
  int _nextId = 1;

  List<CreditSale> get _all => store.values.toList();

  void _notify() => _controller.add(_all);

  @override
  Stream<List<CreditSale>> watchAll() {
    Future.microtask(_notify);
    return _controller.stream;
  }

  @override
  Future<String> add(CreditSale sale) async {
    final id = 'mock_cs_${_nextId++}';
    store[id] = sale.copyWith(id: id);
    _notify();
    return id;
  }

  @override
  Future<void> update(CreditSale sale) async {
    store[sale.id] = sale;
    _notify();
  }

  @override
  Future<CreditSale?> getById(String id) async => store[id];

  @override
  Future<List<CreditSale>> getByDateRange(DateRange range) async {
    return store.values
        .where((c) =>
            !c.date.isBefore(range.start) && c.date.isBefore(range.end))
        .toList();
  }

  @override
  Future<void> delete(String id) async {
    store.remove(id);
    _notify();
  }

  void dispose() => _controller.close();
}
