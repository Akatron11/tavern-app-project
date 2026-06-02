import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';

void main() {
  final sample = DailyRecord(
    id: '2026-06-03',
    date: DateTime(2026, 6, 3),
    revenue: 1000000,
    creditCard: 300000,
    tips: 50000,
    ownerExpenses: 20000,
    cashExpenses: 30000,
    creditSales: 100000,
    creditCustomerName: 'Ahmet',
    previousDayCash: 200000,
    dailyCash: 620000,
    totalCash: 820000,
    workingStaffIds: const ['s1', 's2'],
    linkedCreditSaleId: 'cs1',
    notes: 'yoğun gün',
  );

  test('toMap/fromMap roundtrip aynı modeli üretir', () {
    final map = sample.toMap();
    final restored = DailyRecord.fromMap(sample.id, map);
    expect(restored, sample);
  });

  test('toMap id alanını da içerir', () {
    expect(sample.toMap()['id'], '2026-06-03');
  });

  test('fromMap eksik opsiyonel alanlarda güvenli varsayılan kullanır', () {
    final restored = DailyRecord.fromMap('2026-06-04', {
      'date': DateTime(2026, 6, 4).toIso8601String(),
      'revenue': 0,
      'creditCard': 0,
      'tips': 0,
      'ownerExpenses': 0,
      'cashExpenses': 0,
      'creditSales': 0,
      'previousDayCash': 0,
      'dailyCash': 0,
      'totalCash': 0,
    });
    expect(restored.workingStaffIds, isEmpty);
    expect(restored.creditCustomerName, '');
    expect(restored.linkedCreditSaleId, isNull);
    expect(restored.notes, '');
  });

  test('copyWith yalnızca verilen alanı değiştirir', () {
    final edited = sample.copyWith(revenue: 1500000);
    expect(edited.revenue, 1500000);
    expect(edited.creditCard, sample.creditCard);
  });
}
