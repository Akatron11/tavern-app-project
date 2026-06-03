import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/weekly_summary/domain/tip_distribution.dart';

void main() {
  final dist = TipDistribution(
    id: 'dist1',
    date: DateTime(2026, 6, 3),
    amount: 150000,
    periodStart: DateTime(2026, 5, 27),
    periodEnd: DateTime(2026, 6, 3),
  );

  test('toMap / fromMap roundtrip', () {
    final map = dist.toMap();
    final restored = TipDistribution.fromMap(dist.id, map);
    expect(restored, dist);
  });

  test('copyWith değeri günceller', () {
    final updated = dist.copyWith(amount: 200000);
    expect(updated.amount, 200000);
    expect(updated.id, dist.id);
    expect(updated.date, dist.date);
  });

  test('equatable — aynı alan değerleri eşit', () {
    final other = TipDistribution(
      id: 'dist1',
      date: DateTime(2026, 6, 3),
      amount: 150000,
      periodStart: DateTime(2026, 5, 27),
      periodEnd: DateTime(2026, 6, 3),
    );
    expect(dist, other);
  });
}
