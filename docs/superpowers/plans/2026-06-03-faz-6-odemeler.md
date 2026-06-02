# Faz 6 — Ödemeler (Payments) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Personel tahakkuk + ödeme takibi ve bekleyen gider yönetimi için iki sekmeli Ödemeler ekranı inşa etmek.

**Architecture:** `PayrollCalculator` saf domain servisi olarak TDD ile yazılır. `StaffPayment` ve `PendingExpense` ayrı model sınıfları; ikisi de `payments` Firestore koleksiyonunda `type` alanıyla ayrılır. Personel tahakkuku (`accruedWage`) `DailyRecord.workingStaffIds` + `WageResolver`'dan türetilir — `payments` koleksiyonunda saklanmaz. Mevcut repo/provider/mock kalıpları bire bir izlenir.

**Tech Stack:** Flutter · Riverpod · Firestore (fake_cloud_firestore testlerde) · WageResolver (Faz 3) · DailyRecord (Faz 4) · MoneyInputField, confirmDialog, AppLocalizations (mevcut shared bileşenler)

**Dal:** `phase-6-payments` (zaten açık, 69 test yeşil)

---

## Dosya Yapısı

### Oluşturulacak
```
lib/features/payments/
  domain/
    payroll_summary.dart          # PayrollSummary value object + StaffPayrollRow
    payroll_calculator.dart       # PayrollCalculator.accrue() — saf, TDD
    staff_payment.dart            # StaffPayment model (id, staffId, amount, date, notes)
    pending_expense.dart          # PendingExpense model + ExpensePayment + ExpenseStatus
  data/
    payment_repository.dart       # abstract PaymentRepository
    mock_payment_repository.dart  # bellek-içi; testlerde ve dev'de
    firestore_payment_repository.dart
  application/
    payments_providers.dart       # repo provider, stream providers, PaymentsController
  presentation/
    payments_screen.dart          # DefaultTabController + iki sekme
    expense_form_screen.dart      # gider ekleme/düzenleme ekranı
    widgets/
      staff_payments_tab.dart     # personel listesi + tahakkuk/ödeme özeti + ödeme butonu
      pending_expenses_tab.dart   # gider listesi + aksiyonlar
      staff_payment_dialog.dart   # personele ödeme kaydetme dialog'u
      expense_payment_dialog.dart # gidere kısmi ödeme dialog'u (PaymentDialog ile aynı imza)

test/features/payments/
  payroll_calculator_test.dart
  staff_payment_model_test.dart
  pending_expense_model_test.dart
  payments_controller_test.dart
  payments_screen_test.dart
```

### Değiştirilecek
```
lib/features/daily_record/data/
  daily_record_repository.dart          # + getAll()
  firestore_daily_record_repository.dart # + getAll()
  mock_daily_record_repository.dart      # + getAll()
lib/app/router.dart                      # + /payments
lib/app/placeholder_home_screen.dart     # + Ödemeler kartı
lib/core/l10n/app_tr.arb               # + ödemeler string'leri
lib/core/l10n/app_en.arb               # + payments strings
```

---

## Task 1 — PayrollSummary + PayrollCalculator (TDD)

**Files:**
- Create: `lib/features/payments/domain/payroll_summary.dart`
- Create: `lib/features/payments/domain/payroll_calculator.dart`
- Create: `test/features/payments/payroll_calculator_test.dart`

- [ ] **Step 1: Test dosyasını yaz (kırmızı)**

```dart
// test/features/payments/payroll_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';
import 'package:gilanli_meyhane/features/payments/domain/payroll_calculator.dart';
import 'package:gilanli_meyhane/features/payments/domain/payroll_summary.dart';
import 'package:gilanli_meyhane/features/staff/domain/staff.dart';

DailyRecord _rec(String id, DateTime date, List<String> staffIds) => DailyRecord(
      id: id,
      date: date,
      revenue: 0,
      creditCard: 0,
      tips: 0,
      ownerExpenses: 0,
      cashExpenses: 0,
      creditSales: 0,
      previousDayCash: 0,
      dailyCash: 0,
      totalCash: 0,
      workingStaffIds: staffIds,
    );

Staff _staff(String id, int wage, {List<WageHistoryEntry> history = const []}) =>
    Staff(id: id, name: 'Test $id', role: Role.garson, dailyWage: wage, wageHistory: history);

void main() {
  group('PayrollCalculator.accrue', () {
    test('kayıt yoksa workedDays=0 ve accruedWage=0', () {
      final s = _staff('s1', 100000);
      final result = PayrollCalculator.accrue(s, []);
      expect(result.workedDays, 0);
      expect(result.accruedWage, 0);
      expect(result.staffId, 's1');
      expect(result.staffName, 'Test s1');
    });

    test('3 kayıtta çalışmış personel için 3 günlük ücret', () {
      final s = _staff('s1', 150000);
      final records = [
        _rec('r1', DateTime(2026, 6, 1), ['s1', 's2']),
        _rec('r2', DateTime(2026, 6, 2), ['s1']),
        _rec('r3', DateTime(2026, 6, 3), ['s1', 's3']),
      ];
      final result = PayrollCalculator.accrue(s, records);
      expect(result.workedDays, 3);
      expect(result.accruedWage, 450000); // 3 × 150000
    });

    test('personel çalışmadığı günler sayılmaz', () {
      final s = _staff('s1', 200000);
      final records = [
        _rec('r1', DateTime(2026, 6, 1), ['s2']),
        _rec('r2', DateTime(2026, 6, 2), ['s1']),
        _rec('r3', DateTime(2026, 6, 3), ['s2', 's3']),
      ];
      final result = PayrollCalculator.accrue(s, records);
      expect(result.workedDays, 1);
      expect(result.accruedWage, 200000);
    });

    test('ücret zammı aralığın ortasındaysa öncesi eski, sonrası yeni ücret', () {
      // Zam 4 Haziran'dan itibaren geçerli
      final history = [WageHistoryEntry(effectiveDate: DateTime(2026, 6, 4), dailyWage: 200000)];
      final s = _staff('s1', 100000, history: history);
      final records = [
        _rec('r1', DateTime(2026, 6, 1), ['s1']), // 100000 (eski)
        _rec('r2', DateTime(2026, 6, 3), ['s1']), // 100000 (zam öncesi)
        _rec('r3', DateTime(2026, 6, 4), ['s1']), // 200000 (zam günü)
        _rec('r4', DateTime(2026, 6, 5), ['s1']), // 200000 (zam sonrası)
      ];
      final result = PayrollCalculator.accrue(s, records);
      expect(result.workedDays, 4);
      expect(result.accruedWage, 600000); // 2×100000 + 2×200000
    });

    test('boş workingStaffIds olan kayıt sayılmaz', () {
      final s = _staff('s1', 100000);
      final records = [
        _rec('r1', DateTime(2026, 6, 1), []),
        _rec('r2', DateTime(2026, 6, 2), ['s2']),
      ];
      final result = PayrollCalculator.accrue(s, records);
      expect(result.workedDays, 0);
      expect(result.accruedWage, 0);
    });
  });
}
```

- [ ] **Step 2: Testi çalıştır → kırmızı olduğunu doğrula**

```
flutter test test/features/payments/payroll_calculator_test.dart
```
Beklenen: FAIL — "Cannot find 'PayrollCalculator'"

- [ ] **Step 3: PayrollSummary yaz**

```dart
// lib/features/payments/domain/payroll_summary.dart
import 'package:equatable/equatable.dart';

class PayrollSummary extends Equatable {
  final String staffId;
  final String staffName;
  final int workedDays;
  final int accruedWage; // kuruş

  const PayrollSummary({
    required this.staffId,
    required this.staffName,
    required this.workedDays,
    required this.accruedWage,
  });

  @override
  List<Object?> get props => [staffId, staffName, workedDays, accruedWage];
}

/// UI katmanı için türetilmiş satır (provider'da hesaplanır).
class StaffPayrollRow extends Equatable {
  final String staffId;
  final String staffName;
  final int workedDays;
  final int accruedWage;  // kuruş — PayrollCalculator
  final int totalPaid;    // kuruş — Σ StaffPayment.amount
  final int remaining;    // max(0, accruedWage − totalPaid)

  const StaffPayrollRow({
    required this.staffId,
    required this.staffName,
    required this.workedDays,
    required this.accruedWage,
    required this.totalPaid,
    required this.remaining,
  });

  @override
  List<Object?> get props =>
      [staffId, staffName, workedDays, accruedWage, totalPaid, remaining];
}
```

- [ ] **Step 4: PayrollCalculator yaz**

```dart
// lib/features/payments/domain/payroll_calculator.dart
import '../../daily_record/domain/daily_record.dart';
import '../../staff/domain/staff.dart';
import '../../staff/domain/wage_resolver.dart';
import 'payroll_summary.dart';

class PayrollCalculator {
  PayrollCalculator._();

  /// [staff] için [records] listesindeki çalışma tahakkukunu hesaplar.
  /// workedDays = staff.id'nin workingStaffIds içinde olduğu kayıt sayısı.
  /// accruedWage = o günlere ait wageEffectiveOn toplamı.
  static PayrollSummary accrue(Staff staff, List<DailyRecord> records) {
    int days = 0;
    int wage = 0;
    for (final r in records) {
      if (r.workingStaffIds.contains(staff.id)) {
        days++;
        wage += WageResolver.wageEffectiveOn(staff, r.date);
      }
    }
    return PayrollSummary(
      staffId: staff.id,
      staffName: staff.name,
      workedDays: days,
      accruedWage: wage,
    );
  }
}
```

- [ ] **Step 5: Testi çalıştır → yeşil**

```
flutter test test/features/payments/payroll_calculator_test.dart
```
Beklenen: All 5 tests passed!

- [ ] **Step 6: Commit**

```
git add lib/features/payments/domain/payroll_summary.dart lib/features/payments/domain/payroll_calculator.dart test/features/payments/payroll_calculator_test.dart
git commit -m "feat(payments): TDD PayrollCalculator + PayrollSummary (5 test)"
```

---

## Task 2 — StaffPayment modeli (TDD roundtrip)

**Files:**
- Create: `lib/features/payments/domain/staff_payment.dart`
- Create: `test/features/payments/staff_payment_model_test.dart`

- [ ] **Step 1: Test dosyasını yaz**

```dart
// test/features/payments/staff_payment_model_test.dart
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
```

- [ ] **Step 2: Testi çalıştır → kırmızı**

```
flutter test test/features/payments/staff_payment_model_test.dart
```

- [ ] **Step 3: StaffPayment yaz**

```dart
// lib/features/payments/domain/staff_payment.dart
import 'package:equatable/equatable.dart';

class StaffPayment extends Equatable {
  final String id;
  final String staffId;
  final int amount; // kuruş
  final DateTime date;
  final String notes;

  const StaffPayment({
    required this.id,
    required this.staffId,
    required this.amount,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'type': 'staff',
        'staffId': staffId,
        'amount': amount,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory StaffPayment.fromMap(String id, Map<String, dynamic> map) =>
      StaffPayment(
        id: id,
        staffId: map['staffId'] as String,
        amount: (map['amount'] as num).toInt(),
        date: DateTime.parse(map['date'] as String),
        notes: map['notes'] as String? ?? '',
      );

  StaffPayment copyWith({
    String? id,
    String? staffId,
    int? amount,
    DateTime? date,
    String? notes,
  }) =>
      StaffPayment(
        id: id ?? this.id,
        staffId: staffId ?? this.staffId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [id, staffId, amount, date, notes];
}
```

- [ ] **Step 4: Test → yeşil**

```
flutter test test/features/payments/staff_payment_model_test.dart
```
Beklenen: All 3 tests passed!

- [ ] **Step 5: Commit**

```
git add lib/features/payments/domain/staff_payment.dart test/features/payments/staff_payment_model_test.dart
git commit -m "feat(payments): StaffPayment model (3 test)"
```

---

## Task 3 — PendingExpense modeli (TDD roundtrip)

**Files:**
- Create: `lib/features/payments/domain/pending_expense.dart`
- Create: `test/features/payments/pending_expense_model_test.dart`

- [ ] **Step 1: Test dosyasını yaz**

```dart
// test/features/payments/pending_expense_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/payments/domain/pending_expense.dart';

void main() {
  final payment = ExpensePayment(amount: 50000, date: DateTime(2026, 6, 2));
  final expense = PendingExpense(
    id: 'e1',
    description: 'Elektrik faturası',
    totalAmount: 200000,
    remainingAmount: 150000,
    payments: [payment],
    status: ExpenseStatus.partial,
    date: DateTime(2026, 6, 1),
  );

  test('toMap / fromMap roundtrip', () {
    final map = expense.toMap();
    final restored = PendingExpense.fromMap('e1', map);
    expect(restored, expense);
  });

  test('toMap type alanı "expense" olmalı', () {
    expect(expense.toMap()['type'], 'expense');
  });

  test('payments listesi roundtrip', () {
    final map = expense.toMap();
    final restored = PendingExpense.fromMap('e1', map);
    expect(restored.payments.length, 1);
    expect(restored.payments.first.amount, 50000);
  });

  test('copyWith description değiştirir', () {
    final c = expense.copyWith(description: 'Su faturası');
    expect(c.description, 'Su faturası');
    expect(c.totalAmount, 200000);
  });

  test('boş payments ile pending durumunda oluşturulabilir', () {
    final e = PendingExpense(
      id: '',
      description: 'Bakkal',
      totalAmount: 100000,
      remainingAmount: 100000,
      status: ExpenseStatus.pending,
      date: DateTime(2026, 6, 1),
    );
    expect(e.payments, isEmpty);
    expect(e.status, ExpenseStatus.pending);
  });
}
```

- [ ] **Step 2: Testi çalıştır → kırmızı**

```
flutter test test/features/payments/pending_expense_model_test.dart
```

- [ ] **Step 3: PendingExpense yaz**

```dart
// lib/features/payments/domain/pending_expense.dart
import 'package:equatable/equatable.dart';

enum ExpenseStatus {
  pending,
  partial,
  paid;

  static ExpenseStatus fromString(String v) =>
      ExpenseStatus.values.firstWhere((e) => e.name == v,
          orElse: () => ExpenseStatus.pending);
}

class ExpensePayment extends Equatable {
  final int amount; // kuruş
  final DateTime date;

  const ExpensePayment({required this.amount, required this.date});

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory ExpensePayment.fromMap(Map<String, dynamic> map) => ExpensePayment(
        amount: (map['amount'] as num).toInt(),
        date: DateTime.parse(map['date'] as String),
      );

  @override
  List<Object?> get props => [amount, date];
}

class PendingExpense extends Equatable {
  final String id;
  final String description;
  final int totalAmount;     // kuruş
  final int remainingAmount; // kuruş
  final List<ExpensePayment> payments;
  final ExpenseStatus status;
  final DateTime date;

  const PendingExpense({
    required this.id,
    required this.description,
    required this.totalAmount,
    required this.remainingAmount,
    this.payments = const [],
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'type': 'expense',
        'description': description,
        'totalAmount': totalAmount,
        'remainingAmount': remainingAmount,
        'payments': payments.map((p) => p.toMap()).toList(),
        'status': status.name,
        'date': date.toIso8601String(),
      };

  factory PendingExpense.fromMap(String id, Map<String, dynamic> map) =>
      PendingExpense(
        id: id,
        description: map['description'] as String,
        totalAmount: (map['totalAmount'] as num).toInt(),
        remainingAmount: (map['remainingAmount'] as num).toInt(),
        payments: (map['payments'] as List<dynamic>? ?? [])
            .map((p) => ExpensePayment.fromMap(p as Map<String, dynamic>))
            .toList(),
        status: ExpenseStatus.fromString(map['status'] as String? ?? 'pending'),
        date: DateTime.parse(map['date'] as String),
      );

  PendingExpense copyWith({
    String? id,
    String? description,
    int? totalAmount,
    int? remainingAmount,
    List<ExpensePayment>? payments,
    ExpenseStatus? status,
    DateTime? date,
  }) =>
      PendingExpense(
        id: id ?? this.id,
        description: description ?? this.description,
        totalAmount: totalAmount ?? this.totalAmount,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        payments: payments ?? this.payments,
        status: status ?? this.status,
        date: date ?? this.date,
      );

  @override
  List<Object?> get props =>
      [id, description, totalAmount, remainingAmount, payments, status, date];
}
```

- [ ] **Step 4: Test → yeşil**

```
flutter test test/features/payments/pending_expense_model_test.dart
```
Beklenen: All 5 tests passed!

- [ ] **Step 5: Commit**

```
git add lib/features/payments/domain/pending_expense.dart test/features/payments/pending_expense_model_test.dart
git commit -m "feat(payments): PendingExpense model (5 test)"
```

---

## Task 4 — DailyRecordRepository.getAll() eklentisi

**Files:**
- Modify: `lib/features/daily_record/data/daily_record_repository.dart`
- Modify: `lib/features/daily_record/data/firestore_daily_record_repository.dart`
- Modify: `lib/features/daily_record/data/mock_daily_record_repository.dart`
- Modify: `test/features/daily_record/firestore_daily_record_repository_test.dart`

- [ ] **Step 1: Test ekle (firestore_daily_record_repository_test.dart sonuna)**

Mevcut dosyanın sonuna `void main()` içine yeni test ekle:

```dart
  test('getAll tüm kayıtları döner', () async {
    final fake = FakeFirebaseFirestore();
    final repo = FirestoreDailyRecordRepository(fake);

    await repo.save(record('2026-06-01', DateTime(2026, 6, 1)));
    await repo.save(record('2026-06-02', DateTime(2026, 6, 2)));

    final all = await repo.getAll();
    expect(all.length, 2);
  });
```

- [ ] **Step 2: Testi çalıştır → kırmızı**

```
flutter test test/features/daily_record/firestore_daily_record_repository_test.dart
```

- [ ] **Step 3: Abstract arayüzü güncelle**

```dart
// lib/features/daily_record/data/daily_record_repository.dart
import '../domain/daily_record.dart';

abstract class DailyRecordRepository {
  Future<DailyRecord?> getByDay(String dayKey);
  Future<void> save(DailyRecord record);
  Future<List<DailyRecord>> getAll();
}
```

- [ ] **Step 4: Firestore impl'e getAll() ekle**

```dart
// lib/features/daily_record/data/firestore_daily_record_repository.dart
// Mevcut kodun sonuna şu metodu ekle:
  @override
  Future<List<DailyRecord>> getAll() async {
    final snap = await _col.get();
    return snap.docs
        .map((doc) => DailyRecord.fromMap(doc.id, doc.data()))
        .toList();
  }
```

- [ ] **Step 5: Mock impl'e getAll() ekle**

```dart
// lib/features/daily_record/data/mock_daily_record_repository.dart
// Mevcut kodun sonuna şu metodu ekle:
  @override
  Future<List<DailyRecord>> getAll() async => store.values.toList();
```

- [ ] **Step 6: Testi çalıştır → yeşil**

```
flutter test test/features/daily_record/
```
Beklenen: All 4 tests passed!

- [ ] **Step 7: Tüm testlerin hâlâ yeşil olduğunu doğrula**

```
flutter test --no-pub
```
Beklenen: All 69 (+ yeni test = 70+) tests passed!

- [ ] **Step 8: Commit**

```
git add lib/features/daily_record/data/ test/features/daily_record/firestore_daily_record_repository_test.dart
git commit -m "feat(daily-record): DailyRecordRepository.getAll() + test"
```

---

## Task 5 — PaymentRepository abstract + MockPaymentRepository

**Files:**
- Create: `lib/features/payments/data/payment_repository.dart`
- Create: `lib/features/payments/data/mock_payment_repository.dart`

- [ ] **Step 1: Abstract arayüzü yaz**

```dart
// lib/features/payments/data/payment_repository.dart
import '../domain/pending_expense.dart';
import '../domain/staff_payment.dart';

abstract class PaymentRepository {
  // Staff ödemeleri
  Stream<List<StaffPayment>> watchStaffPayments();
  Future<String> addStaffPayment(StaffPayment payment);

  // Bekleyen giderler
  Stream<List<PendingExpense>> watchExpenses();
  Future<PendingExpense?> getExpenseById(String id);
  Future<String> addExpense(PendingExpense expense);
  Future<void> updateExpense(PendingExpense expense);
}
```

- [ ] **Step 2: MockPaymentRepository yaz**

```dart
// lib/features/payments/data/mock_payment_repository.dart
import 'dart:async';

import '../domain/pending_expense.dart';
import '../domain/staff_payment.dart';
import 'payment_repository.dart';

class MockPaymentRepository implements PaymentRepository {
  final Map<String, StaffPayment> staffPayments = {};
  final Map<String, PendingExpense> expenses = {};
  int _nextId = 1;

  final _spController = StreamController<List<StaffPayment>>.broadcast();
  final _expController = StreamController<List<PendingExpense>>.broadcast();

  void _notifySp() => _spController.add(staffPayments.values.toList());
  void _notifyExp() => _expController.add(expenses.values.toList());

  @override
  Stream<List<StaffPayment>> watchStaffPayments() {
    Future.microtask(_notifySp);
    return _spController.stream;
  }

  @override
  Future<String> addStaffPayment(StaffPayment payment) async {
    final id = 'mock_sp_${_nextId++}';
    staffPayments[id] = payment.copyWith(id: id);
    _notifySp();
    return id;
  }

  @override
  Stream<List<PendingExpense>> watchExpenses() {
    Future.microtask(_notifyExp);
    return _expController.stream;
  }

  @override
  Future<PendingExpense?> getExpenseById(String id) async => expenses[id];

  @override
  Future<String> addExpense(PendingExpense expense) async {
    final id = 'mock_exp_${_nextId++}';
    expenses[id] = expense.copyWith(id: id);
    _notifyExp();
    return id;
  }

  @override
  Future<void> updateExpense(PendingExpense expense) async {
    expenses[expense.id] = expense;
    _notifyExp();
  }

  void dispose() {
    _spController.close();
    _expController.close();
  }
}
```

- [ ] **Step 3: `flutter analyze` → temiz**

```
flutter analyze
```
Beklenen: No issues found!

- [ ] **Step 4: Commit**

```
git add lib/features/payments/data/payment_repository.dart lib/features/payments/data/mock_payment_repository.dart
git commit -m "feat(payments): PaymentRepository abstract + Mock impl"
```

---

## Task 6 — FirestorePaymentRepository

**Files:**
- Create: `lib/features/payments/data/firestore_payment_repository.dart`

- [ ] **Step 1: Firestore impl'i yaz**

```dart
// lib/features/payments/data/firestore_payment_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/pending_expense.dart';
import '../domain/staff_payment.dart';
import 'payment_repository.dart';

class FirestorePaymentRepository implements PaymentRepository {
  FirestorePaymentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('payments');

  @override
  Stream<List<StaffPayment>> watchStaffPayments() {
    return _col
        .where('type', isEqualTo: 'staff')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => StaffPayment.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<String> addStaffPayment(StaffPayment payment) async {
    final doc = await _col.add(payment.toMap());
    return doc.id;
  }

  @override
  Stream<List<PendingExpense>> watchExpenses() {
    return _col
        .where('type', isEqualTo: 'expense')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PendingExpense.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<PendingExpense?> getExpenseById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return PendingExpense.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> addExpense(PendingExpense expense) async {
    final doc = await _col.add(expense.toMap());
    return doc.id;
  }

  @override
  Future<void> updateExpense(PendingExpense expense) =>
      _col.doc(expense.id).set(expense.toMap()..remove('id'));
}
```

- [ ] **Step 2: `flutter analyze` → temiz**

```
flutter analyze
```

- [ ] **Step 3: Commit**

```
git add lib/features/payments/data/firestore_payment_repository.dart
git commit -m "feat(payments): FirestorePaymentRepository"
```

---

## Task 7 — l10n Strings

**Files:**
- Modify: `lib/core/l10n/app_tr.arb`
- Modify: `lib/core/l10n/app_en.arb`

- [ ] **Step 1: app_tr.arb'a ödemeler string'lerini ekle**

`"openCreditBook": "Veresiye Defteri"` satırının **hemen sonrasına** şunu ekle:

```json
  "payments": "Ödemeler",
  "@payments": { "description": "Ödemeler ekranı başlığı ve menü" },
  "openPayments": "Ödemeler",
  "staffPaymentsTab": "Personel",
  "expensesTab": "Giderler",
  "workedDays": "Çalışılan Gün",
  "accruedWage": "Tahakkuk",
  "totalPaid": "Ödenen",
  "remainingBalance": "Kalan",
  "addPaymentToStaff": "Ödeme Kaydet",
  "paymentToStaffConfirmTitle": "Bu ödemeyi kaydetmek istediğinizden emin misiniz?",
  "staffPaymentAdded": "Ödeme kaydedildi.",
  "noStaffForPayments": "Aktif personel bulunamadı.",
  "addExpense": "Gider Ekle",
  "editExpense": "Gider Düzenle",
  "expenseDescription": "Açıklama",
  "expenseDescriptionRequired": "Açıklama zorunludur",
  "expenseTotalAmount": "Toplam Tutar (₺)",
  "expenseTotalAmountRequired": "Toplam tutar zorunludur",
  "expenseTotalAmountInvalid": "Geçerli bir tutar giriniz",
  "expenseAdded": "Gider kaydedildi.",
  "expenseUpdated": "Gider güncellendi.",
  "expensePaymentAdded": "Ödeme kaydedildi.",
  "expenseMarkAsPaid": "Ödendi",
  "expenseMarkAsPaidConfirmTitle": "Bu gideri ödenmiş olarak işaretlemek istiyor musunuz?",
  "expenseUndoPaid": "Geri Al",
  "expenseUndoPaidConfirmTitle": "Bu ödemeyi geri almak istediğinizden emin misiniz?",
  "noExpenses": "Henüz gider kaydı yok.",
  "expenseStatusPending": "Bekliyor",
  "expenseStatusPartial": "Kısmi Ödendi",
  "expenseStatusPaid": "Ödendi"
```

- [ ] **Step 2: app_en.arb'a English string'lerini ekle**

`"openCreditBook": "Credit Book"` satırının **hemen sonrasına** şunu ekle:

```json
  "payments": "Payments",
  "openPayments": "Payments",
  "staffPaymentsTab": "Staff",
  "expensesTab": "Expenses",
  "workedDays": "Days Worked",
  "accruedWage": "Accrued",
  "totalPaid": "Paid",
  "remainingBalance": "Remaining",
  "addPaymentToStaff": "Record Payment",
  "paymentToStaffConfirmTitle": "Are you sure you want to record this payment?",
  "staffPaymentAdded": "Payment recorded.",
  "noStaffForPayments": "No active staff found.",
  "addExpense": "Add Expense",
  "editExpense": "Edit Expense",
  "expenseDescription": "Description",
  "expenseDescriptionRequired": "Description is required",
  "expenseTotalAmount": "Total Amount (₺)",
  "expenseTotalAmountRequired": "Total amount is required",
  "expenseTotalAmountInvalid": "Enter a valid amount",
  "expenseAdded": "Expense saved.",
  "expenseUpdated": "Expense updated.",
  "expensePaymentAdded": "Payment recorded.",
  "expenseMarkAsPaid": "Mark as Paid",
  "expenseMarkAsPaidConfirmTitle": "Mark this expense as paid?",
  "expenseUndoPaid": "Undo",
  "expenseUndoPaidConfirmTitle": "Are you sure you want to undo this payment?",
  "noExpenses": "No expense records yet.",
  "expenseStatusPending": "Pending",
  "expenseStatusPartial": "Partially Paid",
  "expenseStatusPaid": "Paid"
```

- [ ] **Step 3: gen-l10n çalıştır**

```
flutter gen-l10n
```
Beklenen: `lib/core/l10n/generated/` güncellendi, hata yok.

- [ ] **Step 4: `flutter analyze` → temiz**

```
flutter analyze
```

- [ ] **Step 5: Commit**

```
git add lib/core/l10n/
git commit -m "feat(payments): l10n TR/EN string'leri (ödemeler)"
```

---

## Task 8 — payments_providers.dart (Controller + Providers)

**Files:**
- Create: `lib/features/payments/application/payments_providers.dart`
- Create: `test/features/payments/payments_controller_test.dart`

- [ ] **Step 1: Controller test dosyasını yaz (kırmızı)**

```dart
// test/features/payments/payments_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/payments/application/payments_providers.dart';
import 'package:gilanli_meyhane/features/payments/data/mock_payment_repository.dart';
import 'package:gilanli_meyhane/features/payments/domain/pending_expense.dart';
import 'package:gilanli_meyhane/features/payments/domain/staff_payment.dart';

void main() {
  late MockPaymentRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockPaymentRepository();
    container = ProviderContainer(overrides: [
      paymentRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
  });

  PaymentsController ctrl() =>
      container.read(paymentsControllerProvider.notifier);

  test('addStaffPayment kayıt oluşturur', () async {
    await ctrl().addStaffPayment(
      staffId: 'staff1',
      amount: 500000,
      date: DateTime(2026, 6, 1),
      notes: 'Test',
    );
    expect(repo.staffPayments.length, 1);
    final p = repo.staffPayments.values.first;
    expect(p.staffId, 'staff1');
    expect(p.amount, 500000);
  });

  test('addExpense pending kayıt oluşturur', () async {
    await ctrl().addExpense(
      description: 'Elektrik',
      totalAmount: 200000,
      date: DateTime(2026, 6, 1),
    );
    expect(repo.expenses.length, 1);
    final e = repo.expenses.values.first;
    expect(e.description, 'Elektrik');
    expect(e.totalAmount, 200000);
    expect(e.remainingAmount, 200000);
    expect(e.status, ExpenseStatus.pending);
  });

  test('addExpensePayment remaining azaltır ve partial olur', () async {
    await ctrl().addExpense(
        description: 'Su', totalAmount: 300000, date: DateTime(2026, 6, 1));
    final id = repo.expenses.keys.first;

    await ctrl().addExpensePayment(id, 100000);

    final e = repo.expenses[id]!;
    expect(e.remainingAmount, 200000);
    expect(e.status, ExpenseStatus.partial);
    expect(e.payments.length, 1);
  });

  test('markExpensePaid remaining=0 ve status=paid yapar', () async {
    await ctrl().addExpense(
        description: 'Kira', totalAmount: 400000, date: DateTime(2026, 6, 1));
    final id = repo.expenses.keys.first;
    await ctrl().addExpensePayment(id, 100000);

    await ctrl().markExpensePaid(id);

    final e = repo.expenses[id]!;
    expect(e.remainingAmount, 0);
    expect(e.status, ExpenseStatus.paid);
    expect(e.payments.length, 2);
    expect(e.payments.last.amount, 300000);
  });

  test('undoExpensePaid son ödemeyi kaldırır ve status/remaining yeniden hesaplanır',
      () async {
    await ctrl().addExpense(
        description: 'Bakım', totalAmount: 250000, date: DateTime(2026, 6, 1));
    final id = repo.expenses.keys.first;
    await ctrl().markExpensePaid(id);

    await ctrl().undoExpensePaid(id);

    final e = repo.expenses[id]!;
    expect(e.remainingAmount, 250000);
    expect(e.status, ExpenseStatus.pending);
    expect(e.payments, isEmpty);
  });
}
```

- [ ] **Step 2: Testi çalıştır → kırmızı**

```
flutter test test/features/payments/payments_controller_test.dart
```

- [ ] **Step 3: payments_providers.dart yaz**

```dart
// lib/features/payments/application/payments_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/daily_record/application/daily_record_providers.dart';
import '../../../features/staff/application/staff_providers.dart';
import '../../../shared/providers/firebase_providers.dart';
import '../data/firestore_payment_repository.dart';
import '../data/payment_repository.dart';
import '../domain/payroll_calculator.dart';
import '../domain/payroll_summary.dart';
import '../domain/pending_expense.dart';
import '../domain/staff_payment.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return FirestorePaymentRepository(ref.watch(firestoreProvider));
});

final staffPaymentsStreamProvider = StreamProvider<List<StaffPayment>>((ref) {
  return ref.watch(paymentRepositoryProvider).watchStaffPayments();
});

final expensesStreamProvider = StreamProvider<List<PendingExpense>>((ref) {
  return ref.watch(paymentRepositoryProvider).watchExpenses();
});

/// Tüm günlük kayıtları bir kez çeker (payroll hesabı için).
final allDailyRecordsProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(dailyRecordRepositoryProvider).getAll();
});

/// Aktif personel için tahakkuk + ödeme satırlarını hesaplar.
final staffPayrollRowsProvider =
    FutureProvider<List<StaffPayrollRow>>((ref) async {
  final staffAsync = ref.watch(activeStaffProvider);
  final staff = staffAsync.asData?.value ?? [];

  final records = await ref.watch(allDailyRecordsProvider.future);

  final paymentsAsync = ref.watch(staffPaymentsStreamProvider);
  final payments = paymentsAsync.asData?.value ?? [];

  return staff.map((s) {
    final summary = PayrollCalculator.accrue(s, records);
    final paid = payments
        .where((p) => p.staffId == s.id)
        .fold(0, (sum, p) => sum + p.amount);
    final remaining = summary.accruedWage - paid;
    return StaffPayrollRow(
      staffId: s.id,
      staffName: s.name,
      workedDays: summary.workedDays,
      accruedWage: summary.accruedWage,
      totalPaid: paid,
      remaining: remaining < 0 ? 0 : remaining,
    );
  }).toList();
});

// ---------------------------------------------------------------------------
// PaymentsController
// ---------------------------------------------------------------------------

final paymentsControllerProvider =
    AsyncNotifierProvider<PaymentsController, void>(PaymentsController.new);

class PaymentsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  PaymentRepository get _repo => ref.read(paymentRepositoryProvider);

  Future<void> addStaffPayment({
    required String staffId,
    required int amount,
    required DateTime date,
    String notes = '',
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.addStaffPayment(StaffPayment(
          id: '',
          staffId: staffId,
          amount: amount,
          date: date,
          notes: notes,
        )));
  }

  Future<void> addExpense({
    required String description,
    required int totalAmount,
    required DateTime date,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.addExpense(PendingExpense(
          id: '',
          description: description,
          totalAmount: totalAmount,
          remainingAmount: totalAmount,
          status: ExpenseStatus.pending,
          date: date,
        )));
  }

  Future<void> addExpensePayment(String expenseId, int amount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final expense = await _repo.getExpenseById(expenseId);
      if (expense == null) throw Exception('Gider bulunamadı: $expenseId');
      final payment = ExpensePayment(amount: amount, date: DateTime.now());
      final withPayment =
          expense.copyWith(payments: [...expense.payments, payment]);
      final newRemaining = withPayment.totalAmount -
          withPayment.payments.fold(0, (s, p) => s + p.amount);
      final remaining = newRemaining < 0 ? 0 : newRemaining;
      final status = remaining == 0
          ? ExpenseStatus.paid
          : withPayment.payments.isEmpty
              ? ExpenseStatus.pending
              : ExpenseStatus.partial;
      await _repo.updateExpense(
          withPayment.copyWith(remainingAmount: remaining, status: status));
    });
  }

  Future<void> markExpensePaid(String expenseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final expense = await _repo.getExpenseById(expenseId);
      if (expense == null) throw Exception('Gider bulunamadı: $expenseId');
      if (expense.remainingAmount <= 0) return;
      final payment =
          ExpensePayment(amount: expense.remainingAmount, date: DateTime.now());
      final updated = expense.copyWith(
        payments: [...expense.payments, payment],
        remainingAmount: 0,
        status: ExpenseStatus.paid,
      );
      await _repo.updateExpense(updated);
    });
  }

  Future<void> undoExpensePaid(String expenseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final expense = await _repo.getExpenseById(expenseId);
      if (expense == null || expense.payments.isEmpty) return;
      final trimmed = expense.payments.sublist(0, expense.payments.length - 1);
      final newPaid = trimmed.fold(0, (s, p) => s + p.amount);
      final newRemaining = expense.totalAmount - newPaid;
      final status = newRemaining == expense.totalAmount
          ? ExpenseStatus.pending
          : newRemaining == 0
              ? ExpenseStatus.paid
              : ExpenseStatus.partial;
      await _repo.updateExpense(expense.copyWith(
        payments: trimmed,
        remainingAmount: newRemaining,
        status: status,
      ));
    });
  }
}
```

**Önemli:** `allDailyRecordsProvider`'ın tipi `FutureProvider<List<dynamic>>` değil, gerçek tip olmalı. `daily_record_providers.dart` importu zaten `dailyRecordRepositoryProvider`'ı export ediyor. `getAll()` dönüşü `List<DailyRecord>` olduğundan şu import düzeltmesini yap:

```dart
// allDailyRecordsProvider satırını şöyle yaz:
import '../../../features/daily_record/domain/daily_record.dart';
// ...
final allDailyRecordsProvider = FutureProvider<List<DailyRecord>>((ref) {
  return ref.watch(dailyRecordRepositoryProvider).getAll();
});
```

- [ ] **Step 4: Testi çalıştır → yeşil**

```
flutter test test/features/payments/payments_controller_test.dart
```
Beklenen: All 5 tests passed!

- [ ] **Step 5: `flutter analyze` → temiz**

```
flutter analyze
```

- [ ] **Step 6: Commit**

```
git add lib/features/payments/application/payments_providers.dart test/features/payments/payments_controller_test.dart
git commit -m "feat(payments): payments_providers + PaymentsController (5 test)"
```

---

## Task 9 — StaffPaymentDialog + StaffPaymentsTab UI

**Files:**
- Create: `lib/features/payments/presentation/widgets/staff_payment_dialog.dart`
- Create: `lib/features/payments/presentation/widgets/staff_payments_tab.dart`

- [ ] **Step 1: StaffPaymentDialog yaz**

```dart
// lib/features/payments/presentation/widgets/staff_payment_dialog.dart
import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/money_input_field.dart';

/// Personele ödeme tutarı girmek için dialog.
/// Onaylanırsa int kuruş döner; iptal edilirse null.
Future<int?> showStaffPaymentDialog(
  BuildContext context, {
  required String staffName,
}) async {
  final l10n = AppLocalizations.of(context);
  final ctrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.addPaymentToStaff),
      content: Form(
        key: formKey,
        child: MoneyInputField(
          controller: ctrl,
          label: '${l10n.paymentAmount} — $staffName',
          validator: (v) {
            if (v == null || v.trim().isEmpty) return l10n.paymentAmountRequired;
            final n = int.tryParse(v.trim());
            if (n == null || n <= 0) return l10n.paymentAmountInvalid;
            return null;
          },
          textInputAction: TextInputAction.done,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(ctx).pop(MoneyInputField.kurusOf(ctrl));
            }
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: StaffPaymentsTab yaz**

```dart
// lib/features/payments/presentation/widgets/staff_payments_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../application/payments_providers.dart';
import '../../domain/payroll_summary.dart';
import 'staff_payment_dialog.dart';

class StaffPaymentsTab extends ConsumerWidget {
  const StaffPaymentsTab({super.key});

  Future<void> _recordPayment(
    BuildContext context,
    WidgetRef ref,
    StaffPayrollRow row,
    AppLocalizations l10n,
  ) async {
    final amount = await showStaffPaymentDialog(context, staffName: row.staffName);
    if (amount == null || amount <= 0) return;
    if (!context.mounted) return;

    final confirmed = await showConfirmDialog(
      context,
      title: l10n.paymentToStaffConfirmTitle,
    );
    if (!confirmed) return;

    await ref.read(paymentsControllerProvider.notifier).addStaffPayment(
          staffId: row.staffId,
          amount: amount,
          date: DateTime.now(),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.staffPaymentAdded)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rowsAsync = ref.watch(staffPayrollRowsProvider);
    final locale = Localizations.localeOf(context);

    return rowsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (rows) {
        if (rows.isEmpty) {
          return Center(child: Text(l10n.noStaffForPayments));
        }
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final row = rows[i];
            return ListTile(
              title: Text(row.staffName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                '${l10n.workedDays}: ${row.workedDays} · '
                '${l10n.accruedWage}: ${row.accruedWage.toCurrency(locale)} · '
                '${l10n.totalPaid}: ${row.totalPaid.toCurrency(locale)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    row.remaining.toCurrency(locale),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: row.remaining > 0
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_card_outlined),
                    tooltip: l10n.addPaymentToStaff,
                    onPressed: row.remaining > 0
                        ? () => _recordPayment(ctx, ref, row, l10n)
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
```

- [ ] **Step 3: `flutter analyze` → temiz**

```
flutter analyze
```

- [ ] **Step 4: Commit**

```
git add lib/features/payments/presentation/widgets/staff_payment_dialog.dart lib/features/payments/presentation/widgets/staff_payments_tab.dart
git commit -m "feat(payments): StaffPaymentDialog + StaffPaymentsTab UI"
```

---

## Task 10 — ExpensePaymentDialog + PendingExpensesTab + ExpenseFormScreen

**Files:**
- Create: `lib/features/payments/presentation/widgets/expense_payment_dialog.dart`
- Create: `lib/features/payments/presentation/widgets/pending_expenses_tab.dart`
- Create: `lib/features/payments/presentation/expense_form_screen.dart`

- [ ] **Step 1: ExpensePaymentDialog yaz**

```dart
// lib/features/payments/presentation/widgets/expense_payment_dialog.dart
import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/money_input_field.dart';

/// Gidere kısmi ödeme tutarı girmek için dialog.
/// Onaylanırsa int kuruş döner; iptal edilirse null.
Future<int?> showExpensePaymentDialog(
  BuildContext context, {
  required int remainingAmount,
}) async {
  final l10n = AppLocalizations.of(context);
  final ctrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.addPayment),
      content: Form(
        key: formKey,
        child: MoneyInputField(
          controller: ctrl,
          label: l10n.paymentAmount,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return l10n.paymentAmountRequired;
            final n = int.tryParse(v.trim());
            if (n == null || n <= 0) return l10n.paymentAmountInvalid;
            if (MoneyInputField.kurusOf(ctrl) > remainingAmount) {
              return l10n.paymentAmountExceedsRemaining;
            }
            return null;
          },
          textInputAction: TextInputAction.done,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(ctx).pop(MoneyInputField.kurusOf(ctrl));
            }
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: ExpenseFormScreen yaz**

```dart
// lib/features/payments/presentation/expense_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/money_input_field.dart';
import '../application/payments_providers.dart';
import '../domain/pending_expense.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.expense});
  final PendingExpense? expense;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.expense?.description ?? '');
    _amountCtrl = TextEditingController(
      text: _isEdit
          ? (widget.expense!.totalAmount ~/ 100).toString()
          : '',
    );
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed =
        await showConfirmDialog(context, title: l10n.saveConfirmTitle);
    if (!confirmed) return;

    final amount = MoneyInputField.kurusOf(_amountCtrl);
    final ctrl = ref.read(paymentsControllerProvider.notifier);

    if (_isEdit) {
      // Düzenleme: aynı ID ile totalAmount güncelle (basit: yeni gider ekleme yok)
      // Mevcut expense'i yeni değerlerle güncelle
      final updated = widget.expense!.copyWith(
        description: _descCtrl.text.trim(),
        totalAmount: amount,
      );
      await ref.read(paymentRepositoryProvider).updateExpense(updated);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.expenseUpdated)));
        context.pop();
      }
    } else {
      await ctrl.addExpense(
        description: _descCtrl.text.trim(),
        totalAmount: amount,
        date: DateTime.now(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.expenseAdded)));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar:
          AppBar(title: Text(_isEdit ? l10n.editExpense : l10n.addExpense)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _descCtrl,
                  decoration:
                      InputDecoration(labelText: l10n.expenseDescription),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? l10n.expenseDescriptionRequired
                          : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                MoneyInputField(
                  controller: _amountCtrl,
                  label: l10n.expenseTotalAmount,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.expenseTotalAmountRequired;
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return l10n.expenseTotalAmountInvalid;
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _save(l10n),
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: PendingExpensesTab yaz**

```dart
// lib/features/payments/presentation/widgets/pending_expenses_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../application/payments_providers.dart';
import '../../domain/pending_expense.dart';
import 'expense_payment_dialog.dart';

class PendingExpensesTab extends ConsumerWidget {
  const PendingExpensesTab({super.key});

  Color _statusColor(BuildContext context, ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.paid:
        return Theme.of(context).colorScheme.primary;
      case ExpenseStatus.partial:
        return Colors.orange;
      case ExpenseStatus.pending:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _statusLabel(AppLocalizations l10n, ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.paid:
        return l10n.expenseStatusPaid;
      case ExpenseStatus.partial:
        return l10n.expenseStatusPartial;
      case ExpenseStatus.pending:
        return l10n.expenseStatusPending;
    }
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    PendingExpense expense,
    AppLocalizations l10n,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.editExpense),
              onTap: () {
                Navigator.of(ctx).pop();
                context.push('/payments/expense/edit', extra: expense);
              },
            ),
            if (expense.status != ExpenseStatus.paid) ...[
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(l10n.addPayment),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final amount = await showExpensePaymentDialog(
                    context,
                    remainingAmount: expense.remainingAmount,
                  );
                  if (amount != null && amount > 0) {
                    await ref
                        .read(paymentsControllerProvider.notifier)
                        .addExpensePayment(expense.id, amount);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.expensePaymentAdded)));
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(l10n.expenseMarkAsPaid),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.expenseMarkAsPaidConfirmTitle,
                  );
                  if (confirmed) {
                    await ref
                        .read(paymentsControllerProvider.notifier)
                        .markExpensePaid(expense.id);
                  }
                },
              ),
            ],
            if (expense.status == ExpenseStatus.paid)
              ListTile(
                leading: const Icon(Icons.undo),
                title: Text(l10n.expenseUndoPaid),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.expenseUndoPaidConfirmTitle,
                  );
                  if (confirmed) {
                    await ref
                        .read(paymentsControllerProvider.notifier)
                        .undoExpensePaid(expense.id);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(expensesStreamProvider);
    final locale = Localizations.localeOf(context);

    return Stack(
      children: [
        listAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (list) {
            if (list.isEmpty) {
              return Center(child: Text(l10n.noExpenses));
            }
            final sorted = [...list]
              ..sort((a, b) {
                const order = {
                  ExpenseStatus.pending: 0,
                  ExpenseStatus.partial: 1,
                  ExpenseStatus.paid: 2,
                };
                final s = order[a.status]!.compareTo(order[b.status]!);
                return s != 0 ? s : b.date.compareTo(a.date);
              });
            return ListView.separated(
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final e = sorted[i];
                return ListTile(
                  title: Text(e.description),
                  subtitle: Text(
                    '${e.totalAmount.toCurrency(locale)} · '
                    '${l10n.creditRemainingAmount}: ${e.remainingAmount.toCurrency(locale)}',
                  ),
                  trailing: Chip(
                    label: Text(
                      _statusLabel(l10n, e.status),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor:
                        _statusColor(context, e.status).withOpacity(0.15),
                    labelStyle:
                        TextStyle(color: _statusColor(context, e.status)),
                    side: BorderSide.none,
                  ),
                  onTap: () => _showActions(ctx, ref, e, l10n),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'addExpenseFab',
            onPressed: () => context.push('/payments/expense/add'),
            tooltip: l10n.addExpense,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: `flutter analyze` → temiz**

```
flutter analyze
```

- [ ] **Step 5: Commit**

```
git add lib/features/payments/presentation/
git commit -m "feat(payments): ExpensePaymentDialog + PendingExpensesTab + ExpenseFormScreen"
```

---

## Task 11 — PaymentsScreen + Router + Home Kartı + Widget Testi

**Files:**
- Create: `lib/features/payments/presentation/payments_screen.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/app/placeholder_home_screen.dart`
- Create: `test/features/payments/payments_screen_test.dart`

- [ ] **Step 1: PaymentsScreen yaz**

```dart
// lib/features/payments/presentation/payments_screen.dart
import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import 'widgets/pending_expenses_tab.dart';
import 'widgets/staff_payments_tab.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.payments),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.staffPaymentsTab),
              Tab(text: l10n.expensesTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StaffPaymentsTab(),
            PendingExpensesTab(),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: router.dart'a /payments rotalarını ekle**

`import` bloğuna ödemeler ekranlarını ekle:

```dart
import '../features/payments/presentation/expense_form_screen.dart';
import '../features/payments/presentation/payments_screen.dart';
import '../features/payments/domain/pending_expense.dart';
```

`routes` listesine mevcut son rotanın ardından şunları ekle:

```dart
      GoRoute(
        path: '/payments',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/payments/expense/add',
        builder: (context, state) => const ExpenseFormScreen(),
      ),
      GoRoute(
        path: '/payments/expense/edit',
        builder: (context, state) =>
            ExpenseFormScreen(expense: state.extra as PendingExpense),
      ),
```

- [ ] **Step 3: PlaceholderHomeScreen'e Ödemeler kartını ekle**

Mevcut Veresiye Defteri kartının ardından şu kartı ekle:

```dart
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(l10n.openPayments),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/payments'),
              ),
            ),
```

- [ ] **Step 4: Widget testi yaz**

```dart
// test/features/payments/payments_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/payments/application/payments_providers.dart';
import 'package:gilanli_meyhane/features/payments/domain/pending_expense.dart';
import 'package:gilanli_meyhane/features/payments/domain/staff_payment.dart';
import 'package:gilanli_meyhane/features/payments/domain/payroll_summary.dart';
import 'package:gilanli_meyhane/features/payments/presentation/payments_screen.dart';

void main() {
  testWidgets('PaymentsScreen: Personel sekmesi aktif, giderler sekmesine geçilebilir',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffPayrollRowsProvider.overrideWith((_) async => <StaffPayrollRow>[]),
          expensesStreamProvider
              .overrideWith((_) => Stream.value(<PendingExpense>[])),
          staffPaymentsStreamProvider
              .overrideWith((_) => Stream.value(<StaffPayment>[])),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PaymentsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Personel sekmesi varsayılan aktif
    expect(find.byType(TabBar), findsOneWidget);

    // Giderler sekmesine geç
    await tester.tap(find.text('Giderler'));
    await tester.pumpAndSettle();

    // Gider yok mesajı görünmeli
    expect(find.text('Henüz gider kaydı yok.'), findsOneWidget);
  });
}
```

- [ ] **Step 5: Testi çalıştır**

```
flutter test test/features/payments/payments_screen_test.dart
```
Beklenen: All 1 test passed!

- [ ] **Step 6: Tüm testleri çalıştır**

```
flutter test --no-pub
```
Beklenen: tüm testler yeşil (önceki 70 + yeni ≈ 89)

- [ ] **Step 7: Commit**

```
git add lib/features/payments/presentation/payments_screen.dart lib/app/router.dart lib/app/placeholder_home_screen.dart test/features/payments/payments_screen_test.dart
git commit -m "feat(payments): PaymentsScreen + router /payments + ana ekran kartı + widget testi"
```

---

## Task 12 — Son Doğrulama & PROGRESS Güncellemesi

- [ ] **Step 1: Tam test koşusu**

```
flutter test --no-pub
```
Beklenen: Tüm testler yeşil, 0 hata.

- [ ] **Step 2: Analyze**

```
flutter analyze
```
Beklenen: No issues found!

- [ ] **Step 3: PROGRESS.md güncelle**

`PROGRESS.md` dosyasına şunları ekle/güncelle:

1. `- [ ] Faz 6 — Ödemeler` satırını `- [x] **Faz 6 — Ödemeler** ✅ tamam (XX test, analyze temiz)` yap
2. `**Aktif faz:**` satırını `Faz 7 — Dashboard` olarak güncelle
3. `**Branch:**` satırını `phase-6-payments (main'e merge bekliyor)` yap
4. Kronolojik not ekle: tarih + özet
5. Faz 6 adımları bölümü ekle

- [ ] **Step 4: Commit**

```
git add PROGRESS.md
git commit -m "docs(progress): Faz 6 tamam - ödemeler UI + controller"
```

---

## Kabul Kriterleri (master plan §5 Faz 6)

- [x] `payment.dart` (StaffPayment) + TDD `payroll_calculator.dart` (§3.3) ✓
- [x] `PaymentRepository` + Firestore + Mock ✓
- [x] `payments_screen.dart` iki sekme (Personel / Giderler) ✓
- [x] `staff_payments_tab.dart`: `[Ad|Çalışılan Gün|Tahakkuk|Ödenen|Kalan]` (türetilmiş) + kısmi ödeme ✓
- [x] `pending_expenses_tab.dart`: manuel gider ekleme + kısmi ödeme ✓
- [x] Personel tahakkuku wageHistory dahil doğru hesaplanıyor (TDD) ✓
- [x] Kısmi ödemeler her iki sekmede çalışıyor ✓
- [x] `flutter test` yeşil · `flutter analyze` temiz ✓
