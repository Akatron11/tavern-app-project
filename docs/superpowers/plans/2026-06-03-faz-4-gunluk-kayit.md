# Faz 4 — Günlük Kayıt (Daily Record) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Kemal'in her iş gününü tek ekrandan girip düzenleyebildiği, canlı kasa toplamları gösteren ve veresiyeyi `creditSales` koleksiyonuna yansıtan Günlük Kayıt özelliğini inşa etmek.

**Architecture:** Feature-first katmanlı (`domain`/`data`/`application`/`presentation`). Para tamamen `int` kuruş; günlük kasa yalnızca saf `DailyRecordCalculator` ile hesaplanır (Faz 0'da yazıldı, patron masrafı kasayı etkilemez). Firestore'a yalnızca repository katmanı erişir. Günlük kayıt belge kimliği = `dayKey(date)` (yyyy-MM-dd) → gün başına tek kayıt, doğal upsert. Veresiye girilince bağlı `CreditSale` oluşturulur/mutabık kılınır (`reconcile`, §3.4); personel tahakkuku **yazılmaz**, yalnızca `workingStaffIds` saklanır (§1.2 — tahakkuk Faz 6'da türetilir).

**Tech Stack:** Flutter / Dart · Riverpod (AsyncNotifier) · cloud_firestore · go_router · intl + gen-l10n (TR/EN) · equatable. Test: flutter_test, fake_cloud_firestore, mocktail. **Yeni bağımlılık yok.**

---

## Kapsam Notu (faz sınırları)

- **CreditSale Faz 4'e çekildi:** Faz 4'ün kendi kalemleri ("Veresiye girilince `creditSales`'e yazım + `linkedDailyRecordId`" ve "Düzenleme akışı + veresiye **mutabakatı** (§1.3)") `CreditSale` modeli + `reconcile` olmadan karşılanamaz. Bu nedenle bu fazda **minimal** `CreditSale` modeli + `CreditStatus` enum + `CreditReconciler.reconcile` (TDD, §3.4) + `CreditSaleRepository` üçlüsü yazılır. **Faz 5** bunları yeniden kullanarak yalnızca Veresiye Defteri UI'ını (liste, manuel ekleme formu, kısmi/tam ödeme dialog'u, "Ödendi" geri alma) ekler.
- **Personel tahakkuku yazılmaz:** §1.2 gereği tahakkuk `dailyRecords.workingStaffIds` + `staff.wageHistory`'den **türetilir**. Faz 4 yalnızca `workingStaffIds`'i kayda yazar; `payments` koleksiyonuna hiçbir şey yazılmaz (o Faz 6).
- **Para girişi:** Kullanıcı **tam lira** girer (ondalık yok); `liraToKurus` ile saklanır. Gösterim `formatCurrency` (TR varsayılan).
- **Tarih saklama:** Model `date`'i `toIso8601String()` ile saklar (Staff deseniyle aynı; Firebase-bağımsız domain). Belge kimliği `dayKey(date)`.

---

## File Structure

**Yeni dosyalar:**
- `lib/features/daily_record/domain/daily_record.dart` — DailyRecord modeli (immutable, equatable, map dönüşümleri)
- `lib/features/daily_record/data/daily_record_repository.dart` — abstract arayüz
- `lib/features/daily_record/data/firestore_daily_record_repository.dart` — canlı impl
- `lib/features/daily_record/data/mock_daily_record_repository.dart` — bellek-içi impl (dev/test)
- `lib/features/daily_record/application/daily_record_providers.dart` — repo provider'ları + `DailyRecordController.saveRecord` orkestrasyonu
- `lib/features/daily_record/presentation/daily_record_screen.dart` — form ekranı
- `lib/features/daily_record/presentation/widgets/live_totals_card.dart` — canlı kasa kartı
- `lib/features/daily_record/presentation/widgets/staff_multiselect.dart` — aktif personel çoklu seçim
- `lib/features/credit_book/domain/credit_sale.dart` — CreditSale modeli + CreditStatus + CreditPayment
- `lib/features/credit_book/domain/credit_reconciler.dart` — `reconcile` saf fonksiyonu (§3.4)
- `lib/features/credit_book/data/credit_sale_repository.dart` — abstract arayüz
- `lib/features/credit_book/data/firestore_credit_sale_repository.dart` — canlı impl
- `lib/features/credit_book/data/mock_credit_sale_repository.dart` — bellek-içi impl
- `lib/shared/widgets/money_input_field.dart` — yeniden kullanılabilir para (lira) giriş alanı
- `test/features/daily_record/daily_record_model_test.dart`
- `test/features/daily_record/firestore_daily_record_repository_test.dart`
- `test/features/daily_record/daily_record_controller_test.dart`
- `test/features/daily_record/live_totals_card_test.dart`
- `test/features/daily_record/daily_record_screen_test.dart`
- `test/features/credit_book/credit_sale_model_test.dart`
- `test/features/credit_book/credit_reconcile_test.dart`
- `test/features/credit_book/firestore_credit_sale_repository_test.dart`

**Değişecek dosyalar:**
- `lib/core/l10n/app_tr.arb` / `lib/core/l10n/app_en.arb` — Faz 4 string'leri
- `lib/app/router.dart` — `/daily` rotası
- `lib/app/placeholder_home_screen.dart` — Günlük Kayıt + Personel hızlı erişim kartları
- `PROGRESS.md` — faz durumu güncellemesi

---

## Task 0: Çalışma dalı

- [ ] **Step 1: Faz 4 dalını aç**

Run:
```bash
git checkout -b phase-4-daily-record
```
Expected: `Switched to a new branch 'phase-4-daily-record'`

---

## Task 1: DailyRecord modeli (TDD roundtrip)

**Files:**
- Create: `lib/features/daily_record/domain/daily_record.dart`
- Test: `test/features/daily_record/daily_record_model_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/daily_record/daily_record_model_test.dart`:
```dart
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
```

- [ ] **Step 2: Testi çalıştır, başarısız olduğunu doğrula**

Run: `flutter test test/features/daily_record/daily_record_model_test.dart`
Expected: FAIL — `daily_record.dart` yok / `DailyRecord` tanımlı değil.

- [ ] **Step 3: Modeli yaz**

`lib/features/daily_record/domain/daily_record.dart`:
```dart
import 'package:equatable/equatable.dart';

/// Bir iş gününün kasa kaydı. Tüm tutarlar **int kuruş**.
/// Belge kimliği `id` = `dayKey(date)` (yyyy-MM-dd) → gün başına tek kayıt.
class DailyRecord extends Equatable {
  final String id;
  final DateTime date;
  final int revenue; // toplam ciro (+)
  final int creditCard; // kredi kartı toplamı (−)
  final int tips; // toplam bahşiş (+)
  final int ownerExpenses; // masraf — patron karşılar (kasayı ETKİLEMEZ)
  final int cashExpenses; // masraf — kasadan çıkar (−)
  final int creditSales; // veresiye (−)
  final String creditCustomerName; // veresiye müşteri adı ('' = yok)
  final int previousDayCash; // dünden kalan kasa (+)
  final int dailyCash; // hesaplanmış günlük kasa (saklanır)
  final int totalCash; // hesaplanmış toplam kasa (saklanır)
  final List<String> workingStaffIds; // o gün çalışan personel id'leri
  final String? linkedCreditSaleId; // bağlı creditSales dokümanı (varsa)
  final String notes;

  const DailyRecord({
    required this.id,
    required this.date,
    required this.revenue,
    required this.creditCard,
    required this.tips,
    required this.ownerExpenses,
    required this.cashExpenses,
    required this.creditSales,
    this.creditCustomerName = '',
    required this.previousDayCash,
    required this.dailyCash,
    required this.totalCash,
    this.workingStaffIds = const [],
    this.linkedCreditSaleId,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'revenue': revenue,
        'creditCard': creditCard,
        'tips': tips,
        'ownerExpenses': ownerExpenses,
        'cashExpenses': cashExpenses,
        'creditSales': creditSales,
        'creditCustomerName': creditCustomerName,
        'previousDayCash': previousDayCash,
        'dailyCash': dailyCash,
        'totalCash': totalCash,
        'workingStaffIds': workingStaffIds,
        'linkedCreditSaleId': linkedCreditSaleId,
        'notes': notes,
      };

  factory DailyRecord.fromMap(String id, Map<String, dynamic> map) =>
      DailyRecord(
        id: id,
        date: DateTime.parse(map['date'] as String),
        revenue: (map['revenue'] as num).toInt(),
        creditCard: (map['creditCard'] as num).toInt(),
        tips: (map['tips'] as num).toInt(),
        ownerExpenses: (map['ownerExpenses'] as num).toInt(),
        cashExpenses: (map['cashExpenses'] as num).toInt(),
        creditSales: (map['creditSales'] as num).toInt(),
        creditCustomerName: map['creditCustomerName'] as String? ?? '',
        previousDayCash: (map['previousDayCash'] as num).toInt(),
        dailyCash: (map['dailyCash'] as num).toInt(),
        totalCash: (map['totalCash'] as num).toInt(),
        workingStaffIds:
            (map['workingStaffIds'] as List<dynamic>?)?.cast<String>() ??
                const [],
        linkedCreditSaleId: map['linkedCreditSaleId'] as String?,
        notes: map['notes'] as String? ?? '',
      );

  DailyRecord copyWith({
    String? id,
    DateTime? date,
    int? revenue,
    int? creditCard,
    int? tips,
    int? ownerExpenses,
    int? cashExpenses,
    int? creditSales,
    String? creditCustomerName,
    int? previousDayCash,
    int? dailyCash,
    int? totalCash,
    List<String>? workingStaffIds,
    String? linkedCreditSaleId,
    String? notes,
  }) =>
      DailyRecord(
        id: id ?? this.id,
        date: date ?? this.date,
        revenue: revenue ?? this.revenue,
        creditCard: creditCard ?? this.creditCard,
        tips: tips ?? this.tips,
        ownerExpenses: ownerExpenses ?? this.ownerExpenses,
        cashExpenses: cashExpenses ?? this.cashExpenses,
        creditSales: creditSales ?? this.creditSales,
        creditCustomerName: creditCustomerName ?? this.creditCustomerName,
        previousDayCash: previousDayCash ?? this.previousDayCash,
        dailyCash: dailyCash ?? this.dailyCash,
        totalCash: totalCash ?? this.totalCash,
        workingStaffIds: workingStaffIds ?? this.workingStaffIds,
        linkedCreditSaleId: linkedCreditSaleId ?? this.linkedCreditSaleId,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [
        id,
        date,
        revenue,
        creditCard,
        tips,
        ownerExpenses,
        cashExpenses,
        creditSales,
        creditCustomerName,
        previousDayCash,
        dailyCash,
        totalCash,
        workingStaffIds,
        linkedCreditSaleId,
        notes,
      ];
}
```

> Not: `copyWith` ile `linkedCreditSaleId`'yi `null`'a çekmek mümkün değildir (Faz 4 buna ihtiyaç duymaz — silme yok kuralı; bağlı kayıt sıfırlanınca `reconcile` ile `paid/0` olur, referans korunur).

- [ ] **Step 4: Testi çalıştır, geçtiğini doğrula**

Run: `flutter test test/features/daily_record/daily_record_model_test.dart`
Expected: PASS (4 test).

- [ ] **Step 5: Commit**

```bash
git add lib/features/daily_record/domain/daily_record.dart test/features/daily_record/daily_record_model_test.dart
git commit -m "feat(daily-record): DailyRecord modeli + roundtrip testleri"
```

---

## Task 2: DailyRecordRepository (abstract + Firestore + Mock)

**Files:**
- Create: `lib/features/daily_record/data/daily_record_repository.dart`
- Create: `lib/features/daily_record/data/firestore_daily_record_repository.dart`
- Create: `lib/features/daily_record/data/mock_daily_record_repository.dart`
- Test: `test/features/daily_record/firestore_daily_record_repository_test.dart`

- [ ] **Step 1: Failing test yaz (fake_cloud_firestore)**

`test/features/daily_record/firestore_daily_record_repository_test.dart`:
```dart
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
```

- [ ] **Step 2: Testi çalıştır, başarısız olduğunu doğrula**

Run: `flutter test test/features/daily_record/firestore_daily_record_repository_test.dart`
Expected: FAIL — repo sınıfları yok.

- [ ] **Step 3: Abstract arayüzü yaz**

`lib/features/daily_record/data/daily_record_repository.dart`:
```dart
import '../domain/daily_record.dart';

abstract class DailyRecordRepository {
  /// `dayKey` (yyyy-MM-dd) ile o günün kaydını getirir; yoksa `null`.
  Future<DailyRecord?> getByDay(String dayKey);

  /// Kaydı `dayKey` doküman kimliğiyle upsert eder (ekle veya güncelle).
  Future<void> save(DailyRecord record);
}
```

- [ ] **Step 4: Firestore impl'ini yaz**

`lib/features/daily_record/data/firestore_daily_record_repository.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/daily_record.dart';
import 'daily_record_repository.dart';

class FirestoreDailyRecordRepository implements DailyRecordRepository {
  FirestoreDailyRecordRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('dailyRecords');

  @override
  Future<DailyRecord?> getByDay(String dayKey) async {
    final doc = await _col.doc(dayKey).get();
    if (!doc.exists || doc.data() == null) return null;
    return DailyRecord.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> save(DailyRecord record) =>
      _col.doc(record.id).set(record.toMap()..remove('id'));
}
```

- [ ] **Step 5: Mock impl'ini yaz**

`lib/features/daily_record/data/mock_daily_record_repository.dart`:
```dart
import '../domain/daily_record.dart';
import 'daily_record_repository.dart';

class MockDailyRecordRepository implements DailyRecordRepository {
  final Map<String, DailyRecord> store = {};

  @override
  Future<DailyRecord?> getByDay(String dayKey) async => store[dayKey];

  @override
  Future<void> save(DailyRecord record) async {
    store[record.id] = record;
  }
}
```

- [ ] **Step 6: Testi çalıştır, geçtiğini doğrula**

Run: `flutter test test/features/daily_record/firestore_daily_record_repository_test.dart`
Expected: PASS (3 test).

- [ ] **Step 7: Commit**

```bash
git add lib/features/daily_record/data test/features/daily_record/firestore_daily_record_repository_test.dart
git commit -m "feat(daily-record): repository üçlüsü (abstract/firestore/mock) + fake firestore testleri"
```

---

## Task 3: CreditSale modeli + CreditStatus + CreditPayment (TDD roundtrip)

**Files:**
- Create: `lib/features/credit_book/domain/credit_sale.dart`
- Test: `test/features/credit_book/credit_sale_model_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/credit_book/credit_sale_model_test.dart`:
```dart
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
```

- [ ] **Step 2: Testi çalıştır, başarısız olduğunu doğrula**

Run: `flutter test test/features/credit_book/credit_sale_model_test.dart`
Expected: FAIL — `credit_sale.dart` yok.

- [ ] **Step 3: Modeli yaz**

`lib/features/credit_book/domain/credit_sale.dart`:
```dart
import 'package:equatable/equatable.dart';

enum CreditStatus {
  pending,
  partial,
  paid;

  static CreditStatus fromString(String value) => CreditStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => CreditStatus.pending,
      );
}

class CreditPayment extends Equatable {
  final int amount; // kuruş
  final DateTime date;

  const CreditPayment({required this.amount, required this.date});

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory CreditPayment.fromMap(Map<String, dynamic> map) => CreditPayment(
        amount: (map['amount'] as num).toInt(),
        date: DateTime.parse(map['date'] as String),
      );

  @override
  List<Object?> get props => [amount, date];
}

class CreditSale extends Equatable {
  final String id;
  final String customerName;
  final int totalAmount; // kuruş
  final int remainingAmount; // kuruş
  final DateTime date;
  final CreditStatus status;
  final List<CreditPayment> payments;
  final String? linkedDailyRecordId;

  const CreditSale({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.remainingAmount,
    required this.date,
    required this.status,
    this.payments = const [],
    this.linkedDailyRecordId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'customerName': customerName,
        'totalAmount': totalAmount,
        'remainingAmount': remainingAmount,
        'date': date.toIso8601String(),
        'status': status.name,
        'payments': payments.map((p) => p.toMap()).toList(),
        'linkedDailyRecordId': linkedDailyRecordId,
      };

  factory CreditSale.fromMap(String id, Map<String, dynamic> map) => CreditSale(
        id: id,
        customerName: map['customerName'] as String,
        totalAmount: (map['totalAmount'] as num).toInt(),
        remainingAmount: (map['remainingAmount'] as num).toInt(),
        date: DateTime.parse(map['date'] as String),
        status: CreditStatus.fromString(map['status'] as String),
        payments: (map['payments'] as List<dynamic>?)
                ?.map((e) => CreditPayment.fromMap(e as Map<String, dynamic>))
                .toList() ??
            const [],
        linkedDailyRecordId: map['linkedDailyRecordId'] as String?,
      );

  CreditSale copyWith({
    String? id,
    String? customerName,
    int? totalAmount,
    int? remainingAmount,
    DateTime? date,
    CreditStatus? status,
    List<CreditPayment>? payments,
    String? linkedDailyRecordId,
  }) =>
      CreditSale(
        id: id ?? this.id,
        customerName: customerName ?? this.customerName,
        totalAmount: totalAmount ?? this.totalAmount,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        date: date ?? this.date,
        status: status ?? this.status,
        payments: payments ?? this.payments,
        linkedDailyRecordId: linkedDailyRecordId ?? this.linkedDailyRecordId,
      );

  @override
  List<Object?> get props => [
        id,
        customerName,
        totalAmount,
        remainingAmount,
        date,
        status,
        payments,
        linkedDailyRecordId,
      ];
}
```

- [ ] **Step 4: Testi çalıştır, geçtiğini doğrula**

Run: `flutter test test/features/credit_book/credit_sale_model_test.dart`
Expected: PASS (3 test).

- [ ] **Step 5: Commit**

```bash
git add lib/features/credit_book/domain/credit_sale.dart test/features/credit_book/credit_sale_model_test.dart
git commit -m "feat(credit-book): CreditSale modeli (status + payments) + roundtrip testleri"
```

---

## Task 4: CreditReconciler.reconcile (TDD §3.4)

**Files:**
- Create: `lib/features/credit_book/domain/credit_reconciler.dart`
- Test: `test/features/credit_book/credit_reconcile_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/credit_book/credit_reconcile_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_reconciler.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';

CreditSale base({
  int total = 100000,
  int remaining = 100000,
  CreditStatus status = CreditStatus.pending,
  List<CreditPayment> payments = const [],
}) =>
    CreditSale(
      id: 'cs1',
      customerName: 'Ahmet',
      totalAmount: total,
      remainingAmount: remaining,
      date: DateTime(2026, 6, 3),
      status: status,
      payments: payments,
      linkedDailyRecordId: '2026-06-03',
    );

void main() {
  group('CreditReconciler.reconcile', () {
    test('payments boş & remaining==newTotal -> pending', () {
      final r = CreditReconciler.reconcile(base(), newTotal: 80000);
      expect(r.totalAmount, 80000);
      expect(r.remainingAmount, 80000);
      expect(r.status, CreditStatus.pending);
    });

    test('kısmi ödeme varken 0<remaining<newTotal -> partial', () {
      final sale = base(payments: [
        CreditPayment(amount: 30000, date: DateTime(2026, 6, 4)),
      ]);
      final r = CreditReconciler.reconcile(sale, newTotal: 100000);
      expect(r.remainingAmount, 70000);
      expect(r.status, CreditStatus.partial);
    });

    test('ödemeler toplamı newTotal\'a eşit -> paid, remaining 0', () {
      final sale = base(payments: [
        CreditPayment(amount: 100000, date: DateTime(2026, 6, 4)),
      ]);
      final r = CreditReconciler.reconcile(sale, newTotal: 100000);
      expect(r.remainingAmount, 0);
      expect(r.status, CreditStatus.paid);
    });

    test('newTotal=0 (veresiye sıfırlandı) & payments boş -> paid, remaining 0', () {
      final r = CreditReconciler.reconcile(base(), newTotal: 0);
      expect(r.totalAmount, 0);
      expect(r.remainingAmount, 0);
      expect(r.status, CreditStatus.paid);
    });

    test('fazla ödeme (sum>newTotal) remaining 0\'a kırpılır -> paid', () {
      final sale = base(payments: [
        CreditPayment(amount: 120000, date: DateTime(2026, 6, 4)),
      ]);
      final r = CreditReconciler.reconcile(sale, newTotal: 100000);
      expect(r.remainingAmount, 0);
      expect(r.status, CreditStatus.paid);
    });
  });
}
```

- [ ] **Step 2: Testi çalıştır, başarısız olduğunu doğrula**

Run: `flutter test test/features/credit_book/credit_reconcile_test.dart`
Expected: FAIL — `credit_reconciler.dart` yok.

- [ ] **Step 3: reconcile'i yaz**

`lib/features/credit_book/domain/credit_reconciler.dart`:
```dart
import 'dart:math' as math;

import 'credit_sale.dart';

/// Veresiye mutabakatı (saf fonksiyon, §3.4).
///
/// `remaining = max(0, newTotal − Σpayments)`; durum yeniden hesaplanır:
/// - `remaining == 0` → paid
/// - payments boş & `remaining == newTotal` → pending
/// - aksi halde → partial
class CreditReconciler {
  const CreditReconciler._();

  static CreditSale reconcile(CreditSale sale, {required int newTotal}) {
    final paid = sale.payments.fold<int>(0, (sum, p) => sum + p.amount);
    final remaining = math.max(0, newTotal - paid);

    final CreditStatus status;
    if (remaining == 0) {
      status = CreditStatus.paid;
    } else if (sale.payments.isEmpty && remaining == newTotal) {
      status = CreditStatus.pending;
    } else {
      status = CreditStatus.partial;
    }

    return sale.copyWith(
      totalAmount: newTotal,
      remainingAmount: remaining,
      status: status,
    );
  }
}
```

- [ ] **Step 4: Testi çalıştır, geçtiğini doğrula**

Run: `flutter test test/features/credit_book/credit_reconcile_test.dart`
Expected: PASS (5 test).

- [ ] **Step 5: Commit**

```bash
git add lib/features/credit_book/domain/credit_reconciler.dart test/features/credit_book/credit_reconcile_test.dart
git commit -m "feat(credit-book): CreditReconciler.reconcile (§3.4) TDD"
```

---

## Task 5: CreditSaleRepository (abstract + Firestore + Mock)

**Files:**
- Create: `lib/features/credit_book/data/credit_sale_repository.dart`
- Create: `lib/features/credit_book/data/firestore_credit_sale_repository.dart`
- Create: `lib/features/credit_book/data/mock_credit_sale_repository.dart`
- Test: `test/features/credit_book/firestore_credit_sale_repository_test.dart`

> Faz 4 yalnızca `add`/`update`/`getById` kullanır. `watchAll` ve liste sorguları Faz 5'te eklenecektir (YAGNI).

- [ ] **Step 1: Failing test yaz**

`test/features/credit_book/firestore_credit_sale_repository_test.dart`:
```dart
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
```

- [ ] **Step 2: Testi çalıştır, başarısız olduğunu doğrula**

Run: `flutter test test/features/credit_book/firestore_credit_sale_repository_test.dart`
Expected: FAIL — repo sınıfları yok.

- [ ] **Step 3: Abstract arayüzü yaz**

`lib/features/credit_book/data/credit_sale_repository.dart`:
```dart
import '../domain/credit_sale.dart';

abstract class CreditSaleRepository {
  Future<String> add(CreditSale sale);
  Future<void> update(CreditSale sale);
  Future<CreditSale?> getById(String id);
}
```

- [ ] **Step 4: Firestore impl'ini yaz**

`lib/features/credit_book/data/firestore_credit_sale_repository.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/credit_sale.dart';
import 'credit_sale_repository.dart';

class FirestoreCreditSaleRepository implements CreditSaleRepository {
  FirestoreCreditSaleRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('creditSales');

  @override
  Future<String> add(CreditSale sale) async {
    final ref = await _col.add(sale.toMap()..remove('id'));
    return ref.id;
  }

  @override
  Future<void> update(CreditSale sale) =>
      _col.doc(sale.id).update(sale.toMap()..remove('id'));

  @override
  Future<CreditSale?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return CreditSale.fromMap(doc.id, doc.data()!);
  }
}
```

- [ ] **Step 5: Mock impl'ini yaz**

`lib/features/credit_book/data/mock_credit_sale_repository.dart`:
```dart
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
```

- [ ] **Step 6: Testi çalıştır, geçtiğini doğrula**

Run: `flutter test test/features/credit_book/firestore_credit_sale_repository_test.dart`
Expected: PASS (3 test).

- [ ] **Step 7: Commit**

```bash
git add lib/features/credit_book/data test/features/credit_book/firestore_credit_sale_repository_test.dart
git commit -m "feat(credit-book): CreditSaleRepository üçlüsü + fake firestore testleri"
```

---

## Task 6: daily_record_providers.dart — save orkestrasyonu (TDD, mock repo)

**Files:**
- Create: `lib/features/daily_record/application/daily_record_providers.dart`
- Test: `test/features/daily_record/daily_record_controller_test.dart`

- [ ] **Step 1: Failing test yaz (ProviderContainer + mock repo override)**

`test/features/daily_record/daily_record_controller_test.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/credit_book/data/credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/credit_book/data/mock_credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';
import 'package:gilanli_meyhane/features/daily_record/application/daily_record_providers.dart';
import 'package:gilanli_meyhane/features/daily_record/data/daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';

void main() {
  late MockDailyRecordRepository dailyRepo;
  late MockCreditSaleRepository creditRepo;
  late ProviderContainer container;

  setUp(() {
    dailyRepo = MockDailyRecordRepository();
    creditRepo = MockCreditSaleRepository();
    container = ProviderContainer(overrides: [
      dailyRecordRepositoryProvider.overrideWithValue(dailyRepo),
      creditSaleRepositoryProvider.overrideWithValue(creditRepo),
    ]);
    addTearDown(container.dispose);
  });

  Future<void> save({
    required DateTime date,
    int revenue = 0,
    int creditCard = 0,
    int tips = 0,
    int ownerExpenses = 0,
    int cashExpenses = 0,
    int creditSales = 0,
    String creditCustomerName = '',
    int previousDayCash = 0,
    List<String> workingStaffIds = const [],
  }) {
    return container.read(dailyRecordControllerProvider.notifier).saveRecord(
          date: date,
          revenue: revenue,
          creditCard: creditCard,
          tips: tips,
          ownerExpenses: ownerExpenses,
          cashExpenses: cashExpenses,
          creditSales: creditSales,
          creditCustomerName: creditCustomerName,
          previousDayCash: previousDayCash,
          workingStaffIds: workingStaffIds,
          notes: '',
        );
  }

  test('kayıt dayKey ile saklanır; dailyCash/totalCash hesaplanır (patron hariç)', () async {
    await save(
      date: DateTime(2026, 6, 3, 14, 30),
      revenue: 1000000,
      creditCard: 300000,
      tips: 50000,
      ownerExpenses: 20000, // kasayı ETKİLEMEMELİ
      cashExpenses: 30000,
      creditSales: 100000,
      previousDayCash: 200000,
      workingStaffIds: ['s1', 's2'],
    );

    final rec = dailyRepo.store['2026-06-03'];
    expect(rec, isNotNull);
    expect(rec!.dailyCash, 620000); // 1.000.000 - 300.000 + 50.000 - 30.000 - 100.000
    expect(rec.totalCash, 820000);
    expect(rec.workingStaffIds, ['s1', 's2']);
    expect(rec.date.hour, 0); // gece yarısına normalize
  });

  test('veresiye>0 ise bağlı CreditSale oluşturulur ve id kayda yazılır', () async {
    await save(
      date: DateTime(2026, 6, 3),
      revenue: 100000,
      creditSales: 40000,
      creditCustomerName: 'Ahmet',
    );

    expect(creditRepo.store.length, 1);
    final sale = creditRepo.store.values.first;
    expect(sale.customerName, 'Ahmet');
    expect(sale.totalAmount, 40000);
    expect(sale.remainingAmount, 40000);
    expect(sale.status, CreditStatus.pending);
    expect(sale.linkedDailyRecordId, '2026-06-03');

    final rec = dailyRepo.store['2026-06-03']!;
    expect(rec.linkedCreditSaleId, sale.id);
  });

  test('düzenlemede veresiye değişince bağlı CreditSale mutabık kılınır (yeni doküman yaratılmaz)', () async {
    await save(date: DateTime(2026, 6, 3), creditSales: 40000, creditCustomerName: 'Ahmet');
    await save(date: DateTime(2026, 6, 3), creditSales: 60000, creditCustomerName: 'Ahmet');

    expect(creditRepo.store.length, 1); // hâlâ tek doküman
    final sale = creditRepo.store.values.first;
    expect(sale.totalAmount, 60000);
    expect(sale.remainingAmount, 60000);
  });

  test('düzenlemede veresiye sıfırlanınca bağlı CreditSale paid/0 olur (silme yok)', () async {
    await save(date: DateTime(2026, 6, 3), creditSales: 40000, creditCustomerName: 'Ahmet');
    await save(date: DateTime(2026, 6, 3), creditSales: 0);

    expect(creditRepo.store.length, 1);
    final sale = creditRepo.store.values.first;
    expect(sale.remainingAmount, 0);
    expect(sale.status, CreditStatus.paid);
    // bağlı referans korunur
    expect(dailyRepo.store['2026-06-03']!.linkedCreditSaleId, sale.id);
  });

  test('veresiye yoksa CreditSale oluşturulmaz', () async {
    await save(date: DateTime(2026, 6, 3), revenue: 100000);
    expect(creditRepo.store, isEmpty);
    expect(dailyRepo.store['2026-06-03']!.linkedCreditSaleId, isNull);
  });
}
```

- [ ] **Step 2: Testi çalıştır, başarısız olduğunu doğrula**

Run: `flutter test test/features/daily_record/daily_record_controller_test.dart`
Expected: FAIL — provider'lar yok.

- [ ] **Step 3: Provider + controller yaz**

`lib/features/daily_record/application/daily_record_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../shared/providers/firebase_providers.dart';
import '../../credit_book/data/credit_sale_repository.dart';
import '../../credit_book/data/firestore_credit_sale_repository.dart';
import '../../credit_book/domain/credit_reconciler.dart';
import '../../credit_book/domain/credit_sale.dart';
import '../data/daily_record_repository.dart';
import '../data/firestore_daily_record_repository.dart';
import '../domain/daily_record.dart';
import '../domain/daily_record_calculator.dart';

final dailyRecordRepositoryProvider = Provider<DailyRecordRepository>((ref) {
  return FirestoreDailyRecordRepository(ref.watch(firestoreProvider));
});

final creditSaleRepositoryProvider = Provider<CreditSaleRepository>((ref) {
  return FirestoreCreditSaleRepository(ref.watch(firestoreProvider));
});

final dailyRecordControllerProvider =
    AsyncNotifierProvider<DailyRecordController, void>(DailyRecordController.new);

class DailyRecordController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  DailyRecordRepository get _dailyRepo =>
      ref.read(dailyRecordRepositoryProvider);
  CreditSaleRepository get _creditRepo =>
      ref.read(creditSaleRepositoryProvider);

  /// Günlük kaydı kaydeder (upsert), veresiyeyi `creditSales`'e yansıtır.
  /// Patron masrafı kasayı etkilemez (DailyRecordCalculator).
  Future<void> saveRecord({
    required DateTime date,
    required int revenue,
    required int creditCard,
    required int tips,
    required int ownerExpenses,
    required int cashExpenses,
    required int creditSales,
    required String creditCustomerName,
    required int previousDayCash,
    required List<String> workingStaffIds,
    required String notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final day = DateTime(date.year, date.month, date.day);
      final key = dayKey(day);

      final existing = await _dailyRepo.getByDay(key);
      final linkedId = await _syncCreditSale(
        existingLinkedId: existing?.linkedCreditSaleId,
        day: day,
        key: key,
        creditSales: creditSales,
        customerName: creditCustomerName,
      );

      final daily = DailyRecordCalculator.dailyCash(
        revenue: revenue,
        creditCard: creditCard,
        tips: tips,
        cashExpenses: cashExpenses,
        creditSales: creditSales,
      );
      final total = DailyRecordCalculator.totalCash(previousDayCash, daily);

      await _dailyRepo.save(DailyRecord(
        id: key,
        date: day,
        revenue: revenue,
        creditCard: creditCard,
        tips: tips,
        ownerExpenses: ownerExpenses,
        cashExpenses: cashExpenses,
        creditSales: creditSales,
        creditCustomerName: creditCustomerName,
        previousDayCash: previousDayCash,
        dailyCash: daily,
        totalCash: total,
        workingStaffIds: workingStaffIds,
        linkedCreditSaleId: linkedId,
        notes: notes,
      ));
    });
  }

  /// Bağlı veresiyeyi oluşturur/mutabık kılar; güncel `linkedCreditSaleId` döner.
  Future<String?> _syncCreditSale({
    required String? existingLinkedId,
    required DateTime day,
    required String key,
    required int creditSales,
    required String customerName,
  }) async {
    if (creditSales > 0) {
      if (existingLinkedId != null) {
        final sale = await _creditRepo.getById(existingLinkedId);
        if (sale != null) {
          final updated = CreditReconciler.reconcile(
            sale.copyWith(customerName: customerName),
            newTotal: creditSales,
          );
          await _creditRepo.update(updated);
          return existingLinkedId;
        }
      }
      // yeni veresiye dokümanı
      return _creditRepo.add(CreditSale(
        id: '',
        customerName: customerName,
        totalAmount: creditSales,
        remainingAmount: creditSales,
        date: day,
        status: CreditStatus.pending,
        linkedDailyRecordId: key,
      ));
    }

    // creditSales == 0: bağlı kayıt varsa paid/0'a mutabık kıl (silme yok)
    if (existingLinkedId != null) {
      final sale = await _creditRepo.getById(existingLinkedId);
      if (sale != null) {
        await _creditRepo.update(
          CreditReconciler.reconcile(sale, newTotal: 0),
        );
      }
    }
    return existingLinkedId;
  }
}
```

- [ ] **Step 4: Testi çalıştır, geçtiğini doğrula**

Run: `flutter test test/features/daily_record/daily_record_controller_test.dart`
Expected: PASS (5 test).

- [ ] **Step 5: Commit**

```bash
git add lib/features/daily_record/application/daily_record_providers.dart test/features/daily_record/daily_record_controller_test.dart
git commit -m "feat(daily-record): save orkestrasyonu (veresiye mutabakatı dahil) + controller testleri"
```

---

## Task 7: l10n string'leri (TR/EN) + gen-l10n

**Files:**
- Modify: `lib/core/l10n/app_tr.arb`
- Modify: `lib/core/l10n/app_en.arb`

- [ ] **Step 1: TR string'lerini ekle**

`lib/core/l10n/app_tr.arb` içinde son anahtar `"inactive": "Pasif"` satırından önceki `}` kapanışını bozmadan, `"inactive"` satırından sonra virgül ekleyip aşağıdaki blok eklenir (mevcut `"inactive": "Pasif"` satırını `"inactive": "Pasif",` yap):
```json
  "dailyRecord": "Günlük Kayıt",
  "@dailyRecord": { "description": "Günlük kayıt ekranı başlığı ve menü" },
  "recordDate": "İş Günü Tarihi",
  "revenue": "Toplam Ciro",
  "creditCardTotal": "Kredi Kartı Toplamı",
  "totalTips": "Toplam Bahşiş",
  "ownerExpense": "Masraf (Patron Karşılar)",
  "cashExpense": "Masraf (Kasadan Çıkar)",
  "creditSale": "Veresiye Satış",
  "creditCustomer": "Müşteri Adı",
  "previousDayCash": "Dünden Kalan Kasa",
  "workingStaff": "Çalışan Personeller",
  "notes": "Notlar",
  "liveTotals": "Canlı Toplamlar",
  "totalExpense": "Toplam Masraf",
  "dailyCash": "Günlük Kasa",
  "totalCash": "Toplam Kasa",
  "noActiveStaff": "Aktif personel bulunmuyor.",
  "creditCustomerRequired": "Veresiye için müşteri adı zorunludur",
  "dailyRecordSaved": "Günlük kayıt kaydedildi.",
  "openStaff": "Personel",
  "openDailyRecord": "Günlük Kayıt"
```

> Not: `"openDailyRecord"` ile `"dailyRecord"` aynı metni taşır ama farklı bağlamlar (kart vs başlık); ayrı tutmak gelecekte metin ayrışmasına izin verir. Tek bir anahtar kullanmak isterseniz `dailyRecord`'u her ikisinde kullanın ve `openDailyRecord`'u eklemeyin.

- [ ] **Step 2: EN string'lerini ekle**

`lib/core/l10n/app_en.arb` içinde `"inactive": "Inactive"` satırını `"inactive": "Inactive",` yapıp ardından:
```json
  "dailyRecord": "Daily Record",
  "recordDate": "Work Day Date",
  "revenue": "Total Revenue",
  "creditCardTotal": "Credit Card Total",
  "totalTips": "Total Tips",
  "ownerExpense": "Expense (Owner Pays)",
  "cashExpense": "Expense (From Cash)",
  "creditSale": "Credit Sale",
  "creditCustomer": "Customer Name",
  "previousDayCash": "Previous Day Cash",
  "workingStaff": "Working Staff",
  "notes": "Notes",
  "liveTotals": "Live Totals",
  "totalExpense": "Total Expense",
  "dailyCash": "Daily Cash",
  "totalCash": "Total Cash",
  "noActiveStaff": "No active staff.",
  "creditCustomerRequired": "Customer name is required for a credit sale",
  "dailyRecordSaved": "Daily record saved.",
  "openStaff": "Staff",
  "openDailyRecord": "Daily Record"
```

- [ ] **Step 3: gen-l10n çalıştır**

Run: `flutter gen-l10n`
Expected: hatasız üretim; `lib/core/l10n/generated/app_localizations*.dart` güncellenir.

- [ ] **Step 4: Analyze ile doğrula**

Run: `flutter analyze`
Expected: 0 issue.

- [ ] **Step 5: Commit**

```bash
git add lib/core/l10n
git commit -m "feat(l10n): Faz 4 günlük kayıt string'leri (TR/EN)"
```

---

## Task 8: MoneyInputField (paylaşılan widget)

**Files:**
- Create: `lib/shared/widgets/money_input_field.dart`

- [ ] **Step 1: Widget'ı yaz**

`lib/shared/widgets/money_input_field.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/money/money.dart';

/// Tam **lira** girişi alan, yalnızca rakam kabul eden para alanı.
/// Saklama kuruş bazlıdır; [kurusValue] ile kuruş değeri okunur.
class MoneyInputField extends StatelessWidget {
  const MoneyInputField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  /// Alandaki tam lira değerini kuruşa çevirir (boş/eksikse 0).
  static int kurusOf(TextEditingController controller) =>
      liraToKurus(int.tryParse(controller.text.trim()) ?? 0);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: '₺',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: textInputAction,
      onChanged: onChanged,
    );
  }
}
```

- [ ] **Step 2: Analyze ile doğrula**

Run: `flutter analyze lib/shared/widgets/money_input_field.dart`
Expected: 0 issue.

- [ ] **Step 3: Commit**

```bash
git add lib/shared/widgets/money_input_field.dart
git commit -m "feat(shared): MoneyInputField (lira girişi → kuruş)"
```

---

## Task 9: LiveTotalsCard (+ widget testi)

**Files:**
- Create: `lib/features/daily_record/presentation/widgets/live_totals_card.dart`
- Test: `test/features/daily_record/live_totals_card_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/daily_record/live_totals_card_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/daily_record/presentation/widgets/live_totals_card.dart';

Widget wrap(Widget child) => MaterialApp(
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('günlük kasa ve toplam kasa doğru hesaplanıp gösterilir', (tester) async {
    await tester.pumpWidget(wrap(const LiveTotalsCard(
      revenue: 1000000,
      creditCard: 300000,
      tips: 50000,
      ownerExpenses: 20000,
      cashExpenses: 30000,
      creditSales: 100000,
      previousDayCash: 200000,
    )));

    // dailyCash = 620.000 kuruş -> 6.200 ₺ ; totalCash = 820.000 -> 8.200 ₺
    expect(find.byKey(const Key('dailyCashValue')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('dailyCashValue'))).data,
      '6.200 ₺',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('totalCashValue'))).data,
      '8.200 ₺',
    );
    // toplam masraf = patron + kasa = 50.000 kuruş -> 500 ₺
    expect(
      tester.widget<Text>(find.byKey(const Key('totalExpenseValue'))).data,
      '500 ₺',
    );
  });

  testWidgets('patron masrafı günlük kasayı etkilemez', (tester) async {
    await tester.pumpWidget(wrap(const LiveTotalsCard(
      revenue: 500000,
      creditCard: 0,
      tips: 0,
      ownerExpenses: 9999900, // çok büyük patron masrafı
      cashExpenses: 10000,
      creditSales: 0,
      previousDayCash: 0,
    )));

    // dailyCash = 500.000 - 10.000 = 490.000 -> 4.900 ₺ (patron hariç)
    expect(
      tester.widget<Text>(find.byKey(const Key('dailyCashValue'))).data,
      '4.900 ₺',
    );
  });
}
```

- [ ] **Step 2: Testi çalıştır, başarısız olduğunu doğrula**

Run: `flutter test test/features/daily_record/live_totals_card_test.dart`
Expected: FAIL — `LiveTotalsCard` yok.

- [ ] **Step 3: Widget'ı yaz**

`lib/features/daily_record/presentation/widgets/live_totals_card.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/money/currency_formatter.dart';
import '../../domain/daily_record_calculator.dart';

/// Girilen değerlerden günlük/toplam kasayı **canlı** hesaplayıp gösterir.
/// Hesaplama tek kaynak: [DailyRecordCalculator] (patron masrafı kasayı
/// etkilemez; iki masraf kalemi ayrı gösterilir).
class LiveTotalsCard extends StatelessWidget {
  const LiveTotalsCard({
    super.key,
    required this.revenue,
    required this.creditCard,
    required this.tips,
    required this.ownerExpenses,
    required this.cashExpenses,
    required this.creditSales,
    required this.previousDayCash,
  });

  final int revenue;
  final int creditCard;
  final int tips;
  final int ownerExpenses;
  final int cashExpenses;
  final int creditSales;
  final int previousDayCash;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final daily = DailyRecordCalculator.dailyCash(
      revenue: revenue,
      creditCard: creditCard,
      tips: tips,
      cashExpenses: cashExpenses,
      creditSales: creditSales,
    );
    final total = DailyRecordCalculator.totalCash(previousDayCash, daily);
    final totalExpense =
        DailyRecordCalculator.totalExpensesDisplay(ownerExpenses, cashExpenses);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.liveTotals,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.spaceSm),
            _row(context, l10n.ownerExpense, formatCurrency(ownerExpenses, locale: locale),
                key: const Key('ownerExpenseValue')),
            _row(context, l10n.cashExpense, formatCurrency(cashExpenses, locale: locale),
                key: const Key('cashExpenseValue')),
            _row(context, l10n.totalExpense, formatCurrency(totalExpense, locale: locale),
                key: const Key('totalExpenseValue')),
            const Divider(),
            _row(context, l10n.dailyCash, formatCurrency(daily, locale: locale),
                key: const Key('dailyCashValue'), emphasize: true),
            _row(context, l10n.totalCash, formatCurrency(total, locale: locale),
                key: const Key('totalCashValue'), emphasize: true),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {required Key key, bool emphasize = false}) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, key: key, style: style),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Testi çalıştır, geçtiğini doğrula**

Run: `flutter test test/features/daily_record/live_totals_card_test.dart`
Expected: PASS (2 test).

- [ ] **Step 5: Commit**

```bash
git add lib/features/daily_record/presentation/widgets/live_totals_card.dart test/features/daily_record/live_totals_card_test.dart
git commit -m "feat(daily-record): LiveTotalsCard (canlı kasa, patron masrafı ayrı) + testleri"
```

---

## Task 10: StaffMultiSelect (aktif personel çoklu seçim)

**Files:**
- Create: `lib/features/daily_record/presentation/widgets/staff_multiselect.dart`

> Kontrollü bileşen: seçim durumunu ebeveyn (ekran) tutar; widget yalnızca gösterir ve `onChanged` ile bildirir. `activeStaffProvider` (Faz 3) yeniden kullanılır.

- [ ] **Step 1: Widget'ı yaz**

`lib/features/daily_record/presentation/widgets/staff_multiselect.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../staff/application/staff_providers.dart';

/// Aktif personeli FilterChip listesi olarak gösterir; seçilen id'leri
/// [onChanged] ile bildirir.
class StaffMultiSelect extends ConsumerWidget {
  const StaffMultiSelect({
    super.key,
    required this.selectedIds,
    required this.onChanged,
  });

  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final staffAsync = ref.watch(activeStaffProvider);

    return staffAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSizes.spaceSm),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => Text(e.toString()),
      data: (staff) {
        if (staff.isEmpty) {
          return Text(l10n.noActiveStaff);
        }
        return Wrap(
          spacing: AppSizes.spaceSm,
          runSpacing: AppSizes.spaceXs,
          children: staff.map((s) {
            final selected = selectedIds.contains(s.id);
            return FilterChip(
              label: Text(s.name),
              selected: selected,
              onSelected: (value) {
                final next = [...selectedIds];
                if (value) {
                  next.add(s.id);
                } else {
                  next.remove(s.id);
                }
                onChanged(next);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Analyze ile doğrula**

Run: `flutter analyze lib/features/daily_record/presentation/widgets/staff_multiselect.dart`
Expected: 0 issue.

- [ ] **Step 3: Commit**

```bash
git add lib/features/daily_record/presentation/widgets/staff_multiselect.dart
git commit -m "feat(daily-record): StaffMultiSelect (aktif personel çoklu seçim)"
```

---

## Task 11: DailyRecordScreen (form)

**Files:**
- Create: `lib/features/daily_record/presentation/daily_record_screen.dart`

- [ ] **Step 1: Ekranı yaz**

`lib/features/daily_record/presentation/daily_record_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/money_input_field.dart';
import '../application/daily_record_providers.dart';
import '../domain/daily_record.dart';
import 'widgets/live_totals_card.dart';
import 'widgets/staff_multiselect.dart';

class DailyRecordScreen extends ConsumerStatefulWidget {
  const DailyRecordScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  ConsumerState<DailyRecordScreen> createState() => _DailyRecordScreenState();
}

class _DailyRecordScreenState extends ConsumerState<DailyRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _revenueCtrl = TextEditingController();
  final _creditCardCtrl = TextEditingController();
  final _tipsCtrl = TextEditingController();
  final _ownerExpenseCtrl = TextEditingController();
  final _cashExpenseCtrl = TextEditingController();
  final _creditSaleCtrl = TextEditingController();
  final _creditCustomerCtrl = TextEditingController();
  final _previousDayCashCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late DateTime _date;
  List<String> _selectedStaffIds = [];

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
    _loadForDate(_date);
  }

  @override
  void dispose() {
    _revenueCtrl.dispose();
    _creditCardCtrl.dispose();
    _tipsCtrl.dispose();
    _ownerExpenseCtrl.dispose();
    _cashExpenseCtrl.dispose();
    _creditSaleCtrl.dispose();
    _creditCustomerCtrl.dispose();
    _previousDayCashCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  int _kurus(TextEditingController c) => MoneyInputField.kurusOf(c);
  String _lira(int kurus) => kurus == 0 ? '' : (kurus ~/ 100).toString();

  Future<void> _loadForDate(DateTime date) async {
    final key = dayKey(DateTime(date.year, date.month, date.day));
    final rec = await ref.read(dailyRecordRepositoryProvider).getByDay(key);
    if (!mounted) return;
    setState(() {
      _revenueCtrl.text = _lira(rec?.revenue ?? 0);
      _creditCardCtrl.text = _lira(rec?.creditCard ?? 0);
      _tipsCtrl.text = _lira(rec?.tips ?? 0);
      _ownerExpenseCtrl.text = _lira(rec?.ownerExpenses ?? 0);
      _cashExpenseCtrl.text = _lira(rec?.cashExpenses ?? 0);
      _creditSaleCtrl.text = _lira(rec?.creditSales ?? 0);
      _creditCustomerCtrl.text = rec?.creditCustomerName ?? '';
      _previousDayCashCtrl.text = _lira(rec?.previousDayCash ?? 0);
      _notesCtrl.text = rec?.notes ?? '';
      _selectedStaffIds = List<String>.from(rec?.workingStaffIds ?? const []);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
      await _loadForDate(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);

    final ok = await showConfirmDialog(context, title: l10n.saveConfirmTitle);
    if (!ok) return;

    await ref.read(dailyRecordControllerProvider.notifier).saveRecord(
          date: _date,
          revenue: _kurus(_revenueCtrl),
          creditCard: _kurus(_creditCardCtrl),
          tips: _kurus(_tipsCtrl),
          ownerExpenses: _kurus(_ownerExpenseCtrl),
          cashExpenses: _kurus(_cashExpenseCtrl),
          creditSales: _kurus(_creditSaleCtrl),
          creditCustomerName: _creditCustomerCtrl.text.trim(),
          previousDayCash: _kurus(_previousDayCashCtrl),
          workingStaffIds: _selectedStaffIds,
          notes: _notesCtrl.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(dailyRecordControllerProvider);
    if (state is! AsyncError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.dailyRecordSaved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saving = ref.watch(dailyRecordControllerProvider).isLoading;

    ref.listen(dailyRecordControllerProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dailyRecord)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}), // canlı toplam için
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            children: [
              // Tarih
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(l10n.recordDate),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(_date)),
                trailing: const Icon(Icons.edit),
                onTap: _pickDate,
              ),
              const SizedBox(height: AppSizes.spaceSm),

              MoneyInputField(controller: _revenueCtrl, label: l10n.revenue),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(
                  controller: _creditCardCtrl, label: l10n.creditCardTotal),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(controller: _tipsCtrl, label: l10n.totalTips),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(
                  controller: _ownerExpenseCtrl, label: l10n.ownerExpense),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(
                  controller: _cashExpenseCtrl, label: l10n.cashExpense),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(
                  controller: _creditSaleCtrl, label: l10n.creditSale),
              const SizedBox(height: AppSizes.spaceMd),
              TextFormField(
                controller: _creditCustomerCtrl,
                decoration: InputDecoration(labelText: l10n.creditCustomer),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  // Veresiye girilmişse müşteri adı zorunlu
                  if (_kurus(_creditSaleCtrl) > 0 &&
                      (v == null || v.trim().isEmpty)) {
                    return l10n.creditCustomerRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(
                controller: _previousDayCashCtrl,
                label: l10n.previousDayCash,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSizes.spaceLg),

              // Çalışan personeller
              Text(l10n.workingStaff,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSizes.spaceSm),
              StaffMultiSelect(
                selectedIds: _selectedStaffIds,
                onChanged: (ids) => setState(() => _selectedStaffIds = ids),
              ),
              const SizedBox(height: AppSizes.spaceLg),

              // Notlar
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(labelText: l10n.notes),
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.spaceLg),

              // Canlı toplamlar
              LiveTotalsCard(
                revenue: _kurus(_revenueCtrl),
                creditCard: _kurus(_creditCardCtrl),
                tips: _kurus(_tipsCtrl),
                ownerExpenses: _kurus(_ownerExpenseCtrl),
                cashExpenses: _kurus(_cashExpenseCtrl),
                creditSales: _kurus(_creditSaleCtrl),
                previousDayCash: _kurus(_previousDayCashCtrl),
              ),
              const SizedBox(height: AppSizes.spaceLg),

              SizedBox(
                height: AppSizes.minTouchTarget,
                child: ElevatedButton(
                  onPressed: saving ? null : _submit,
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

> Not: `Form.onChanged` her alan değişiminde `setState` tetikleyerek `LiveTotalsCard`'ı günceller — bu "alanlar değişince canlı toplam" gereksinimini karşılar (Task 13 testi bunu doğrular).

- [ ] **Step 2: Analyze ile doğrula**

Run: `flutter analyze lib/features/daily_record/presentation/daily_record_screen.dart`
Expected: 0 issue.

- [ ] **Step 3: Commit**

```bash
git add lib/features/daily_record/presentation/daily_record_screen.dart
git commit -m "feat(daily-record): DailyRecordScreen (tüm alanlar, canlı toplam, kaydet onayı)"
```

---

## Task 12: Router /daily rotası + ana ekran hızlı erişim

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `lib/app/placeholder_home_screen.dart`

- [ ] **Step 1: /daily rotasını ekle**

`lib/app/router.dart` — importlara ekle:
```dart
import '../features/daily_record/presentation/daily_record_screen.dart';
```
`routes:` listesinde `/staff` rotasından sonra ekle:
```dart
      GoRoute(
        path: '/daily',
        builder: (context, state) => const DailyRecordScreen(),
      ),
```

- [ ] **Step 2: Ana ekrana hızlı erişim kartları ekle**

`lib/app/placeholder_home_screen.dart` — importlara `go_router` ekle:
```dart
import 'package:go_router/go_router.dart';
```
`body: Center(child: Text(l10n.greeting('Kemal')))` satırını şununla değiştir:
```dart
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.greeting('Kemal'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(l10n.openDailyRecord),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/daily'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.people),
                title: Text(l10n.openStaff),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/staff'),
              ),
            ),
          ],
        ),
      ),
```

- [ ] **Step 3: Analyze + mevcut testlerin hâlâ geçtiğini doğrula**

Run: `flutter analyze`
Expected: 0 issue.

Run: `flutter test test/features/auth/login_screen_test.dart`
Expected: PASS (login testi `PlaceholderHomeScreen`'i hâlâ buluyor — değişiklik yalnızca gövdeyi genişletti).

- [ ] **Step 4: Commit**

```bash
git add lib/app/router.dart lib/app/placeholder_home_screen.dart
git commit -m "feat(daily-record): /daily rotası + ana ekran hızlı erişim kartları"
```

---

## Task 13: DailyRecordScreen widget testi (canlı toplam güncellenmesi)

**Files:**
- Test: `test/features/daily_record/daily_record_screen_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/daily_record/daily_record_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/credit_book/data/credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/credit_book/data/mock_credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/application/daily_record_providers.dart';
import 'package:gilanli_meyhane/features/daily_record/data/daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/presentation/daily_record_screen.dart';
import 'package:gilanli_meyhane/features/daily_record/presentation/widgets/live_totals_card.dart';
import 'package:gilanli_meyhane/features/staff/application/staff_providers.dart';
import 'package:gilanli_meyhane/features/staff/data/mock_staff_repository.dart';
import 'package:gilanli_meyhane/features/staff/data/staff_repository.dart';

Widget buildApp({
  required DailyRecordRepository dailyRepo,
  required CreditSaleRepository creditRepo,
  required StaffRepository staffRepo,
}) {
  return ProviderScope(
    overrides: [
      dailyRecordRepositoryProvider.overrideWithValue(dailyRepo),
      creditSaleRepositoryProvider.overrideWithValue(creditRepo),
      staffRepositoryProvider.overrideWithValue(staffRepo),
    ],
    child: const MaterialApp(
      locale: Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: DailyRecordScreen(),
    ),
  );
}

void main() {
  testWidgets('ciro girilince günlük kasa canlı güncellenir', (tester) async {
    await tester.pumpWidget(buildApp(
      dailyRepo: MockDailyRecordRepository(),
      creditRepo: MockCreditSaleRepository(),
      staffRepo: MockStaffRepository(),
    ));
    await tester.pumpAndSettle();

    // Başlangıçta günlük kasa 0 ₺
    expect(
      tester.widget<Text>(find.byKey(const Key('dailyCashValue'))).data,
      '0 ₺',
    );

    // Toplam Ciro alanına 10000 (lira) gir -> 1.000.000 kuruş
    final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.revenue),
      '10000',
    );
    await tester.pump();

    // Günlük kasa = 10.000 ₺ ; canlı kart güncellenmeli
    expect(find.byType(LiveTotalsCard), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('dailyCashValue'))).data,
      '10.000 ₺',
    );
  });
}
```

- [ ] **Step 2: Testi çalıştır, geçtiğini doğrula**

Run: `flutter test test/features/daily_record/daily_record_screen_test.dart`
Expected: PASS (1 test).

> Eğer `MockStaffRepository.watchActive()` stream'i pump sırasında veri yaymazsa `pumpAndSettle` askıda kalmaz çünkü `_notify` `Future.microtask` ile boş liste yayar; `StaffMultiSelect` `noActiveStaff` metnini gösterir. Test yine geçer (canlı toplam kartı personelden bağımsızdır).

- [ ] **Step 3: Commit**

```bash
git add test/features/daily_record/daily_record_screen_test.dart
git commit -m "test(daily-record): ekran canlı toplam güncelleme widget testi"
```

---

## Task 14: Faz 4 doğrulama + PROGRESS güncelleme

**Files:**
- Modify: `PROGRESS.md`

- [ ] **Step 1: Tüm test paketini çalıştır**

Run: `flutter test`
Expected: TÜM testler PASS. (Faz 0–3: 37 + Faz 4: model 4 + dailyRepo 3 + creditModel 3 + reconcile 5 + creditRepo 3 + controller 5 + liveCard 2 + screen 1 = 26 yeni → toplam ~63.)

- [ ] **Step 2: Analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: superpowers:verification-before-completion çağır**

Kanıtları (test sayısı + analyze çıktısı) topla; iddiaları çıktıyla doğrula.

- [ ] **Step 4: PROGRESS.md güncelle**

`PROGRESS.md` içinde:
- `- [ ] Faz 4 — Günlük Kayıt` satırını `- [x] **Faz 4 — Günlük Kayıt** ✅ tamam (...test, analyze temiz)` yap (gerçek test sayısını yaz).
- "Aktif faz" satırını `Faz 5 — Veresiye Defteri` yap.
- "Kayıt / Notlar" bölümüne kronolojik bir özet ekle (CreditSale'in Faz 4'e çekildiği notu dahil).
- Faz 4 adımları için yeni bir "## Faz 4 — Adımlar" bölümü ekle (bu plandaki task'ları işaretli olarak).

- [ ] **Step 5: Commit**

```bash
git add PROGRESS.md
git commit -m "docs(progress): Faz 4 tamam — günlük kayıt + veresiye yansıması"
```

- [ ] **Step 6: Dalı tamamla**

`superpowers:finishing-a-development-branch` ile seçenekleri sun (main'e FF merge / PR / branch'te bırak). Önceki fazların deseni: `main`'e FF merge + dal silme.

---

## Self-Review Notları

- **Spec kapsamı (§4.3):** tarih, ciro, kredi kartı, bahşiş, iki masraf alanı (patron/kasa), veresiye + müşteri adı, dünden kalan, çalışan personel, canlı toplamlar, kaydet onayı, düzenleme — tümü Task 11 + 6 + 9'da. ✅
- **Master plan Faz 4 kalemleri:** model (T1), repo (T2), providers/orkestrasyon (T6), ekran + iki masraf alanı (T11), live_totals_card (T9), bahşiş alanı (T11), staff_multiselect (T10), veresiye→creditSales + linkedCreditSaleId (T6), düzenleme + mutabakat §1.3 (T6), widget testi (T13). ✅
- **§1.7 patron masrafı kasayı etkilemez:** Calculator imzasında `ownerExpenses` yok; LiveTotalsCard testi ve controller testi bunu açıkça doğrular. ✅
- **§1.2 personel tahakkuku türetilir:** Faz 4 yalnızca `workingStaffIds` saklar; `payments`'a yazım yok. ✅
- **Placeholder taraması:** tüm adımlar tam kod içeriyor; "TODO/TBD/uygun hata yönetimi" yok. ✅
- **Tip tutarlılığı:** `getByDay(String)`, `save(DailyRecord)`, `reconcile(CreditSale,{newTotal})`, `saveRecord({...})`, `MoneyInputField.kurusOf`, `LiveTotalsCard({revenue,...})` tüm task'larda birebir aynı. ✅
- **Onay/geri-alma:** kaydet onay dialog'u (T11); silme yok (veresiye sıfırlanınca paid/0, referans korunur — T6). ✅
```