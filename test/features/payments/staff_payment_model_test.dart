import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/payments/domain/staff_payment.dart';

void main() {
  final sample = StaffPayment(
    id: 'sp1',
    staffId: 'staff_a',
    amount: 300000,
    date: DateTime(2026, 6, 1),
    notes: 'Haftalık',
  );

  test('toMap / fromMap roundtrip', () {
    final map = sample.toMap();
    final restored = StaffPayment.fromMap('sp1', map);
    expect(restored, sample);
  });

  test('toMap type alanı "staff" olmalı', () {
    expect(sample.toMap()['type'], 'staff');
  });

  test('copyWith staffId değiştirir', () {
    final c = sample.copyWith(staffId: 'staff_b');
    expect(c.staffId, 'staff_b');
    expect(c.amount, 300000);
  });
}
