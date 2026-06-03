# Faz 8 — Haftalık Özet (Weekly Summary) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Haftalık özet ekranını (bar grafik + günlük liste + personel gün tablosu + bahşiş dağıtımı) inşa etmek.

**Architecture:** `weekly_summary` feature; Riverpod FutureProvider + StateProvider (hafta offset); `TipDistribution` modeli Firestore `tipDistributions` koleksiyonunda; `DailyRecordRepository.getByDateRange()` eklenerek hafta verisi çekilir. Tüm hesaplama provider'da, UI salt-gösterim. `allStaffProvider` (StreamProvider) re-kullanılır.

**Tech Stack:** Flutter 3 · Riverpod 3 · fl_chart 1.2 · go_router · Firestore · intl · equatable. Test: flutter_test, fake_cloud_firestore, mocktail.

---

## Dosya Haritası

### Yeni dosyalar
| Dosya | Sorumluluk |
|---|---|
| `lib/features/weekly_summary/domain/tip_distribution.dart` | TipDistribution model (immutable, equatable) |
| `lib/features/weekly_summary/data/tip_distribution_repository.dart` | Abstract repo arayüzü |
| `lib/features/weekly_summary/data/firestore_tip_distribution_repository.dart` | Firestore impl |
| `lib/features/weekly_summary/data/mock_tip_distribution_repository.dart` | Bellek-içi mock |
| `lib/features/weekly_summary/application/weekly_providers.dart` | Tüm provider'lar + TipDistributionController |
| `lib/features/weekly_summary/presentation/weekly_summary_screen.dart` | Ana ekran |
| `lib/features/weekly_summary/presentation/widgets/weekly_bar_chart.dart` | fl_chart bar grafiği |
| `lib/features/weekly_summary/presentation/widgets/daily_summary_list.dart` | Günlük kayıt listesi |
| `lib/features/weekly_summary/presentation/widgets/staff_days_table.dart` | Personel gün tablosu |
| `test/features/weekly_summary/tip_distribution_model_test.dart` | Model roundtrip testleri |
| `test/features/weekly_summary/weekly_providers_test.dart` | Provider unit testleri |
| `test/features/weekly_summary/weekly_summary_screen_test.dart` | Widget testleri |

### Değiştirilen dosyalar
| Dosya | Değişiklik |
|---|---|
| `lib/features/daily_record/data/daily_record_repository.dart` | `getByDateRange(DateRange)` eklenir |
| `lib/features/daily_record/data/firestore_daily_record_repository.dart` | `getByDateRange` impl |
| `lib/features/daily_record/data/mock_daily_record_repository.dart` | `getByDateRange` impl |
| `lib/core/l10n/app_tr.arb` | Yeni string'ler eklenir |
| `lib/core/l10n/app_en.arb` | Yeni string'ler eklenir |
| `lib/app/router.dart` | `/weekly` placeholder → `WeeklySummaryScreen` |

---

## Task 1: ARB string'leri + gen-l10n

**Files:**
- Modify: `lib/core/l10n/app_tr.arb`
- Modify: `lib/core/l10n/app_en.arb`

- [ ] **Step 1: app_tr.arb'a yeni string'leri ekle**

`lib/core/l10n/app_tr.arb` dosyasının son `}` kapanışından önce şunları ekle:

```json
  "prevWeek": "Önceki Hafta",
  "@prevWeek": { "description": "Haftalık özet — önceki hafta butonu tooltip" },
  "nextWeek": "Sonraki Hafta",
  "@nextWeek": { "description": "Haftalık özet — sonraki hafta butonu tooltip" },
  "weeklyRevenue": "Haftalık Ciro",
  "weeklyTips": "Haftalık Bahşiş",
  "openTips": "Dağıtılmamış Bahşiş",
  "@openTips": { "description": "Haftalık özet — dağıtılmamış bahşiş etiket" },
  "distributeTips": "Dağıtıldı, Kapat",
  "@distributeTips": { "description": "Bahşiş dağıtım butonu" },
  "distributeTipsConfirmTitle": "Bahşiş dağıtımını onaylıyor musunuz?",
  "distributeTipsConfirmBody": "{amount} dağıtılmamış bahşiş kasadan düşülecek.",
  "@distributeTipsConfirmBody": {
    "description": "Bahşiş dağıtım onay dialog içeriği",
    "placeholders": { "amount": { "type": "String" } }
  },
  "tipsDistributed": "Bahşiş dağıtımı kaydedildi.",
  "noRecordsThisWeek": "Bu hafta kayıt bulunmuyor.",
  "staffDaysTitle": "Personel Günleri",
  "noOpenTips": "Dağıtılacak bahşiş yok."
```

- [ ] **Step 2: app_en.arb'a yeni string'leri ekle**

`lib/core/l10n/app_en.arb` dosyasının son `}` kapanışından önce şunları ekle:

```json
  "prevWeek": "Previous Week",
  "nextWeek": "Next Week",
  "weeklyRevenue": "Weekly Revenue",
  "weeklyTips": "Weekly Tips",
  "openTips": "Undistributed Tips",
  "distributeTips": "Distribute & Close",
  "distributeTipsConfirmTitle": "Confirm tip distribution?",
  "distributeTipsConfirmBody": "{amount} in undistributed tips will be deducted from cash.",
  "tipsDistributed": "Tip distribution recorded.",
  "noRecordsThisWeek": "No records this week.",
  "staffDaysTitle": "Staff Days",
  "noOpenTips": "No tips to distribute."
```

- [ ] **Step 3: gen-l10n çalıştır**

```powershell
cd C:\Users\Akatron\Desktop\tavern-app-project
flutter gen-l10n
```

Beklenen: hata yok, `lib/core/l10n/generated/` dosyaları güncellendi.

- [ ] **Step 4: analyze**

```powershell
flutter analyze
```

Beklenen: 0 issue.

---

## Task 2: TipDistribution model (TDD)

**Files:**
- Create: `lib/features/weekly_summary/domain/tip_distribution.dart`
- Create: `test/features/weekly_summary/tip_distribution_model_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/weekly_summary/tip_distribution_model_test.dart`:

```dart
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
```

- [ ] **Step 2: Testin kırmızı olduğunu doğrula**

```powershell
flutter test test/features/weekly_summary/tip_distribution_model_test.dart
```

Beklenen: FAIL (dosya yok).

- [ ] **Step 3: TipDistribution modelini yaz**

`lib/features/weekly_summary/domain/tip_distribution.dart`:

```dart
import 'package:equatable/equatable.dart';

class TipDistribution extends Equatable {
  final String id;
  final DateTime date;
  final int amount;
  final DateTime periodStart;
  final DateTime periodEnd;

  const TipDistribution({
    required this.id,
    required this.date,
    required this.amount,
    required this.periodStart,
    required this.periodEnd,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
      };

  factory TipDistribution.fromMap(String id, Map<String, dynamic> map) =>
      TipDistribution(
        id: id,
        date: DateTime.parse(map['date'] as String),
        amount: (map['amount'] as num).toInt(),
        periodStart: DateTime.parse(map['periodStart'] as String),
        periodEnd: DateTime.parse(map['periodEnd'] as String),
      );

  TipDistribution copyWith({
    String? id,
    DateTime? date,
    int? amount,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) =>
      TipDistribution(
        id: id ?? this.id,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        periodStart: periodStart ?? this.periodStart,
        periodEnd: periodEnd ?? this.periodEnd,
      );

  @override
  List<Object?> get props => [id, date, amount, periodStart, periodEnd];
}
```

- [ ] **Step 4: Testlerin yeşil olduğunu doğrula**

```powershell
flutter test test/features/weekly_summary/tip_distribution_model_test.dart
```

Beklenen: 3/3 PASS.

- [ ] **Step 5: Commit**

```powershell
git add lib/features/weekly_summary/domain/tip_distribution.dart test/features/weekly_summary/tip_distribution_model_test.dart
git commit -m "feat(weekly): TipDistribution model + 3 roundtrip testi"
```

---

## Task 3: TipDistributionRepository üçlüsü

**Files:**
- Create: `lib/features/weekly_summary/data/tip_distribution_repository.dart`
- Create: `lib/features/weekly_summary/data/firestore_tip_distribution_repository.dart`
- Create: `lib/features/weekly_summary/data/mock_tip_distribution_repository.dart`

- [ ] **Step 1: Abstract repo arayüzünü yaz**

`lib/features/weekly_summary/data/tip_distribution_repository.dart`:

```dart
import '../domain/tip_distribution.dart';

abstract class TipDistributionRepository {
  Future<String> add(TipDistribution dist);
  Future<List<TipDistribution>> getAll();
}
```

- [ ] **Step 2: Mock impl yaz**

`lib/features/weekly_summary/data/mock_tip_distribution_repository.dart`:

```dart
import '../domain/tip_distribution.dart';
import 'tip_distribution_repository.dart';

class MockTipDistributionRepository implements TipDistributionRepository {
  final Map<String, TipDistribution> store = {};
  int _counter = 0;

  @override
  Future<String> add(TipDistribution dist) async {
    final id = 'dist_${_counter++}';
    store[id] = dist.copyWith(id: id);
    return id;
  }

  @override
  Future<List<TipDistribution>> getAll() async => store.values.toList();
}
```

- [ ] **Step 3: Firestore impl yaz**

`lib/features/weekly_summary/data/firestore_tip_distribution_repository.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tip_distribution.dart';
import 'tip_distribution_repository.dart';

class FirestoreTipDistributionRepository implements TipDistributionRepository {
  FirestoreTipDistributionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('tipDistributions');

  @override
  Future<String> add(TipDistribution dist) async {
    final map = dist.toMap()..remove('id');
    final docRef = await _col.add(map);
    return docRef.id;
  }

  @override
  Future<List<TipDistribution>> getAll() async {
    final snap = await _col.orderBy('date').get();
    return snap.docs
        .map((doc) => TipDistribution.fromMap(doc.id, doc.data()))
        .toList();
  }
}
```

- [ ] **Step 4: analyze**

```powershell
flutter analyze
```

Beklenen: 0 issue.

- [ ] **Step 5: Commit**

```powershell
git add lib/features/weekly_summary/data/
git commit -m "feat(weekly): TipDistributionRepository üçlüsü (abstract/Firestore/Mock)"
```

---

## Task 4: DailyRecordRepository.getByDateRange() (TDD)

**Files:**
- Modify: `lib/features/daily_record/data/daily_record_repository.dart`
- Modify: `lib/features/daily_record/data/firestore_daily_record_repository.dart`
- Modify: `lib/features/daily_record/data/mock_daily_record_repository.dart`
- Create (test ekleme): `test/features/weekly_summary/weekly_providers_test.dart` (T4 kısmı buraya)

- [ ] **Step 1: Abstract repo'ya getByDateRange ekle**

`lib/features/daily_record/data/daily_record_repository.dart` dosyasını aç, `getAll()` satırının altına şunu ekle:

```dart
  /// [range.start] dahil, [range.end] hariç aralıktaki kayıtları döner.
  Future<List<DailyRecord>> getByDateRange(DateRange range);
```

Dosyanın üstüne import ekle:
```dart
import '../../../core/utils/date_utils.dart';
```

Dosya sonunda şöyle görünmeli:
```dart
import '../../../core/utils/date_utils.dart';
import '../domain/daily_record.dart';

abstract class DailyRecordRepository {
  Future<DailyRecord?> getByDay(String dayKey);
  Future<void> save(DailyRecord record);
  Future<List<DailyRecord>> getAll();
  Future<List<DailyRecord>> getByDateRange(DateRange range);
}
```

- [ ] **Step 2: Mock impl'e getByDateRange ekle**

`lib/features/daily_record/data/mock_daily_record_repository.dart` dosyasına şu metodu ekle:

```dart
import '../../../core/utils/date_utils.dart';
```
(dosya başına import ekle)

```dart
  @override
  Future<List<DailyRecord>> getByDateRange(DateRange range) async {
    return store.values
        .where((r) =>
            !r.date.isBefore(range.start) && r.date.isBefore(range.end))
        .toList();
  }
```

- [ ] **Step 3: Firestore impl'e getByDateRange ekle**

`lib/features/daily_record/data/firestore_daily_record_repository.dart` dosyasına import ve metod ekle:

```dart
import '../../../core/utils/date_utils.dart';
```

```dart
  @override
  Future<List<DailyRecord>> getByDateRange(DateRange range) async {
    final startKey = dayKey(range.start);
    final endKey = dayKey(range.end);
    final snap = await _col
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
        .where(FieldPath.documentId, isLessThan: endKey)
        .get();
    return snap.docs
        .map((doc) => DailyRecord.fromMap(doc.id, doc.data()))
        .toList();
  }
```

- [ ] **Step 4: Mock repo ile getByDateRange testi yaz**

`test/features/weekly_summary/weekly_providers_test.dart` dosyasını oluştur:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/utils/date_utils.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record_calculator.dart';

DailyRecord _makeRecord(DateTime date) {
  final daily = DailyRecordCalculator.dailyCash(
    revenue: 100000,
    creditCard: 0,
    tips: 0,
    cashExpenses: 0,
    creditSales: 0,
  );
  return DailyRecord(
    id: dayKey(date),
    date: date,
    revenue: 100000,
    creditCard: 0,
    tips: 0,
    ownerExpenses: 0,
    cashExpenses: 0,
    creditSales: 0,
    previousDayCash: 0,
    dailyCash: daily,
    totalCash: daily,
  );
}

void main() {
  group('MockDailyRecordRepository.getByDateRange', () {
    late MockDailyRecordRepository repo;

    setUp(() {
      repo = MockDailyRecordRepository();
    });

    test('aralık içindeki kayıtları döner', () async {
      final r1 = _makeRecord(DateTime(2026, 6, 2)); // Pazartesi
      final r2 = _makeRecord(DateTime(2026, 6, 3)); // Salı
      final r3 = _makeRecord(DateTime(2026, 6, 9)); // Gelecek Pazartesi (hariç)
      repo.store[r1.id] = r1;
      repo.store[r2.id] = r2;
      repo.store[r3.id] = r3;

      final range = (
        start: DateTime(2026, 6, 2),
        end: DateTime(2026, 6, 9), // hariç
      );
      final result = await repo.getByDateRange(range);

      expect(result.length, 2);
      expect(result.any((r) => r.id == r1.id), isTrue);
      expect(result.any((r) => r.id == r2.id), isTrue);
      expect(result.any((r) => r.id == r3.id), isFalse);
    });

    test('aralık dışındaki kayıtları döndürmez', () async {
      final r1 = _makeRecord(DateTime(2026, 6, 1)); // aralık öncesi
      repo.store[r1.id] = r1;

      final range = (
        start: DateTime(2026, 6, 2),
        end: DateTime(2026, 6, 9),
      );
      final result = await repo.getByDateRange(range);

      expect(result, isEmpty);
    });

    test('boş store için boş liste döner', () async {
      final range = (
        start: DateTime(2026, 6, 2),
        end: DateTime(2026, 6, 9),
      );
      final result = await repo.getByDateRange(range);
      expect(result, isEmpty);
    });
  });
}
```

- [ ] **Step 5: Testlerin yeşil olduğunu doğrula**

```powershell
flutter test test/features/weekly_summary/weekly_providers_test.dart
```

Beklenen: 3/3 PASS.

- [ ] **Step 6: Tam test paketi yeşil mi kontrol et**

```powershell
flutter test
```

Beklenen: önceki 92 test + 3 yeni = 95 PASS.

- [ ] **Step 7: Commit**

```powershell
git add lib/features/daily_record/data/ test/features/weekly_summary/weekly_providers_test.dart
git commit -m "feat(weekly): DailyRecordRepository.getByDateRange + 3 test"
```

---

## Task 5: weekly_providers.dart

**Files:**
- Create: `lib/features/weekly_summary/application/weekly_providers.dart`

- [ ] **Step 1: weekly_providers.dart yaz**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../shared/providers/firebase_providers.dart';
import '../../daily_record/application/daily_record_providers.dart';
import '../../daily_record/domain/daily_record.dart';
import '../../staff/application/staff_providers.dart';
import '../../staff/domain/staff.dart';
import '../data/firestore_tip_distribution_repository.dart';
import '../data/tip_distribution_repository.dart';
import '../domain/tip_distribution.dart';

/// Hafta navigasyon ofseti: 0 = bu hafta, -1 = geçen hafta, vb.
final weekOffsetProvider = StateProvider<int>((ref) => 0);

/// Offset'e göre hesaplanan haftanın aralığı.
final currentWeekRangeProvider = Provider<DateRange>((ref) {
  final offset = ref.watch(weekOffsetProvider);
  final base = DateTime.now();
  final shifted = DateTime(base.year, base.month, base.day + offset * 7);
  return weekRange(shifted);
});

/// Mevcut haftanın günlük kayıtları.
final weeklyRecordsProvider = FutureProvider<List<DailyRecord>>((ref) async {
  final range = ref.watch(currentWeekRangeProvider);
  return ref.watch(dailyRecordRepositoryProvider).getByDateRange(range);
});

/// Bahşiş dağıtımları repo provider'ı.
final tipDistributionRepositoryProvider =
    Provider<TipDistributionRepository>((ref) {
  return FirestoreTipDistributionRepository(ref.watch(firestoreProvider));
});

/// Tüm bahşiş dağıtımları.
final allTipDistributionsProvider =
    FutureProvider<List<TipDistribution>>((ref) async {
  return ref.watch(tipDistributionRepositoryProvider).getAll();
});

/// Tüm günlük kayıtlar (açık bahşiş hesabı için).
final allDailyRecordsProvider =
    FutureProvider<List<DailyRecord>>((ref) async {
  return ref.watch(dailyRecordRepositoryProvider).getAll();
});

/// Son dağıtımdan bu yana birikmiş bahşiş toplamı.
/// Son dağıtım yoksa tüm kayıtların bahşiş toplamı.
final openTipsProvider = FutureProvider<int>((ref) async {
  final distributions = await ref.watch(allTipDistributionsProvider.future);
  final allRecords = await ref.watch(allDailyRecordsProvider.future);

  if (distributions.isEmpty) {
    return allRecords.fold<int>(0, (s, r) => s + r.tips);
  }

  final lastDistDate = distributions
      .map((d) => d.date)
      .reduce((a, b) => a.isAfter(b) ? a : b);

  return allRecords
      .where((r) => r.date.isAfter(lastDistDate))
      .fold<int>(0, (s, r) => s + r.tips);
});

/// Mevcut haftada çalışan personel ve kaç gün çalıştıkları.
final weeklyStaffDaysProvider =
    FutureProvider<List<({Staff staff, int days})>>((ref) async {
  final records = await ref.watch(weeklyRecordsProvider.future);
  final allStaff = await ref.watch(allStaffProvider.future);

  final dayCounts = <String, int>{};
  for (final record in records) {
    for (final id in record.workingStaffIds) {
      dayCounts[id] = (dayCounts[id] ?? 0) + 1;
    }
  }

  final result = allStaff
      .where((s) => dayCounts.containsKey(s.id))
      .map((s) => (staff: s, days: dayCounts[s.id]!))
      .toList()
    ..sort((a, b) => b.days.compareTo(a.days));

  return result;
});

/// Bahşiş dağıtım controller'ı.
final tipDistributionControllerProvider =
    AsyncNotifierProvider<TipDistributionController, void>(
        TipDistributionController.new);

class TipDistributionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Açık bahşişi dağıtılmış olarak kaydeder.
  /// [amount]: dağıtılan tutar (kuruş). [periodStart]/[periodEnd]: kapsanan dönem.
  Future<void> distribute({
    required int amount,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(tipDistributionRepositoryProvider).add(
            TipDistribution(
              id: '',
              date: DateTime.now(),
              amount: amount,
              periodStart: periodStart,
              periodEnd: periodEnd,
            ),
          );
      ref.invalidate(allTipDistributionsProvider);
      ref.invalidate(allDailyRecordsProvider);
    });
  }
}
```

- [ ] **Step 2: analyze**

```powershell
flutter analyze
```

Beklenen: 0 issue.

- [ ] **Step 3: Commit**

```powershell
git add lib/features/weekly_summary/application/weekly_providers.dart
git commit -m "feat(weekly): weekly_providers (offset, range, records, openTips, staffDays, TipDistributionController)"
```

---

## Task 6: WeeklyBarChart widget

**Files:**
- Create: `lib/features/weekly_summary/presentation/widgets/weekly_bar_chart.dart`

- [ ] **Step 1: WeeklyBarChart yaz**

`lib/features/weekly_summary/presentation/widgets/weekly_bar_chart.dart`:

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/utils/date_utils.dart';
import '../../../daily_record/domain/daily_record.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.records,
    required this.weekRange,
  });

  final List<DailyRecord> records;
  final DateRange weekRange;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final recordMap = {for (final r in records) dayKey(r.date): r};

    final groups = List.generate(7, (i) {
      final day = DateTime(
        weekRange.start.year,
        weekRange.start.month,
        weekRange.start.day + i,
      );
      final key = dayKey(day);
      final revenue = (recordMap[key]?.revenue ?? 0) / 100.0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: revenue,
            color: Theme.of(context).colorScheme.primary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: groups,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}₺',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final day = DateTime(
                    weekRange.start.year,
                    weekRange.start.month,
                    weekRange.start.day + value.toInt(),
                  );
                  final label =
                      intl.DateFormat('E', locale).format(day).substring(0, 3);
                  return Text(label, style: const TextStyle(fontSize: 11));
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = DateTime(
                  weekRange.start.year,
                  weekRange.start.month,
                  weekRange.start.day + group.x,
                );
                final key = dayKey(day);
                final rev = recordMap[key]?.revenue ?? 0;
                return BarTooltipItem(
                  '${(rev / 100).toStringAsFixed(0)} ₺',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: analyze**

```powershell
flutter analyze
```

Beklenen: 0 issue.

- [ ] **Step 3: Commit**

```powershell
git add lib/features/weekly_summary/presentation/widgets/weekly_bar_chart.dart
git commit -m "feat(weekly): WeeklyBarChart widget (fl_chart, günlük ciro)"
```

---

## Task 7: DailySummaryList widget

**Files:**
- Create: `lib/features/weekly_summary/presentation/widgets/daily_summary_list.dart`

- [ ] **Step 1: DailySummaryList yaz**

`lib/features/weekly_summary/presentation/widgets/daily_summary_list.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../daily_record/domain/daily_record.dart';

class DailySummaryList extends StatelessWidget {
  const DailySummaryList({
    super.key,
    required this.records,
    required this.weekRange,
  });

  final List<DailyRecord> records;
  final DateRange weekRange;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final recordMap = {for (final r in records) dayKey(r.date): r};
    final days = List.generate(
      7,
      (i) => DateTime(
        weekRange.start.year,
        weekRange.start.month,
        weekRange.start.day + i,
      ),
    );

    return Column(
      children: days.map((day) {
        final key = dayKey(day);
        final record = recordMap[key];
        final dateLabel =
            intl.DateFormat('d MMM, EEEE', locale).format(day);

        if (record == null) {
          return ListTile(
            dense: true,
            title: Text(dateLabel,
                style: const TextStyle(fontStyle: FontStyle.italic)),
            subtitle: const Text('—'),
          );
        }

        return ListTile(
          dense: true,
          title: Text(dateLabel),
          subtitle: Text(
            'Ciro: ${record.revenue.toCurrency(locale)}  |  Kasa: ${record.dailyCash.toCurrency(locale)}',
          ),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () => context.push('/daily',
              extra: {'date': '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}'}),
        );
      }).toList(),
    );
  }
}
```

- [ ] **Step 2: analyze**

```powershell
flutter analyze
```

Beklenen: 0 issue.

- [ ] **Step 3: Commit**

```powershell
git add lib/features/weekly_summary/presentation/widgets/daily_summary_list.dart
git commit -m "feat(weekly): DailySummaryList widget (haftalık günlük kayıt listesi)"
```

---

## Task 8: StaffDaysTable widget

**Files:**
- Create: `lib/features/weekly_summary/presentation/widgets/staff_days_table.dart`

- [ ] **Step 1: StaffDaysTable yaz**

`lib/features/weekly_summary/presentation/widgets/staff_days_table.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../staff/domain/staff.dart';

class StaffDaysTable extends StatelessWidget {
  const StaffDaysTable({
    super.key,
    required this.staffDays,
  });

  final List<({Staff staff, int days})> staffDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (staffDays.isEmpty) {
      return const SizedBox.shrink();
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          children: [
            _cell(l10n.staffName, bold: true),
            _cell(l10n.staffRole, bold: true),
            _cell(l10n.staffDaysTitle, bold: true, align: TextAlign.center),
          ],
        ),
        ...staffDays.map(
          (entry) => TableRow(
            children: [
              _cell(entry.staff.name),
              _cell(_roleLabel(context, entry.staff.role)),
              _cell('${entry.days}', align: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(String text, {bool bold = false, TextAlign align = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        textAlign: align,
        style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
    );
  }

  String _roleLabel(BuildContext context, StaffRole role) {
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case StaffRole.garson:
        return l10n.roleGarson;
      case StaffRole.asci:
        return l10n.roleAsci;
      case StaffRole.barmen:
        return l10n.roleBarmen;
      case StaffRole.kasiyer:
        return l10n.roleKasiyer;
      case StaffRole.diger:
        return l10n.roleDiger;
    }
  }
}
```

- [ ] **Step 2: analyze**

```powershell
flutter analyze
```

Beklenen: 0 issue.

- [ ] **Step 3: Commit**

```powershell
git add lib/features/weekly_summary/presentation/widgets/staff_days_table.dart
git commit -m "feat(weekly): StaffDaysTable widget (ad, rol, gün)"
```

---

## Task 9: WeeklySummaryScreen + router

**Files:**
- Create: `lib/features/weekly_summary/presentation/weekly_summary_screen.dart`
- Modify: `lib/app/router.dart`

- [ ] **Step 1: WeeklySummaryScreen yaz**

`lib/features/weekly_summary/presentation/weekly_summary_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/extensions/currency_extension.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../application/weekly_providers.dart';
import 'widgets/daily_summary_list.dart';
import 'widgets/staff_days_table.dart';
import 'widgets/weekly_bar_chart.dart';

class WeeklySummaryScreen extends ConsumerWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final weekRange = ref.watch(currentWeekRangeProvider);
    final offset = ref.watch(weekOffsetProvider);
    final recordsAsync = ref.watch(weeklyRecordsProvider);
    final openTipsAsync = ref.watch(openTipsProvider);
    final staffDaysAsync = ref.watch(weeklyStaffDaysProvider);

    final startLabel = intl.DateFormat('d MMM', locale).format(weekRange.start);
    final endLabel = intl.DateFormat('d MMM y', locale).format(
      weekRange.end.subtract(const Duration(days: 1)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.openWeeklySummary),
        actions: [
          IconButton(
            tooltip: l10n.prevWeek,
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                ref.read(weekOffsetProvider.notifier).state = offset - 1,
          ),
          IconButton(
            tooltip: l10n.nextWeek,
            icon: const Icon(Icons.chevron_right),
            onPressed: offset >= 0
                ? null
                : () =>
                    ref.read(weekOffsetProvider.notifier).state = offset + 1,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '$startLabel – $endLabel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Bar grafik
            recordsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (records) => records.isEmpty
                  ? Center(child: Text(l10n.noRecordsThisWeek))
                  : WeeklyBarChart(records: records, weekRange: weekRange),
            ),
            const SizedBox(height: 16),

            // Açık bahşiş + Dağıtıldı butonu
            openTipsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('$e'),
              data: (openTips) => _OpenTipsSection(
                openTips: openTips,
                locale: locale,
                weekRange: weekRange,
              ),
            ),
            const SizedBox(height: 16),

            // Günlük özet listesi
            Text(l10n.dailyRecord,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            recordsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('$e'),
              data: (records) =>
                  DailySummaryList(records: records, weekRange: weekRange),
            ),
            const SizedBox(height: 16),

            // Personel günleri tablosu
            Text(l10n.staffDaysTitle,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            staffDaysAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('$e'),
              data: (staffDays) => StaffDaysTable(staffDays: staffDays),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenTipsSection extends ConsumerWidget {
  const _OpenTipsSection({
    required this.openTips,
    required this.locale,
    required this.weekRange,
  });

  final int openTips;
  final String locale;
  final ({DateTime start, DateTime end}) weekRange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ctrl = ref.read(tipDistributionControllerProvider.notifier);
    final ctrlState = ref.watch(tipDistributionControllerProvider);

    if (openTips <= 0) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: Text(l10n.noOpenTips),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.openTips,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(openTips.toCurrency(locale),
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: ctrlState.isLoading
                  ? null
                  : () async {
                      final confirmed = await showConfirmDialog(
                        context: context,
                        title: l10n.distributeTipsConfirmTitle,
                        body: l10n.distributeTipsConfirmBody(
                            openTips.toCurrency(locale)),
                      );
                      if (confirmed != true) return;
                      await ctrl.distribute(
                        amount: openTips,
                        periodStart: weekRange.start,
                        periodEnd: DateTime.now(),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.tipsDistributed)),
                        );
                      }
                    },
              child: Text(l10n.distributeTips),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: confirm_dialog.dart içinde showConfirmDialog fonksiyonunu kontrol et**

`lib/shared/widgets/confirm_dialog.dart` dosyasını oku ve `showConfirmDialog` fonksiyonunun `body` parametresini destekleyip desteklemediğini kontrol et. Desteklemiyorsa `_OpenTipsSection`'daki çağrıyı `showDialog` ile manuel yaz.

Mevcut `confirm_dialog.dart`'ı oku; `body` parametresi yoksa `_OpenTipsSection`'daki `showConfirmDialog` çağrısını şunla değiştir:

```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text(l10n.distributeTipsConfirmTitle),
    content: Text(l10n.distributeTipsConfirmBody(
        openTips.toCurrency(locale))),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(ctx).pop(false),
        child: Text(l10n.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.of(ctx).pop(true),
        child: Text(l10n.distributeTips),
      ),
    ],
  ),
);
```

- [ ] **Step 3: router.dart güncelle — /weekly placeholder'ı değiştir**

`lib/app/router.dart` dosyasında `WeeklySummaryScreen` import'unu ekle:

```dart
import '../features/weekly_summary/presentation/weekly_summary_screen.dart';
```

`/weekly` route'unu güncelle:

```dart
GoRoute(
  path: '/weekly',
  builder: (context, state) => const WeeklySummaryScreen(),
),
```

`_PlaceholderScreen` sınıfını **yalnızca** `/monthly` hâlâ kullanıyorsa bırak. `/weekly` için artık kullanılmıyor.

- [ ] **Step 4: analyze**

```powershell
flutter analyze
```

Beklenen: 0 issue.

- [ ] **Step 5: Commit**

```powershell
git add lib/features/weekly_summary/presentation/ lib/app/router.dart
git commit -m "feat(weekly): WeeklySummaryScreen + router /weekly güncellemesi"
```

---

## Task 10: Widget testleri + tam doğrulama

**Files:**
- Create: `test/features/weekly_summary/weekly_summary_screen_test.dart`
- Modify: `PROGRESS.md`

- [ ] **Step 1: Widget testini yaz**

`test/features/weekly_summary/weekly_summary_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/utils/date_utils.dart';
import 'package:gilanli_meyhane/features/daily_record/application/daily_record_providers.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record_calculator.dart';
import 'package:gilanli_meyhane/features/staff/application/staff_providers.dart';
import 'package:gilanli_meyhane/features/staff/data/mock_staff_repository.dart';
import 'package:gilanli_meyhane/features/weekly_summary/application/weekly_providers.dart';
import 'package:gilanli_meyhane/features/weekly_summary/data/mock_tip_distribution_repository.dart';
import 'package:gilanli_meyhane/features/weekly_summary/presentation/weekly_summary_screen.dart';
import 'package:gilanli_meyhane/app/app.dart';

DailyRecord _rec(DateTime date, {int revenue = 100000}) {
  final daily = DailyRecordCalculator.dailyCash(
    revenue: revenue,
    creditCard: 0,
    tips: 0,
    cashExpenses: 0,
    creditSales: 0,
  );
  return DailyRecord(
    id: dayKey(date),
    date: date,
    revenue: revenue,
    creditCard: 0,
    tips: 0,
    ownerExpenses: 0,
    cashExpenses: 0,
    creditSales: 0,
    previousDayCash: 0,
    dailyCash: daily,
    totalCash: daily,
  );
}

Widget _wrap(Widget child, {
  MockDailyRecordRepository? dailyRepo,
  MockStaffRepository? staffRepo,
  MockTipDistributionRepository? tipRepo,
}) {
  return ProviderScope(
    overrides: [
      dailyRecordRepositoryProvider
          .overrideWithValue(dailyRepo ?? MockDailyRecordRepository()),
      staffRepositoryProvider
          .overrideWithValue(staffRepo ?? MockStaffRepository()),
      tipDistributionRepositoryProvider
          .overrideWithValue(tipRepo ?? MockTipDistributionRepository()),
    ],
    child: GilanliApp(home: child),
  );
}

void main() {
  testWidgets('Haftalık Özet ekranı AppBar başlığı ve navigasyon butonları',
      (tester) async {
    await tester.pumpWidget(_wrap(const WeeklySummaryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Haftalık Özet'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('Kayıt yoksa noRecordsThisWeek mesajı görünür', (tester) async {
    await tester.pumpWidget(_wrap(const WeeklySummaryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Bu hafta kayıt bulunmuyor.'), findsOneWidget);
  });

  testWidgets('Kayıt varsa bar grafik render edilir', (tester) async {
    final repo = MockDailyRecordRepository();
    final monday = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    final rec = _rec(DateTime(monday.year, monday.month, monday.day),
        revenue: 500000);
    repo.store[rec.id] = rec;

    await tester.pumpWidget(_wrap(const WeeklySummaryScreen(), dailyRepo: repo));
    await tester.pumpAndSettle();

    // Bar grafik yüklenmiş, "Bu hafta kayıt bulunmuyor" gösteriliyor olmamalı
    expect(find.text('Bu hafta kayıt bulunmuyor.'), findsNothing);
  });

  testWidgets('Açık bahşiş yoksa noOpenTips kartı görünür', (tester) async {
    await tester.pumpWidget(_wrap(const WeeklySummaryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Dağıtılacak bahşiş yok.'), findsOneWidget);
  });
}
```

> **Not:** `GilanliApp` widget'ının `home` parametresi yoksa testi şöyle yaz:
>
> ```dart
> Widget _wrap(Widget child, {...}) {
>   return ProviderScope(
>     overrides: [...],
>     child: MaterialApp(
>       localizationsDelegates: AppLocalizations.localizationsDelegates,
>       supportedLocales: AppLocalizations.supportedLocales,
>       home: child,
>     ),
>   );
> }
> ```
>
> `GilanliApp`'in `home` parametresini destekleyip desteklemediğini `lib/app/app.dart`'a bakarak kontrol et; desteklemiyorsa `MaterialApp` kullan.

- [ ] **Step 2: app.dart kontrol + gerekirse _wrap düzelt**

`lib/app/app.dart` dosyasını oku. `GilanliApp`'in `home` veya `overrides` kabul edip etmediğini gör. Desteklemiyorsa testlerdeki `_wrap` fonksiyonunu `MaterialApp` ile güncelle.

- [ ] **Step 3: Tüm testleri çalıştır**

```powershell
flutter test
```

Beklenen: önceki testler + yeni testler hepsi PASS (yaklaşık 100+ test).

- [ ] **Step 4: analyze**

```powershell
flutter analyze
```

Beklenen: 0 issue.

- [ ] **Step 5: PROGRESS.md güncelle**

`PROGRESS.md` dosyasında Faz 8 satırını güncelle:

```markdown
- [x] **Faz 8 — Haftalık Özet** ✅ tamam (X test, analyze temiz)
```

Son güncelleme tarihini ve aktif fazı da güncelle:
```markdown
**Son güncelleme:** 2026-06-03
**Aktif faz:** Faz 9 — Aylık Özet
```

Faz 8 adımlarını ekle:
```markdown
## Faz 8 — Adımlar

- [x] T1: ARB TR/EN string'leri (12 yeni) + gen-l10n
- [x] T2: TipDistribution modeli (TDD, 3 test)
- [x] T3: TipDistributionRepository üçlüsü (abstract/Firestore/Mock)
- [x] T4: DailyRecordRepository.getByDateRange() + 3 Mock testi
- [x] T5: weekly_providers.dart (weekOffset, weekRange, weeklyRecords, openTips, staffDays, TipDistributionController)
- [x] T6: WeeklyBarChart widget (fl_chart, 7 bar)
- [x] T7: DailySummaryList widget (haftalık günlük liste)
- [x] T8: StaffDaysTable widget (ad, rol, gün)
- [x] T9: WeeklySummaryScreen + router /weekly güncelleme
- [x] T10: Widget testleri (4) + tam doğrulama + PROGRESS güncelleme
```

- [ ] **Step 6: Commit**

```powershell
git add test/features/weekly_summary/weekly_summary_screen_test.dart PROGRESS.md
git commit -m "test(weekly): WeeklySummaryScreen widget testleri (4) + PROGRESS Faz 8 tamamlandı"
```

---

## Kabul Kriterleri

- `flutter test` yeşil (tüm testler PASS)
- `flutter analyze` 0 issue
- `/weekly` rotası artık gerçek `WeeklySummaryScreen`'e gidiyor
- Bar grafik mevcut haftanın günlük cirolarını gösteriyor
- `<` `>` ile hafta değiştirilebiliyor; bu haftadan ileriye geçilemiyor (`>` butonu disable)
- "Dağıtılmamış Bahşiş" bölümü doğru miktarı gösteriyor; "Dağıtıldı, Kapat" onay dialog'u açıp `tipDistributions`'a kayıt yazıyor
- Personel günleri tablosu haftada çalışan personeli gösteriyor
- TR/EN string hardcode yok
