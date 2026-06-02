import '../domain/credit_sale.dart';
import 'credit_sale_repository.dart';

class MockCreditSaleRepository implements CreditSaleRepository {
  final Map<String, CreditSale> store = {};
  int _nextId = 1;

  @override
  Future<String> add(CreditSale sale) async {
    final id = 'mock_cs_${_nextId++}';
    store[id] = sale.copyWith(id: id);
    return id;
  }

  @override
  Future<void> update(CreditSale sale) async {
    store[sale.id] = sale;
  }

  @override
  Future<CreditSale?> getById(String id) async => store[id];
}
