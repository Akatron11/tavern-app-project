import '../domain/credit_sale.dart';

abstract class CreditSaleRepository {
  Future<String> add(CreditSale sale);
  Future<void> update(CreditSale sale);
  Future<CreditSale?> getById(String id);
}
