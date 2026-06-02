import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';

void main() {
  final sale = CreditSale(
    id: 'cs1',
    customerName: 'Ahmet',
    totalAmount: 100000,
    remainingAmount: 70000,
    date: DateTime(2026, 6, 3),
    status: CreditStatus.partial,
    payments: [
      CreditPayment(amount: 30000, date: DateTime(2026, 6, 4)),
    ],
    linkedDailyRecordId: '2026-06-03',
  );

  test('toMap/fromMap roundtrip aynı modeli üretir', () {
    final restored = CreditSale.fromMap(sale.id, sale.toMap());
    expect(restored, sale);
  });

  test('CreditStatus.fromString bilinmeyen değer için pending döner', () {
    expect(CreditStatus.fromString('xyz'), CreditStatus.pending);
    expect(CreditStatus.fromString('paid'), CreditStatus.paid);
  });

  test('fromMap boş payments listesini güvenli okur', () {
    final restored = CreditSale.fromMap('cs2', {
      'customerName': 'Veli',
      'totalAmount': 50000,
      'remainingAmount': 50000,
      'date': DateTime(2026, 6, 5).toIso8601String(),
      'status': 'pending',
    });
    expect(restored.payments, isEmpty);
    expect(restored.linkedDailyRecordId, isNull);
  });
}
