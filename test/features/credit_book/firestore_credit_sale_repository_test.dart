import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/credit_book/data/firestore_credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';

CreditSale sale({int total = 100000}) => CreditSale(
      id: '',
      customerName: 'Ahmet',
      totalAmount: total,
      remainingAmount: total,
      date: DateTime(2026, 6, 3),
      status: CreditStatus.pending,
      linkedDailyRecordId: '2026-06-03',
    );

void main() {
  test('add yeni id döner ve getById ile okunur', () async {
    final fake = FakeFirebaseFirestore();
    final repo = FirestoreCreditSaleRepository(fake);

    final id = await repo.add(sale());
    expect(id, isNotEmpty);

    final loaded = await repo.getById(id);
    expect(loaded, isNotNull);
    expect(loaded!.customerName, 'Ahmet');
    expect(loaded.linkedDailyRecordId, '2026-06-03');
  });

  test('update mevcut dokümanı değiştirir', () async {
    final fake = FakeFirebaseFirestore();
    final repo = FirestoreCreditSaleRepository(fake);

    final id = await repo.add(sale(total: 100000));
    final loaded = await repo.getById(id);
    await repo.update(loaded!.copyWith(totalAmount: 50000, remainingAmount: 50000));

    final reloaded = await repo.getById(id);
    expect(reloaded!.totalAmount, 50000);
  });

  test('getById olmayan id için null döner', () async {
    final fake = FakeFirebaseFirestore();
    final repo = FirestoreCreditSaleRepository(fake);
    expect(await repo.getById('nope'), isNull);
  });
}
