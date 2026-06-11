import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/credit_book/application/credit_book_providers.dart';
import 'package:gilanli_meyhane/features/credit_book/data/mock_credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';

void main() {
  late MockCreditSaleRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockCreditSaleRepository();
    container = ProviderContainer(overrides: [
      creditSaleRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
  });

  CreditBookController ctrl() =>
      container.read(creditBookControllerProvider.notifier);

  test('addSale pending kayıt oluşturur', () async {
    await ctrl().addSale(
      customerName: 'Ali',
      totalAmount: 100000,
      date: DateTime(2026, 1, 1),
    );
    expect(repo.store.length, 1);
    final sale = repo.store.values.first;
    expect(sale.customerName, 'Ali');
    expect(sale.totalAmount, 100000);
    expect(sale.remainingAmount, 100000);
    expect(sale.status, CreditStatus.pending);
    expect(sale.linkedDailyRecordId, isNull);
  });

  test('addPayment remaining azaltır ve status partial olur', () async {
    await ctrl().addSale(
        customerName: 'Mehmet', totalAmount: 500000, date: DateTime(2026, 1, 1));
    final id = repo.store.keys.first;

    await ctrl().addPayment(id, 200000);

    final sale = repo.store[id]!;
    expect(sale.remainingAmount, 300000);
    expect(sale.status, CreditStatus.partial);
    expect(sale.payments.length, 1);
    expect(sale.payments.first.amount, 200000);
  });

  test('markPaid remaining sıfırlar ve status paid olur', () async {
    await ctrl().addSale(
        customerName: 'Ayşe', totalAmount: 300000, date: DateTime(2026, 1, 1));
    final id = repo.store.keys.first;
    await ctrl().addPayment(id, 100000);

    await ctrl().markPaid(id);

    final sale = repo.store[id]!;
    expect(sale.remainingAmount, 0);
    expect(sale.status, CreditStatus.paid);
    expect(sale.payments.length, 2);
    expect(sale.payments.last.amount, 200000);
  });

  test('undoPaid son ödemeyi siler ve status/remaining yeniden hesaplanır',
      () async {
    await ctrl().addSale(
        customerName: 'Fatma', totalAmount: 400000, date: DateTime(2026, 1, 1));
    final id = repo.store.keys.first;
    await ctrl().addPayment(id, 100000);
    await ctrl().markPaid(id);

    await ctrl().undoPaid(id);

    final sale = repo.store[id]!;
    expect(sale.remainingAmount, 300000);
    expect(sale.status, CreditStatus.partial);
    expect(sale.payments.length, 1);
  });

  test('updateSale müşteri adı ve toplamı günceller, mutabakat yapılır',
      () async {
    await ctrl().addSale(
        customerName: 'Eski', totalAmount: 200000, date: DateTime(2026, 1, 1));
    final id = repo.store.keys.first;
    final sale = repo.store[id]!;

    await ctrl().updateSale(sale, customerName: 'Yeni', totalAmount: 150000);

    final updated = repo.store[id]!;
    expect(updated.customerName, 'Yeni');
    expect(updated.totalAmount, 150000);
    expect(updated.remainingAmount, 150000);
    expect(updated.status, CreditStatus.pending);
  });

  test('BUG-06: updateSale tarih verilince günceller, verilmezse korur',
      () async {
    await ctrl().addSale(
        customerName: 'Veli', totalAmount: 100000, date: DateTime(2026, 1, 1));
    final id = repo.store.keys.first;

    await ctrl().updateSale(repo.store[id]!,
        customerName: 'Veli', totalAmount: 100000, date: DateTime(2026, 3, 15));
    expect(repo.store[id]!.date, DateTime(2026, 3, 15));

    await ctrl().updateSale(repo.store[id]!,
        customerName: 'Veli', totalAmount: 120000);
    expect(repo.store[id]!.date, DateTime(2026, 3, 15)); // korunur
  });

  test('YENİ-01: deleteSale ödendi kaydı tamamen siler', () async {
    await ctrl().addSale(
        customerName: 'Sil', totalAmount: 100000, date: DateTime(2026, 1, 1));
    final id = repo.store.keys.first;
    await ctrl().markPaid(id);

    await ctrl().deleteSale(id);

    expect(repo.store, isEmpty);
  });
}
