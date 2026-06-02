# Faz 5 — Veresiye Defteri (Credit Book) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Veresiye defteri UI'ını ekle: liste, manuel ekleme/düzenleme, kısmi ödeme, "Ödendi" + geri alma.

**Architecture:** Faz 4'te `CreditSale` modeli, `CreditReconciler` ve `CreditSaleRepository` üçlüsü zaten tamamlandı. Bu fazda: (1) repo'ya `watchAll()` ekle, (2) feature-bazlı `credit_book_providers.dart` yaz (`CreditBookController`: addSale/addPayment/markPaid/undoPaid), (3) liste + form + ödeme dialog'u ekle, (4) router ve ana ekrana kart ekle. `creditSaleRepositoryProvider` `daily_record_providers.dart`'tan `credit_book_providers.dart`'a taşınır; import chain güncellenir.

**Tech Stack:** Flutter · Riverpod 3.x · GoRouter · fake_cloud_firestore (test) · `CreditReconciler` (zaten var)

---

## Dosya Haritası

| İşlem | Dosya |
|---|---|
| Modify | `lib/features/credit_book/data/credit_sale_repository.dart` |
| Modify | `lib/features/credit_book/data/firestore_credit_sale_repository.dart` |
| Modify | `lib/features/credit_book/data/mock_credit_sale_repository.dart` |
| Create | `lib/features/credit_book/application/credit_book_providers.dart` |
| Modify | `lib/features/daily_record/application/daily_record_providers.dart` |
| Create | `lib/features/credit_book/presentation/credit_list_screen.dart` |
| Create | `lib/features/credit_book/presentation/credit_form.dart` |
| Create | `lib/features/credit_book/presentation/widgets/payment_dialog.dart` |
| Create | `lib/features/credit_book/presentation/widgets/credit_sale_tile.dart` |
| Modify | `lib/core/l10n/app_tr.arb` |
| Modify | `lib/core/l10n/app_en.arb` |
| Modify | `lib/app/router.dart` |
| Modify | `lib/app/placeholder_home_screen.dart` |
| Create | `test/features/credit_book/credit_book_controller_test.dart` |
| Create | `test/features/credit_book/credit_list_screen_test.dart` |

---

## Task 1: `CreditSaleRepository`'ye `watchAll()` Ekle

**Files:**
- Modify: `lib/features/credit_book/data/credit_sale_repository.dart`
- Modify: `lib/features/credit_book/data/firestore_credit_sale_repository.dart`
- Modify: `lib/features/credit_book/data/mock_credit_sale_repository.dart`

- [ ] **Step 1: Abstract arayüze `watchAll()` ekle**

`lib/features/credit_book/data/credit_sale_repository.dart` dosyasını tam olarak şu içerikle değiştir:

```dart
import '../domain/credit_sale.dart';

abstract class CreditSaleRepository {
  Stream<List<CreditSale>> watchAll();
  Future<String> add(CreditSale sale);
  Future<void> update(CreditSale sale);
  Future<CreditSale?> getById(String id);
}
```

- [ ] **Step 2: Firestore impl'e `watchAll()` ekle**

`lib/features/credit_book/data/firestore_credit_sale_repository.dart` dosyasını tam olarak şu içerikle değiştir:

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
  Stream<List<CreditSale>> watchAll() => _col
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => CreditSale.fromMap(d.id, d.data()))
          .toList());

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

- [ ] **Step 3: Mock impl'e `watchAll()` + StreamController ekle**

`lib/features/credit_book/data/mock_credit_sale_repository.dart` dosyasını tam olarak şu içerikle değiştir:

```dart
import 'dart:async';

import '../domain/credit_sale.dart';
import 'credit_sale_repository.dart';

class MockCreditSaleRepository implements CreditSaleRepository {
  final Map<String, CreditSale> store = {};
  final _controller = StreamController<List<CreditSale>>.broadcast();
  int _nextId = 1;

  List<CreditSale> get _all => store.values.toList();

  void _notify() => _controller.add(_all);

  @override
  Stream<List<CreditSale>> watchAll() {
    Future.microtask(_notify);
    return _controller.stream;
  }

  @override
  Future<String> add(CreditSale sale) async {
    final id = 'mock_cs_${_nextId++}';
    store[id] = sale.copyWith(id: id);
    _notify();
    return id;
  }

  @override
  Future<void> update(CreditSale sale) async {
    store[sale.id] = sale;
    _notify();
  }

  @override
  Future<CreditSale?> getById(String id) async => store[id];

  void dispose() => _controller.close();
}
```

- [ ] **Step 4: `flutter analyze` çalıştır — 0 issue beklenir**

```
flutter analyze
```

---

## Task 2: `credit_book_providers.dart` + `CreditBookController` + Unit Testler

**Files:**
- Create: `lib/features/credit_book/application/credit_book_providers.dart`
- Modify: `lib/features/daily_record/application/daily_record_providers.dart`
- Modify: `test/features/daily_record/daily_record_controller_test.dart`
- Create: `test/features/credit_book/credit_book_controller_test.dart`

`creditSaleRepositoryProvider` şu an `daily_record_providers.dart`'ta. Onu `credit_book_providers.dart`'a taşıyıp `daily_record_providers.dart`'tan import edeceğiz.

- [ ] **Step 1: `credit_book_providers.dart` oluştur**

```dart
// lib/features/credit_book/application/credit_book_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/firebase_providers.dart';
import '../data/credit_sale_repository.dart';
import '../data/firestore_credit_sale_repository.dart';
import '../domain/credit_reconciler.dart';
import '../domain/credit_sale.dart';

final creditSaleRepositoryProvider = Provider<CreditSaleRepository>((ref) {
  return FirestoreCreditSaleRepository(ref.watch(firestoreProvider));
});

final creditSaleListProvider = StreamProvider<List<CreditSale>>((ref) {
  return ref.watch(creditSaleRepositoryProvider).watchAll();
});

final creditBookControllerProvider =
    AsyncNotifierProvider<CreditBookController, void>(
        CreditBookController.new);

class CreditBookController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  CreditSaleRepository get _repo => ref.read(creditSaleRepositoryProvider);

  /// Manuel (günlük kayda bağlı olmayan) yeni veresiye ekler.
  Future<void> addSale({
    required String customerName,
    required int totalAmount,
    required DateTime date,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.add(CreditSale(
          id: '',
          customerName: customerName,
          totalAmount: totalAmount,
          remainingAmount: totalAmount,
          date: date,
          status: CreditStatus.pending,
        )));
  }

  /// Mevcut veresiyeyi günceller (müşteri adı + toplam → mutabakat).
  Future<void> updateSale(CreditSale sale,
      {required String customerName, required int totalAmount}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final updated = CreditReconciler.reconcile(
        sale.copyWith(customerName: customerName),
        newTotal: totalAmount,
      );
      return _repo.update(updated);
    });
  }

  /// Kısmi ödeme ekler; amount > 0 && amount <= remaining olmalı.
  Future<void> addPayment(String saleId, int amount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sale = await _repo.getById(saleId);
      if (sale == null) throw Exception('Veresiye bulunamadı: $saleId');
      final payment = CreditPayment(amount: amount, date: DateTime.now());
      final withPayment = sale.copyWith(
          payments: [...sale.payments, payment]);
      final reconciled = CreditReconciler.reconcile(
          withPayment, newTotal: sale.totalAmount);
      await _repo.update(reconciled);
    });
  }

  /// Kalan tutarı sıfırlar; payments listesine tam-ödeme kaydı ekler.
  Future<void> markPaid(String saleId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sale = await _repo.getById(saleId);
      if (sale == null) throw Exception('Veresiye bulunamadı: $saleId');
      if (sale.remainingAmount <= 0) return;
      final payment =
          CreditPayment(amount: sale.remainingAmount, date: DateTime.now());
      final withPayment =
          sale.copyWith(payments: [...sale.payments, payment]);
      final reconciled = CreditReconciler.reconcile(
          withPayment, newTotal: sale.totalAmount);
      await _repo.update(reconciled);
    });
  }

  /// Son ödemeyi siler; status'u yeniden hesaplar.
  Future<void> undoPaid(String saleId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sale = await _repo.getById(saleId);
      if (sale == null || sale.payments.isEmpty) return;
      final trimmed = sale.payments.sublist(0, sale.payments.length - 1);
      final withoutLast = sale.copyWith(payments: trimmed);
      final reconciled = CreditReconciler.reconcile(
          withoutLast, newTotal: sale.totalAmount);
      await _repo.update(reconciled);
    });
  }
}
```

- [ ] **Step 2: `daily_record_providers.dart` içindeki `creditSaleRepositoryProvider` tanımını kaldır, import ekle**

`daily_record_providers.dart` dosyasında şu satırı:
```dart
import '../../credit_book/data/credit_sale_repository.dart';
import '../../credit_book/data/firestore_credit_sale_repository.dart';
```
kaldır ve yerine:
```dart
import '../../credit_book/application/credit_book_providers.dart';
```
ekle.

Ayrıca dosyadaki `creditSaleRepositoryProvider` provider tanımını kaldır (artık `credit_book_providers.dart`'ta).

Dosya şu hale gelmeli:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../shared/providers/firebase_providers.dart';
import '../../credit_book/application/credit_book_providers.dart';
import '../../credit_book/domain/credit_reconciler.dart';
import '../../credit_book/domain/credit_sale.dart';
import '../data/daily_record_repository.dart';
import '../data/firestore_daily_record_repository.dart';
import '../domain/daily_record.dart';
import '../domain/daily_record_calculator.dart';

final dailyRecordRepositoryProvider = Provider<DailyRecordRepository>((ref) {
  return FirestoreDailyRecordRepository(ref.watch(firestoreProvider));
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

- [ ] **Step 3: `daily_record_controller_test.dart` import'unu güncelle**

`test/features/daily_record/daily_record_controller_test.dart` dosyasında:

Şu satırı:
```dart
import 'package:gilanli_meyhane/features/daily_record/application/daily_record_providers.dart';
```
koru.

Şu satırı:
```dart
import 'package:gilanli_meyhane/features/credit_book/data/mock_credit_sale_repository.dart';
```
koru.

`creditSaleRepositoryProvider` override'ında import source değişti ama provider adı aynı — test dosyasını düzenle:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/credit_book/application/credit_book_providers.dart';
import 'package:gilanli_meyhane/features/credit_book/data/mock_credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';
import 'package:gilanli_meyhane/features/daily_record/application/daily_record_providers.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';
```

(Geri kalan test içeriği aynı kalır.)

- [ ] **Step 4: Unit test dosyası oluştur**

`test/features/credit_book/credit_book_controller_test.dart`:

```dart
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
    await ctrl()
        .addSale(customerName: 'Mehmet', totalAmount: 500000, date: DateTime(2026, 1, 1));
    final id = repo.store.keys.first;

    await ctrl().addPayment(id, 200000);

    final sale = repo.store[id]!;
    expect(sale.remainingAmount, 300000);
    expect(sale.status, CreditStatus.partial);
    expect(sale.payments.length, 1);
    expect(sale.payments.first.amount, 200000);
  });

  test('markPaid remaining sıfırlar ve status paid olur', () async {
    await ctrl()
        .addSale(customerName: 'Ayşe', totalAmount: 300000, date: DateTime(2026, 1, 1));
    final id = repo.store.keys.first;
    await ctrl().addPayment(id, 100000); // partial

    await ctrl().markPaid(id);

    final sale = repo.store[id]!;
    expect(sale.remainingAmount, 0);
    expect(sale.status, CreditStatus.paid);
    expect(sale.payments.length, 2);
    expect(sale.payments.last.amount, 200000); // kalan 200000 ödendi
  });

  test('undoPaid son ödemeyi siler ve status/remaining yeniden hesaplanır', () async {
    await ctrl()
        .addSale(customerName: 'Fatma', totalAmount: 400000, date: DateTime(2026, 1, 1));
    final id = repo.store.keys.first;
    await ctrl().addPayment(id, 100000);
    await ctrl().markPaid(id); // total: 400000, payments: [100000, 300000]

    await ctrl().undoPaid(id);

    final sale = repo.store[id]!;
    expect(sale.remainingAmount, 300000);
    expect(sale.status, CreditStatus.partial);
    expect(sale.payments.length, 1);
  });

  test('updateSale müşteri adı ve toplamı günceller, mutabakat yapılır', () async {
    await ctrl()
        .addSale(customerName: 'Eski', totalAmount: 200000, date: DateTime(2026, 1, 1));
    final id = repo.store.keys.first;
    final sale = repo.store[id]!;

    await ctrl().updateSale(sale, customerName: 'Yeni', totalAmount: 150000);

    final updated = repo.store[id]!;
    expect(updated.customerName, 'Yeni');
    expect(updated.totalAmount, 150000);
    expect(updated.remainingAmount, 150000);
    expect(updated.status, CreditStatus.pending);
  });
}
```

- [ ] **Step 5: Testleri çalıştır — 5 test yeşil beklenir**

```
flutter test test/features/credit_book/credit_book_controller_test.dart --reporter=compact
```

Beklenen çıktı: `+5: All tests passed!`

- [ ] **Step 6: Önceki testlerin hâlâ yeşil olduğunu doğrula**

```
flutter test test/features/daily_record/daily_record_controller_test.dart --reporter=compact
```

Beklenen çıktı: `+5: All tests passed!`

- [ ] **Step 7: Commit**

```
git add lib/features/credit_book/ lib/features/daily_record/application/daily_record_providers.dart test/features/credit_book/credit_book_controller_test.dart test/features/daily_record/daily_record_controller_test.dart
git commit -m "feat(credit-book): CreditBookController (addSale/addPayment/markPaid/undoPaid) + watchAll + repo taşıma"
```

---

## Task 3: ARB Strings + gen-l10n

**Files:**
- Modify: `lib/core/l10n/app_tr.arb`
- Modify: `lib/core/l10n/app_en.arb`

- [ ] **Step 1: `app_tr.arb` dosyasına veresiye string'leri ekle**

Mevcut `app_tr.arb` dosyasının sonundaki kapanış `}` dan önce şu satırları ekle:

```json
  "creditBook": "Veresiye Defteri",
  "@creditBook": { "description": "Veresiye defteri ekranı başlığı ve menü" },
  "addCreditSale": "Veresiye Ekle",
  "editCreditSale": "Veresiyeyi Düzenle",
  "creditTotalAmount": "Toplam Tutar (₺)",
  "creditTotalAmountRequired": "Toplam tutar zorunludur",
  "creditTotalAmountInvalid": "Geçerli bir tutar giriniz",
  "creditRemainingAmount": "Kalan",
  "creditStatusPending": "Bekliyor",
  "creditStatusPartial": "Kısmi Ödendi",
  "creditStatusPaid": "Ödendi",
  "addPayment": "Ödeme Ekle",
  "paymentAmount": "Ödeme Tutarı (₺)",
  "paymentAmountRequired": "Ödeme tutarı zorunludur",
  "paymentAmountInvalid": "Geçerli bir tutar giriniz",
  "paymentAmountExceedsRemaining": "Ödeme tutarı kalandan fazla olamaz",
  "markAsPaid": "Ödendi",
  "undoPaid": "Geri Al",
  "undoPaidConfirmTitle": "Bu ödemeyi geri almak istediğinizden emin misiniz?",
  "markAsPaidConfirmTitle": "Tüm bakiyeyi ödenmiş olarak işaretlemek istiyor musunuz?",
  "creditSaleAdded": "Veresiye kaydedildi.",
  "creditSaleUpdated": "Veresiye güncellendi.",
  "paymentAdded": "Ödeme kaydedildi.",
  "noCreditSales": "Henüz veresiye kaydı yok.",
  "openCreditBook": "Veresiye Defteri"
```

Yeni son içerik şöyle görünmeli (`openDailyRecord` satırından devam eder):
```json
  "openDailyRecord": "Günlük Kayıt",
  "creditBook": "Veresiye Defteri",
  ...
  "openCreditBook": "Veresiye Defteri"
}
```

- [ ] **Step 2: `app_en.arb` dosyasına İngilizce string'leri ekle**

Mevcut `app_en.arb` dosyasının sonundaki `}` dan önce şu satırları ekle:

```json
  "creditBook": "Credit Book",
  "addCreditSale": "Add Credit Sale",
  "editCreditSale": "Edit Credit Sale",
  "creditTotalAmount": "Total Amount (₺)",
  "creditTotalAmountRequired": "Total amount is required",
  "creditTotalAmountInvalid": "Enter a valid amount",
  "creditRemainingAmount": "Remaining",
  "creditStatusPending": "Pending",
  "creditStatusPartial": "Partially Paid",
  "creditStatusPaid": "Paid",
  "addPayment": "Add Payment",
  "paymentAmount": "Payment Amount (₺)",
  "paymentAmountRequired": "Payment amount is required",
  "paymentAmountInvalid": "Enter a valid amount",
  "paymentAmountExceedsRemaining": "Payment cannot exceed remaining balance",
  "markAsPaid": "Mark as Paid",
  "undoPaid": "Undo",
  "undoPaidConfirmTitle": "Are you sure you want to undo this payment?",
  "markAsPaidConfirmTitle": "Mark full balance as paid?",
  "creditSaleAdded": "Credit sale saved.",
  "creditSaleUpdated": "Credit sale updated.",
  "paymentAdded": "Payment recorded.",
  "noCreditSales": "No credit sales yet.",
  "openCreditBook": "Credit Book"
```

- [ ] **Step 3: gen-l10n çalıştır**

```
flutter gen-l10n
```

Hata çıkmamalı.

- [ ] **Step 4: `flutter analyze` çalıştır — 0 issue beklenir**

```
flutter analyze
```

- [ ] **Step 5: Commit**

```
git add lib/core/l10n/
git commit -m "feat(credit-book): ARB TR/EN string'leri (veresiye defteri)"
```

---

## Task 4: `credit_form.dart` — Manuel Ekleme + Düzenleme

**Files:**
- Create: `lib/features/credit_book/presentation/credit_form.dart`

`CreditForm` iki modda çalışır: ekleme (`sale == null`) ve düzenleme (`sale != null`).

- [ ] **Step 1: `credit_form.dart` oluştur**

```dart
// lib/features/credit_book/presentation/credit_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/money_input_field.dart';
import '../application/credit_book_providers.dart';
import '../domain/credit_sale.dart';

class CreditForm extends ConsumerStatefulWidget {
  const CreditForm({super.key, this.sale});

  /// Düzenleme modunda dolu gelir; eklemede null.
  final CreditSale? sale;

  @override
  ConsumerState<CreditForm> createState() => _CreditFormState();
}

class _CreditFormState extends ConsumerState<CreditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;

  bool get _isEdit => widget.sale != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.sale?.customerName ?? '');
    // Tutarı lira olarak göster (kuruş / 100)
    final amountLira = widget.sale != null
        ? (widget.sale!.totalAmount / 100).toStringAsFixed(0)
        : '';
    _amountCtrl = TextEditingController(text: amountLira);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);

    final confirmed = await showConfirmDialog(
      context,
      title: l10n.saveConfirmTitle,
    );
    if (!confirmed) return;

    final customerName = _nameCtrl.text.trim();
    final totalKurus = int.parse(_amountCtrl.text.replaceAll('.', '')) * 100;

    if (_isEdit) {
      await ref.read(creditBookControllerProvider.notifier).updateSale(
            widget.sale!,
            customerName: customerName,
            totalAmount: totalKurus,
          );
    } else {
      await ref.read(creditBookControllerProvider.notifier).addSale(
            customerName: customerName,
            totalAmount: totalKurus,
            date: DateTime.now(),
          );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            _isEdit ? l10n.creditSaleUpdated : l10n.creditSaleAdded),
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editCreditSale : l10n.addCreditSale),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.creditCustomer,
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.creditCustomerRequired
                      : null,
                ),
                const SizedBox(height: 16),
                MoneyInputField(
                  controller: _amountCtrl,
                  label: l10n.creditTotalAmount,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.creditTotalAmountRequired;
                    }
                    final n = int.tryParse(v.replaceAll('.', ''));
                    if (n == null || n <= 0) return l10n.creditTotalAmountInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _submit,
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

- [ ] **Step 2: `flutter analyze` çalıştır — 0 issue beklenir**

```
flutter analyze
```

- [ ] **Step 3: Commit**

```
git add lib/features/credit_book/presentation/credit_form.dart
git commit -m "feat(credit-book): CreditForm (ekleme + düzenleme modu)"
```

---

## Task 5: `payment_dialog.dart`

**Files:**
- Create: `lib/features/credit_book/presentation/widgets/payment_dialog.dart`

`showPaymentDialog` bir `AlertDialog` açar; onaylanan tutarı (kuruş, int) döndürür; iptal veya hata durumunda `null` döner.

- [ ] **Step 1: `payment_dialog.dart` oluştur**

```dart
// lib/features/credit_book/presentation/widgets/payment_dialog.dart
import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';

/// Kısmi ödeme dialog'u.
/// [remainingAmount] kuruş cinsinden maksimum tutardır.
/// Onaylanan tutarı kuruş olarak döndürür; iptal/hata durumunda null.
Future<int?> showPaymentDialog(
  BuildContext context, {
  required int remainingAmount,
}) async {
  final l10n = AppLocalizations.of(context);
  final ctrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final result = await showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.addPayment),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.paymentAmount,
            border: const OutlineInputBorder(),
            suffixText: '₺',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return l10n.paymentAmountRequired;
            }
            final n = int.tryParse(v.replaceAll('.', ''));
            if (n == null || n <= 0) return l10n.paymentAmountInvalid;
            final kurus = n * 100;
            if (kurus > remainingAmount) {
              return l10n.paymentAmountExceedsRemaining;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(null),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final n = int.parse(ctrl.text.replaceAll('.', ''));
              Navigator.of(ctx).pop(n * 100);
            }
          },
          child: Text(l10n.confirm),
        ),
      ],
    ),
  );
  ctrl.dispose();
  return result;
}
```

- [ ] **Step 2: `flutter analyze` çalıştır — 0 issue beklenir**

```
flutter analyze
```

- [ ] **Step 3: Commit**

```
git add lib/features/credit_book/presentation/widgets/payment_dialog.dart
git commit -m "feat(credit-book): PaymentDialog (kısmi ödeme, validation)"
```

---

## Task 6: `credit_sale_tile.dart` + `credit_list_screen.dart`

**Files:**
- Create: `lib/features/credit_book/presentation/widgets/credit_sale_tile.dart`
- Create: `lib/features/credit_book/presentation/credit_list_screen.dart`

Liste elemanları `CreditSaleTile` bileşenine ayrıştırılır; ekran widget testi için küçük tutulur.

- [ ] **Step 1: `credit_sale_tile.dart` oluştur**

```dart
// lib/features/credit_book/presentation/widgets/credit_sale_tile.dart
import 'package:flutter/material.dart';

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/credit_sale.dart';

class CreditSaleTile extends StatelessWidget {
  const CreditSaleTile({
    super.key,
    required this.sale,
    required this.onTap,
  });

  final CreditSale sale;
  final VoidCallback onTap;

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (sale.status) {
      CreditStatus.pending => cs.error,
      CreditStatus.partial => cs.tertiary,
      CreditStatus.paid => cs.primary,
    };
  }

  String _statusLabel(AppLocalizations l10n) => switch (sale.status) {
        CreditStatus.pending => l10n.creditStatusPending,
        CreditStatus.partial => l10n.creditStatusPartial,
        CreditStatus.paid => l10n.creditStatusPaid,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final color = _statusColor(context);

    return ListTile(
      title: Text(sale.customerName,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${l10n.creditRemainingAmount}: ${sale.remainingAmount.toCurrency(locale)}  /  ${sale.totalAmount.toCurrency(locale)}',
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Chip(
        label: Text(
          _statusLabel(l10n),
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        backgroundColor: color.withAlpha(26),
        side: BorderSide.none,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
      onTap: onTap,
    );
  }
}
```

- [ ] **Step 2: `credit_list_screen.dart` oluştur**

Aşağıda, BottomSheet ile aksiyonları sunan tam ekran kodu:

```dart
// lib/features/credit_book/presentation/credit_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../application/credit_book_providers.dart';
import '../domain/credit_sale.dart';
import 'widgets/credit_sale_tile.dart';
import 'widgets/payment_dialog.dart';

class CreditListScreen extends ConsumerWidget {
  const CreditListScreen({super.key});

  List<CreditSale> _sorted(List<CreditSale> list) {
    const order = {
      CreditStatus.pending: 0,
      CreditStatus.partial: 1,
      CreditStatus.paid: 2,
    };
    final copy = [...list];
    copy.sort((a, b) {
      final s = order[a.status]!.compareTo(order[b.status]!);
      if (s != 0) return s;
      return b.date.compareTo(a.date);
    });
    return copy;
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    CreditSale sale,
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
              title: Text(l10n.editCreditSale),
              onTap: () {
                Navigator.of(ctx).pop();
                context.push('/credit/edit', extra: sale);
              },
            ),
            if (sale.status != CreditStatus.paid) ...[
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(l10n.addPayment),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final amount = await showPaymentDialog(
                    context,
                    remainingAmount: sale.remainingAmount,
                  );
                  if (amount != null && amount > 0) {
                    await ref
                        .read(creditBookControllerProvider.notifier)
                        .addPayment(sale.id, amount);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.paymentAdded)),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(l10n.markAsPaid),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.markAsPaidConfirmTitle,
                  );
                  if (confirmed) {
                    await ref
                        .read(creditBookControllerProvider.notifier)
                        .markPaid(sale.id);
                  }
                },
              ),
            ],
            if (sale.status == CreditStatus.paid)
              ListTile(
                leading: const Icon(Icons.undo),
                title: Text(l10n.undoPaid),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed = await showConfirmDialog(
                    context,
                    title: l10n.undoPaidConfirmTitle,
                  );
                  if (confirmed) {
                    await ref
                        .read(creditBookControllerProvider.notifier)
                        .undoPaid(sale.id);
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
    final listAsync = ref.watch(creditSaleListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.creditBook)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/credit/add'),
        tooltip: l10n.addCreditSale,
        child: const Icon(Icons.add),
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(l10n.noCreditSales));
          }
          final sorted = _sorted(list);
          return ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final sale = sorted[i];
              return CreditSaleTile(
                sale: sale,
                onTap: () => _showActions(ctx, ref, sale, l10n),
              );
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 3: `flutter analyze` çalıştır — 0 issue beklenir**

```
flutter analyze
```

- [ ] **Step 4: Commit**

```
git add lib/features/credit_book/presentation/
git commit -m "feat(credit-book): CreditListScreen + CreditSaleTile (liste, BottomSheet aksiyonlar)"
```

---

## Task 7: Router + Ana Ekran Kartı

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `lib/app/placeholder_home_screen.dart`

- [ ] **Step 1: `router.dart`'a `/credit`, `/credit/add`, `/credit/edit` rotalarını ekle**

`lib/app/router.dart` dosyasını şu hale getir:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/credit_book/domain/credit_sale.dart';
import '../features/credit_book/presentation/credit_form.dart';
import '../features/credit_book/presentation/credit_list_screen.dart';
import '../features/daily_record/presentation/daily_record_screen.dart';
import '../features/staff/presentation/staff_list_screen.dart';
import 'placeholder_home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      if (authState.isLoading) return null;
      final isLoggedIn = authState.asData?.value != null;
      final isOnLogin = state.matchedLocation == '/login';
      if (!isLoggedIn && !isOnLogin) return '/login';
      if (isLoggedIn && isOnLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const PlaceholderHomeScreen(),
      ),
      GoRoute(
        path: '/staff',
        builder: (context, state) => const StaffListScreen(),
      ),
      GoRoute(
        path: '/daily',
        builder: (context, state) => const DailyRecordScreen(),
      ),
      GoRoute(
        path: '/credit',
        builder: (context, state) => const CreditListScreen(),
      ),
      GoRoute(
        path: '/credit/add',
        builder: (context, state) => const CreditForm(),
      ),
      GoRoute(
        path: '/credit/edit',
        builder: (context, state) =>
            CreditForm(sale: state.extra as CreditSale),
      ),
    ],
  );

  ref.listen(authStateChangesProvider, (prev, next) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
});
```

- [ ] **Step 2: `placeholder_home_screen.dart`'a Veresiye Defteri kartı ekle**

`PlaceholderHomeScreen`'deki `ListView` içinde personel kartından sonra şu kartı ekle:

```dart
Card(
  child: ListTile(
    leading: const Icon(Icons.menu_book_outlined),
    title: Text(l10n.openCreditBook),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.push('/credit'),
  ),
),
```

- [ ] **Step 3: `flutter analyze` çalıştır — 0 issue beklenir**

```
flutter analyze
```

- [ ] **Step 4: Commit**

```
git add lib/app/router.dart lib/app/placeholder_home_screen.dart
git commit -m "feat(credit-book): /credit rotası + ana ekran kartı"
```

---

## Task 8: Widget Testi — `credit_list_screen_test.dart`

**Files:**
- Create: `test/features/credit_book/credit_list_screen_test.dart`

- [ ] **Step 1: Widget test dosyası oluştur**

```dart
// test/features/credit_book/credit_list_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/credit_book/application/credit_book_providers.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';
import 'package:gilanli_meyhane/features/credit_book/presentation/credit_list_screen.dart';

import '../../helpers/app_wrapper.dart';

void main() {
  group('CreditListScreen', () {
    test('boş liste "noCreditSales" mesajı gösterir', () async {
      final container = ProviderContainer(overrides: [
        creditSaleListProvider.overrideWith(
            (_) => Stream.value(<CreditSale>[])),
      ]);
      addTearDown(container.dispose);

      await tester_helper(container);
    });

    testWidgets('listede kayıt varsa müşteri adı görünür',
        (WidgetTester tester) async {
      final sales = [
        CreditSale(
          id: '1',
          customerName: 'Test Müşteri',
          totalAmount: 100000,
          remainingAmount: 100000,
          date: DateTime(2026, 1, 1),
          status: CreditStatus.pending,
        ),
      ];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            creditSaleListProvider
                .overrideWith((_) => Stream.value(sales)),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              // flutter_localizations + app localizations
            ],
            home: CreditListScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Test Müşteri'), findsOneWidget);
    });
  });
}
```

**Not:** Bu test basit bir smoke test. Localizations setup için Faz 4'teki widget test helper'ı varsa kullan; yoksa aşağıdaki helper dosyasını oluştur.

- [ ] **Step 2: Test helper yoksa `test/helpers/app_wrapper.dart` oluştur**

```dart
// test/helpers/app_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';

/// Test widgetlerini sarmalayan yardımcı.
Widget buildTestApp(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
```

Sonra `credit_list_screen_test.dart`'ı şu sade ve tam haliyle değiştir:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/credit_book/application/credit_book_providers.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';
import 'package:gilanli_meyhane/features/credit_book/presentation/credit_list_screen.dart';

import '../../helpers/app_wrapper.dart';

void main() {
  testWidgets('CreditListScreen: kayıt varsa müşteri adı görünür',
      (WidgetTester tester) async {
    final sales = [
      CreditSale(
        id: '1',
        customerName: 'Test Müşteri',
        totalAmount: 100000,
        remainingAmount: 100000,
        date: DateTime(2026, 1, 1),
        status: CreditStatus.pending,
      ),
    ];

    await tester.pumpWidget(buildTestApp(
      const CreditListScreen(),
      overrides: [
        creditSaleListProvider.overrideWith((_) => Stream.value(sales)),
      ],
    ));

    await tester.pump();
    expect(find.text('Test Müşteri'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Var olan test helper'ı kontrol et**

```
flutter test test/features/credit_book/credit_list_screen_test.dart --reporter=compact
```

Testin geçmesi beklenir. Başarısız olursa hata mesajını incele.

- [ ] **Step 4: Commit**

```
git add test/
git commit -m "test(credit-book): CreditListScreen widget testi"
```

---

## Task 9: Tam Doğrulama

- [ ] **Step 1: Tüm testleri çalıştır**

```
flutter test --reporter=compact
```

Beklenen çıktı: tüm testler (≥ 70) yeşil. Özellikle:
- `test/features/credit_book/credit_book_controller_test.dart` → 5 test
- `test/features/credit_book/credit_list_screen_test.dart` → 1 test
- `test/features/daily_record/daily_record_controller_test.dart` → 5 test (hâlâ yeşil)
- Önceki tüm testler (63 Faz 4 öncesi): hâlâ geçiyor

- [ ] **Step 2: `flutter analyze` çalıştır — 0 issue**

```
flutter analyze
```

- [ ] **Step 3: PROGRESS.md güncelle**

`PROGRESS.md` dosyasında:
- `- [ ] Faz 5 — Veresiye Defteri` satırını `- [x] **Faz 5 — Veresiye Defteri** ✅ tamam (X test, analyze temiz)` yap
- Aktif faz kısmını güncelle: `Faz 6 — Ödemeler — başlamaya hazır`
- Yeni bir Faz 5 adımlar bölümü ekle (tamamlanan adımlarla)
- Kayıt/Notlar bölümüne tarihli not ekle

- [ ] **Step 4: Son commit**

```
git add PROGRESS.md
git commit -m "docs(progress): Faz 5 tamam - veresiye defteri UI + controller"
```

---

## Kabul Kriterleri

- [ ] `CreditListScreen` liste, ekleme, kısmi ödeme, "Ödendi", geri alma akışlarını destekliyor
- [ ] `CreditForm` hem ekleme hem düzenleme modunda çalışıyor
- [ ] `CreditBookController.addPayment/markPaid/undoPaid` doğru status geçişleri yapıyor
- [ ] `flutter test` yeşil (≥ 70 test)
- [ ] `flutter analyze` 0 issue
- [ ] TR/EN lokalizasyon tam
