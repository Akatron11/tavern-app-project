import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/daily_record/data/firestore_daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';

DailyRecord record(String id, DateTime date, {int revenue = 100000}) =>
    DailyRecord(
      id: id,
      date: date,
      revenue: revenue,
      creditCard: 0,
      tips: 0,
      ownerExpenses: 0,
      cashExpenses: 0,
      creditSales: 0,
      previousDayCash: 0,
      dailyCash: revenue,
      totalCash: revenue,
    );

void main() {
  test('save sonra getByDay aynı kaydı döner (dayKey doküman kimliği)', () async {
    final fake = FakeFirebaseFirestore();
    final repo = FirestoreDailyRecordRepository(fake);

    await repo.save(record('2026-06-03', DateTime(2026, 6, 3)));
    final loaded = await repo.getByDay('2026-06-03');

    expect(loaded, isNotNull);
    expect(loaded!.revenue, 100000);
    // doküman kimliği dayKey olmalı
    final doc =
        await fake.collection('dailyRecords').doc('2026-06-03').get();
    expect(doc.exists, isTrue);
  });

  test('save aynı gün için üzerine yazar (upsert)', () async {
    final fake = FakeFirebaseFirestore();
    final repo = FirestoreDailyRecordRepository(fake);

    await repo.save(record('2026-06-03', DateTime(2026, 6, 3), revenue: 100000));
    await repo.save(record('2026-06-03', DateTime(2026, 6, 3), revenue: 500000));

    final loaded = await repo.getByDay('2026-06-03');
    expect(loaded!.revenue, 500000);
    final all = await fake.collection('dailyRecords').get();
    expect(all.docs.length, 1);
  });

  test('getByDay olmayan gün için null döner', () async {
    final fake = FakeFirebaseFirestore();
    final repo = FirestoreDailyRecordRepository(fake);
    expect(await repo.getByDay('2099-01-01'), isNull);
  });
}
