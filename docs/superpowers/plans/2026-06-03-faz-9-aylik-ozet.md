# Faz 9 — Aylık Özet Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aylık özet ekranını inşa etmek: `MonthlyReportCalculator` (TDD), aylık providers, özet kartlar, günlük ciro bar grafiği, veresiye tablosu ve ay gezinme.

**Architecture:** `MonthlyReportCalculator` (saf, TDD) + `MonthlyReport` data class + `monthly_providers.dart` (offset/range/records/credits/wages/report) + `MonthlySummaryScreen` (3 widget + navigasyon). `CreditSaleRepository`'ye `getByDateRange` eklenir. Tüm tutarlar `int` kuruş.

**Tech Stack:** Flutter · Riverpod · fl_chart · intl · go_router · fake_cloud_firestore (test) · mocktail

---

## Dosya Yapısı

| Yeni Dosyalar | Sorumluluk |
|---|---|
| `lib/features/monthly_summary/domain/monthly_report.dart` | MonthlyReport data class (equatable) |
| `lib/features/monthly_summary/domain/monthly_report_calculator.dart` | TDD saf hesaplama — §3.5 formülü |
| `lib/features/monthly_summary/application/monthly_providers.dart` | monthOffset, monthRange, records, credits, wages, report |
| `lib/features/monthly_summary/presentation/monthly_summary_screen.dart` | Ana ekran |
| `lib/features/monthly_summary/presentation/widgets/monthly_bar_chart.dart` | Günlük ciro bar grafiği (fl_chart) |
| `lib/features/monthly_summary/presentation/widgets/monthly_credit_table.dart` | Ay içi veresiye tablosu |
| `lib/features/monthly_summary/presentation/widgets/summary_cards_section.dart` | Özet stat kartları (Wrap grid) |
| `test/features/monthly_summary/monthly_report_calculator_test.dart` | TDD birim testleri |
| `test/features/monthly_summary/monthly_providers_test.dart` | Provider birim testleri |
| `test/features/monthly_summary/monthly_summary_screen_test.dart` | Widget testleri |

| Değiştirilen Dosyalar | Değişiklik |
|---|---|
| `lib/core/l10n/app_tr.arb` | 12 yeni string |
| `lib/core/l10n/app_en.arb` | 12 yeni string |
| `lib/features/credit_book/data/credit_sale_repository.dart` | `getByDateRange` abstract |
| `lib/features/credit_book/data/firestore_credit_sale_repository.dart` | `getByDateRange` impl |
| `lib/features/credit_book/data/mock_credit_sale_repository.dart` | `getByDateRange` impl |
| `lib/app/router.dart` | `/monthly` placeholder → `MonthlySummaryScreen` |
| `PROGRESS.md` | Faz 9 adımları + kabul kaydı |

---

## Task 1: Git branch + ARB strings + gen-l10n

**Files:**
- Modify: `lib/core/l10n/app_tr.arb`
- Modify: `lib/core/l10n/app_en.arb`

- [ ] **Step 1: Branch aç**

```powershell
git checkout -b phase-9-monthly-summary
```

Expected: `Switched to a new branch 'phase-9-monthly-summary'`

- [ ] **Step 2: `app_tr.arb` sonuna 12 string ekle** (kapanış `}` öncesine virgül + yeni satırlar)

```json
  "prevMonth": "Önceki Ay",
  "@prevMonth": { "description": "Aylık özet — önceki ay butonu tooltip" },
  "nextMonth": "Sonraki Ay",
  "@nextMonth": { "description": "Aylık özet — sonraki ay butonu tooltip" },
  "monthlyRevenue": "Aylık Ciro",
  "@monthlyRevenue": { "description": "Aylık özet — ciro kartı etiketi" },
  "monthlyCreditCard": "Kredi Kartı",
  "@monthlyCreditCard": { "description": "Aylık özet — kredi kartı kartı etiketi" },
  "monthlyCashExpenses": "Kasa Masrafı",
  "@monthlyCashExpenses": { "description": "Aylık özet — kasa masrafı kartı etiketi" },
  "monthlyOwnerExpenses": "Patron Masrafı",
  "@monthlyOwnerExpenses": { "description": "Aylık özet — patron masrafı kartı etiketi" },
  "monthlyStaffWages": "Personel Ücretleri",
  "@monthlyStaffWages": { "description": "Aylık özet — personel ücretleri kartı etiketi" },
  "monthlyCreditSalesTotal": "Veresiye (Toplam)",
  "@monthlyCreditSalesTotal": { "description": "Aylık özet — veresiye toplam etiketi" },
  "monthlyUncollectible": "Tahsil Edilemeyen",
  "@monthlyUncollectible": { "description": "Aylık özet — tahsil edilemeyen veresiye etiketi" },
  "monthlyProfitLabel": "Kâr / Zarar",
  "@monthlyProfitLabel": { "description": "Aylık özet — kâr zarar kartı etiketi" },
  "noRecordsThisMonth": "Bu ay kayıt bulunmuyor.",
  "@noRecordsThisMonth": { "description": "Aylık özet — kayıt yoksa gösterilen mesaj" },
  "monthlyCreditSalesTable": "Aylık Veresiyeler",
  "@monthlyCreditSalesTable": { "description": "Aylık özet — veresiye tablosu başlığı" }
```

- [ ] **Step 3: `app_en.arb` sonuna 12 string ekle**

```json
  "prevMonth": "Previous Month",
  "nextMonth": "Next Month",
  "monthlyRevenue": "Monthly Revenue",
  "monthlyCreditCard": "Credit Card",
  "monthlyCashExpenses": "Cash Expenses",
  "monthlyOwnerExpenses": "Owner Expenses",
  "monthlyStaffWages": "Staff Wages",
  "monthlyCreditSalesTotal": "Credit Sales (Total)",
  "monthlyUncollectible": "Uncollectible",
  "monthlyProfitLabel": "Profit / Loss",
  "noRecordsThisMonth": "No records this month.",
  "monthlyCreditSalesTable": "Monthly Credit Sales"
```

- [ ] **Step 4: gen-l10n çalıştır**

```powershell
flutter gen-l10n
```

Expected: `lib/core/l10n/generated/` dosyaları güncellendi, hata yok.

- [ ] **Step 5: analyze kontrol**

```powershell
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```powershell
git add lib/core/l10n/app_tr.arb lib/core/l10n/app_en.arb lib/core/l10n/generated/
git commit -m "feat(monthly): ARB TR/EN strings (12 yeni) + gen-l10n"
```

---

## Task 2: MonthlyReport domain data class

**Files:**
- Create: `lib/features/monthly_summary/domain/monthly_report.dart`

- [ ] **Step 1: Dosyayı oluştur**

```dart
// lib/features/monthly_summary/domain/monthly_report.dart
import 'package:equatable/equatable.dart';

/// Bir ay için hesaplanmış özet rapor. Tüm tutarlar int kuruş.
class MonthlyReport extends Equatable {
  const MonthlyReport({
    required this.revenue,
    required this.creditCard,
    required this.cashExpenses,
    required this.ownerExpenses,
    required this.staffWages,
    required this.creditSalesTotal,
    required this.uncollectibleCredit,
    required this.profit,
  });

  final int revenue;
  final int creditCard;
  final int cashExpenses;
  final int ownerExpenses;
  final int staffWages;
  final int creditSalesTotal;
  final int uncollectibleCredit;
  final int profit;

  @override
  List<Object?> get props => [
        revenue,
        creditCard,
        cashExpenses,
        ownerExpenses,
        staffWages,
        creditSalesTotal,
        uncollectibleCredit,
        profit,
      ];
}
```

- [ ] **Step 2: analyze kontrol**

```powershell
flutter analyze
```

Expected: `No issues found!`

---

## Task 3: TDD — MonthlyReportCalculator (§3.5)

**Files:**
- Create: `lib/features/monthly_summary/domain/monthly_report_calculator.dart`
- Create: `test/features/monthly_summary/monthly_report_calculator_test.dart`

- [ ] **Step 1: Test dosyasını oluştur (RED)**

```dart
// test/features/monthly_summary/monthly_report_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/monthly_summary/domain/monthly_report_calculator.dart';

void main() {
  group('MonthlyReportCalculator.monthlyProfit', () {
    test('normal kâr hesabı', () {
      final result = MonthlyReportCalculator.monthlyProfit(
        revenue: 1000000,
        creditCard: 300000,
        cashExpenses: 50000,
        ownerExpenses: 20000,
        staffWages: 200000,
        uncollectibleCredit: 100000,
      );
      // 1_000_000 − 300_000 − (50_000 + 20_000) − 200_000 − 100_000 = 330_000
      expect(result, 330000);
    });

    test('tüm sıfır → 0', () {
      expect(
        MonthlyReportCalculator.monthlyProfit(
          revenue: 0,
          creditCard: 0,
          cashExpenses: 0,
          ownerExpenses: 0,
          staffWages: 0,
          uncollectibleCredit: 0,
        ),
        0,
      );
    });

    test('zarar durumu — negatif sonuç döner', () {
      final result = MonthlyReportCalculator.monthlyProfit(
        revenue: 100000,
        creditCard: 0,
        cashExpenses: 50000,
        ownerExpenses: 20000,
        staffWages: 100000,
        uncollectibleCredit: 50000,
      );
      // 100_000 − 0 − (50_000 + 20_000) − 100_000 − 50_000 = −120_000
      expect(result, -120000);
    });

    test('patron masrafı kâra dahil edilir (günlük kasadan farklı)', () {
      final withoutOwner = MonthlyReportCalculator.monthlyProfit(
        revenue: 500000,
        creditCard: 0,
        cashExpenses: 0,
        ownerExpenses: 0,
        staffWages: 0,
        uncollectibleCredit: 0,
      );
      final withOwner = MonthlyReportCalculator.monthlyProfit(
        revenue: 500000,
        creditCard: 0,
        cashExpenses: 0,
        ownerExpenses: 100000,
        staffWages: 0,
        uncollectibleCredit: 0,
      );
      expect(withoutOwner, 500000);
      expect(withOwner, 400000);
    });

    test('tahsil edilemeyen veresiye kârdan düşülür', () {
      final result = MonthlyReportCalculator.monthlyProfit(
        revenue: 500000,
        creditCard: 0,
        cashExpenses: 0,
        ownerExpenses: 0,
        staffWages: 0,
        uncollectibleCredit: 200000,
      );
      expect(result, 300000);
    });
  });
}
```

- [ ] **Step 2: Testi çalıştır — RED olduğunu doğrula**

```powershell
flutter test test/features/monthly_summary/monthly_report_calculator_test.dart
```

Expected: FAIL (sınıf henüz yok)

- [ ] **Step 3: `monthly_report_calculator.dart` oluştur (GREEN)**

```dart
// lib/features/monthly_summary/domain/monthly_report_calculator.dart

/// Aylık Kâr/Zarar hesaplama servisi. §3.5 formülü.
/// Tüm parametreler int kuruş. Bahşiş dahil DEĞİL.
class MonthlyReportCalculator {
  MonthlyReportCalculator._();

  static int monthlyProfit({
    required int revenue,
    required int creditCard,
    required int cashExpenses,
    required int ownerExpenses,
    required int staffWages,
    required int uncollectibleCredit,
  }) =>
      revenue -
      creditCard -
      (cashExpenses + ownerExpenses) -
      staffWages -
      uncollectibleCredit;
}
```

- [ ] **Step 4: Testi çalıştır — GREEN olduğunu doğrula**

```powershell
flutter test test/features/monthly_summary/monthly_report_calculator_test.dart
```

Expected: `All tests passed! (5)`

- [ ] **Step 5: Commit**

```powershell
git add lib/features/monthly_summary/domain/ test/features/monthly_summary/monthly_report_calculator_test.dart
git commit -m "feat(monthly): TDD MonthlyReport + MonthlyReportCalculator (5 test)"
```

---

## Task 4: CreditSaleRepository — getByDateRange

**Files:**
- Modify: `lib/features/credit_book/data/credit_sale_repository.dart`
- Modify: `lib/features/credit_book/data/firestore_credit_sale_repository.dart`
- Modify: `lib/features/credit_book/data/mock_credit_sale_repository.dart`

- [ ] **Step 1: Abstract arayüze metod ekle**

`lib/features/credit_book/data/credit_sale_repository.dart` dosyasını şu hale getir:

```dart
import '../../../core/utils/date_utils.dart';
import '../domain/credit_sale.dart';

abstract class CreditSaleRepository {
  Stream<List<CreditSale>> watchAll();
  Future<String> add(CreditSale sale);
  Future<void> update(CreditSale sale);
  Future<CreditSale?> getById(String id);

  /// [range.start] dahil, [range.end] hariç tarihe sahip veresiyeler.
  Future<List<CreditSale>> getByDateRange(DateRange range);
}
```

- [ ] **Step 2: Firestore impl'ine ekle**

`lib/features/credit_book/data/firestore_credit_sale_repository.dart` dosyasına `getByDateRange` metodunu ekle:

```dart
  @override
  Future<List<CreditSale>> getByDateRange(DateRange range) async {
    final snap = await _col
        .where('date',
            isGreaterThanOrEqualTo: range.start.toIso8601String())
        .where('date', isLessThan: range.end.toIso8601String())
        .get();
    return snap.docs
        .map((d) => CreditSale.fromMap(d.id, d.data()))
        .toList();
  }
```

- [ ] **Step 3: Mock impl'ine ekle**

`lib/features/credit_book/data/mock_credit_sale_repository.dart` dosyasına `getByDateRange` metodunu ekle:

```dart
  @override
  Future<List<CreditSale>> getByDateRange(DateRange range) async {
    return store.values
        .where((c) =>
            !c.date.isBefore(range.start) && c.date.isBefore(range.end))
        .toList();
  }
```

- [ ] **Step 4: Testleri çalıştır — tüm yeşil**

```powershell
flutter test
```

Expected: tüm testler yeşil (107 civarı — önceki 102 + 5 yeni)

- [ ] **Step 5: Commit**

```powershell
git add lib/features/credit_book/data/
git commit -m "feat(monthly): CreditSaleRepository.getByDateRange (3 impl)"
```

---

## Task 5: monthly_providers.dart

**Files:**
- Create: `lib/features/monthly_summary/application/monthly_providers.dart`
- Create: `test/features/monthly_summary/monthly_providers_test.dart`

- [ ] **Step 1: Test dosyasını oluştur (RED için)**

```dart
// test/features/monthly_summary/monthly_providers_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/utils/date_utils.dart';
import 'package:gilanli_meyhane/features/credit_book/application/credit_book_providers.dart';
import 'package:gilanli_meyhane/features/credit_book/data/mock_credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/application/daily_record_providers.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record_calculator.dart';
import 'package:gilanli_meyhane/features/monthly_summary/application/monthly_providers.dart';
import 'package:gilanli_meyhane/features/staff/application/staff_providers.dart';
import 'package:gilanli_meyhane/features/staff/data/mock_staff_repository.dart';

DailyRecord _makeRecord(DateTime date,
    {int revenue = 100000,
    int creditCard = 0,
    int cashExpenses = 0,
    int ownerExpenses = 0}) {
  final daily = DailyRecordCalculator.dailyCash(
    revenue: revenue,
    creditCard: creditCard,
    tips: 0,
    cashExpenses: cashExpenses,
    creditSales: 0,
  );
  return DailyRecord(
    id: dayKey(date),
    date: date,
    revenue: revenue,
    creditCard: creditCard,
    tips: 0,
    ownerExpenses: ownerExpenses,
    cashExpenses: cashExpenses,
    creditSales: 0,
    previousDayCash: 0,
    dailyCash: daily,
    totalCash: daily,
  );
}

ProviderContainer _makeContainer({
  MockDailyRecordRepository? dailyRepo,
  MockCreditSaleRepository? creditRepo,
  MockStaffRepository? staffRepo,
}) {
  return ProviderContainer(overrides: [
    dailyRecordRepositoryProvider
        .overrideWithValue(dailyRepo ?? MockDailyRecordRepository()),
    creditSaleRepositoryProvider
        .overrideWithValue(creditRepo ?? MockCreditSaleRepository()),
    staffRepositoryProvider
        .overrideWithValue(staffRepo ?? MockStaffRepository()),
  ]);
}

void main() {
  group('MonthOffsetNotifier', () {
    test('başlangıç değeri 0', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      expect(c.read(monthOffsetProvider), 0);
    });

    test('previous() → -1', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      c.read(monthOffsetProvider.notifier).previous();
      expect(c.read(monthOffsetProvider), -1);
    });

    test('previous() + next() → 0', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      c.read(monthOffsetProvider.notifier).previous();
      c.read(monthOffsetProvider.notifier).next();
      expect(c.read(monthOffsetProvider), 0);
    });
  });

  group('monthlyReportProvider', () {
    test('kayıt yoksa tüm değerler 0', () async {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final report = await c.read(monthlyReportProvider.future);
      expect(report.revenue, 0);
      expect(report.profit, 0);
    });

    test('ay içindeki kayıtlar doğru toplanır', () async {
      final dailyRepo = MockDailyRecordRepository();
      final now = DateTime.now();
      final rec = _makeRecord(
        DateTime(now.year, now.month, 1),
        revenue: 500000,
        creditCard: 100000,
        cashExpenses: 30000,
        ownerExpenses: 20000,
      );
      dailyRepo.store[rec.id] = rec;

      final c = _makeContainer(dailyRepo: dailyRepo);
      addTearDown(c.dispose);

      final report = await c.read(monthlyReportProvider.future);
      expect(report.revenue, 500000);
      expect(report.creditCard, 100000);
      expect(report.cashExpenses, 30000);
      expect(report.ownerExpenses, 20000);
      // profit: 500000 - 100000 - (30000 + 20000) - 0 - 0 = 350000
      expect(report.profit, 350000);
    });
  });
}
```

- [ ] **Step 2: Testi çalıştır — RED olduğunu doğrula**

```powershell
flutter test test/features/monthly_summary/monthly_providers_test.dart
```

Expected: FAIL (monthly_providers henüz yok)

- [ ] **Step 3: `monthly_providers.dart` oluştur**

```dart
// lib/features/monthly_summary/application/monthly_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../credit_book/application/credit_book_providers.dart';
import '../../credit_book/domain/credit_sale.dart';
import '../../daily_record/application/daily_record_providers.dart';
import '../../daily_record/domain/daily_record.dart';
import '../../payments/domain/payroll_calculator.dart';
import '../../staff/application/staff_providers.dart';
import '../domain/monthly_report.dart';
import '../domain/monthly_report_calculator.dart';

/// Ay navigasyon ofseti: 0 = bu ay, -1 = geçen ay, vb.
final monthOffsetProvider =
    NotifierProvider<MonthOffsetNotifier, int>(MonthOffsetNotifier.new);

class MonthOffsetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void previous() => state = state - 1;
  void next() => state = state + 1;
}

/// Offset'e göre hesaplanan ayın aralığı.
final currentMonthRangeProvider = Provider<DateRange>((ref) {
  final offset = ref.watch(monthOffsetProvider);
  final base = DateTime.now();
  final shifted = DateTime(base.year, base.month + offset, 1);
  return monthRange(shifted);
});

/// Mevcut ayın günlük kayıtları.
final monthlyRecordsProvider = FutureProvider<List<DailyRecord>>((ref) async {
  final range = ref.watch(currentMonthRangeProvider);
  return ref.watch(dailyRecordRepositoryProvider).getByDateRange(range);
});

/// Mevcut ayın veresiye kayıtları.
final monthlyCreditSalesProvider =
    FutureProvider<List<CreditSale>>((ref) async {
  final range = ref.watch(currentMonthRangeProvider);
  return ref.watch(creditSaleRepositoryProvider).getByDateRange(range);
});

/// Mevcut ay için tüm personelin toplam tahakkuk ücreti.
final monthlyStaffWagesProvider = FutureProvider<int>((ref) async {
  final records = await ref.watch(monthlyRecordsProvider.future);
  final allStaff = await ref.watch(allStaffProvider.future);
  return allStaff.fold<int>(
      0, (sum, s) => sum + PayrollCalculator.accrue(s, records).accruedWage);
});

/// Aylık özet raporu (tüm kartların verisi).
final monthlyReportProvider = FutureProvider<MonthlyReport>((ref) async {
  final records = await ref.watch(monthlyRecordsProvider.future);
  final credits = await ref.watch(monthlyCreditSalesProvider.future);
  final staffWages = await ref.watch(monthlyStaffWagesProvider.future);

  final revenue = records.fold<int>(0, (s, r) => s + r.revenue);
  final creditCard = records.fold<int>(0, (s, r) => s + r.creditCard);
  final cashExpenses = records.fold<int>(0, (s, r) => s + r.cashExpenses);
  final ownerExpenses = records.fold<int>(0, (s, r) => s + r.ownerExpenses);
  final creditSalesTotal =
      credits.fold<int>(0, (s, c) => s + c.totalAmount);
  final uncollectible =
      credits.fold<int>(0, (s, c) => s + c.remainingAmount);

  final profit = MonthlyReportCalculator.monthlyProfit(
    revenue: revenue,
    creditCard: creditCard,
    cashExpenses: cashExpenses,
    ownerExpenses: ownerExpenses,
    staffWages: staffWages,
    uncollectibleCredit: uncollectible,
  );

  return MonthlyReport(
    revenue: revenue,
    creditCard: creditCard,
    cashExpenses: cashExpenses,
    ownerExpenses: ownerExpenses,
    staffWages: staffWages,
    creditSalesTotal: creditSalesTotal,
    uncollectibleCredit: uncollectible,
    profit: profit,
  );
});
```

- [ ] **Step 4: Testi çalıştır — GREEN**

```powershell
flutter test test/features/monthly_summary/monthly_providers_test.dart
```

Expected: `All tests passed! (5)`

- [ ] **Step 5: Commit**

```powershell
git add lib/features/monthly_summary/application/ test/features/monthly_summary/monthly_providers_test.dart
git commit -m "feat(monthly): monthly_providers (offset, range, records, credits, wages, report) + 5 test"
```

---

## Task 6: MonthlyBarChart widget

**Files:**
- Create: `lib/features/monthly_summary/presentation/widgets/monthly_bar_chart.dart`

- [ ] **Step 1: Dosyayı oluştur**

```dart
// lib/features/monthly_summary/presentation/widgets/monthly_bar_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../daily_record/domain/daily_record.dart';

/// Bir aydaki günlük ciro bar grafiği (fl_chart).
/// Her bar bir günü temsil eder; alt etiketlerde 1, 5, 10, 15, 20, 25, 30/31.
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    super.key,
    required this.records,
    required this.monthRange,
  });

  final List<DailyRecord> records;
  final DateRange monthRange;

  @override
  Widget build(BuildContext context) {
    final recordMap = {for (final r in records) dayKey(r.date): r};
    // Ayın son günü = monthRange.end − 1 gün
    final lastDay =
        monthRange.end.subtract(const Duration(days: 1));
    final daysInMonth = lastDay.day;

    final groups = List.generate(daysInMonth, (i) {
      final day = DateTime(
        monthRange.start.year,
        monthRange.start.month,
        i + 1,
      );
      final revenue = (recordMap[dayKey(day)]?.revenue ?? 0) / 100.0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: revenue,
            color: Theme.of(context).colorScheme.primary,
            width: 8,
            borderRadius: BorderRadius.circular(2),
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
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
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
                  final d = value.toInt() + 1;
                  if (d == 1 || d % 5 == 0) {
                    return Text('$d',
                        style: const TextStyle(fontSize: 10));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = DateTime(
                  monthRange.start.year,
                  monthRange.start.month,
                  group.x + 1,
                );
                final rev = recordMap[dayKey(day)]?.revenue ?? 0;
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

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```powershell
git add lib/features/monthly_summary/presentation/widgets/monthly_bar_chart.dart
git commit -m "feat(monthly): MonthlyBarChart widget (fl_chart, günlük ciro)"
```

---

## Task 7: MonthlyCreditTable widget

**Files:**
- Create: `lib/features/monthly_summary/presentation/widgets/monthly_credit_table.dart`

- [ ] **Step 1: Dosyayı oluştur**

```dart
// lib/features/monthly_summary/presentation/widgets/monthly_credit_table.dart
import 'package:flutter/material.dart';

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../credit_book/domain/credit_sale.dart';

/// Ay içindeki veresiye kayıtları tablosu.
class MonthlyCreditTable extends StatelessWidget {
  const MonthlyCreditTable({super.key, required this.credits});

  final List<CreditSale> credits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    if (credits.isEmpty) {
      return Text(l10n.noCreditSales);
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
          ),
          children: [
            _header(l10n.creditCustomer),
            _header(l10n.creditTotalAmount),
            _header(l10n.creditRemainingAmount),
          ],
        ),
        ...credits.map(
          (c) => TableRow(
            children: [
              _cell(c.customerName),
              _cell(c.totalAmount.toCurrency(locale)),
              _cell(c.remainingAmount.toCurrency(locale)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          text,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12),
        ),
      );

  Widget _cell(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(text, style: const TextStyle(fontSize: 13)),
      );
}
```

- [ ] **Step 2: analyze**

```powershell
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```powershell
git add lib/features/monthly_summary/presentation/widgets/monthly_credit_table.dart
git commit -m "feat(monthly): MonthlyCreditTable widget"
```

---

## Task 8: SummaryCardsSection widget

**Files:**
- Create: `lib/features/monthly_summary/presentation/widgets/summary_cards_section.dart`

- [ ] **Step 1: Dosyayı oluştur**

```dart
// lib/features/monthly_summary/presentation/widgets/summary_cards_section.dart
import 'package:flutter/material.dart';

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/monthly_report.dart';

/// Aylık özet istatistik kartları (Wrap grid).
class SummaryCardsSection extends StatelessWidget {
  const SummaryCardsSection({super.key, required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatCard(
          label: l10n.monthlyRevenue,
          value: report.revenue.toCurrency(locale),
          color: cs.primary,
        ),
        _StatCard(
          label: l10n.monthlyCreditCard,
          value: report.creditCard.toCurrency(locale),
          color: cs.error,
        ),
        _StatCard(
          label: l10n.monthlyCashExpenses,
          value: report.cashExpenses.toCurrency(locale),
          color: cs.error,
        ),
        _StatCard(
          label: l10n.monthlyOwnerExpenses,
          value: report.ownerExpenses.toCurrency(locale),
          color: cs.error,
        ),
        _StatCard(
          label: l10n.monthlyStaffWages,
          value: report.staffWages.toCurrency(locale),
          color: cs.error,
        ),
        _StatCard(
          label: l10n.monthlyCreditSalesTotal,
          value: report.creditSalesTotal.toCurrency(locale),
        ),
        _StatCard(
          label: l10n.monthlyUncollectible,
          value: report.uncollectibleCredit.toCurrency(locale),
          color: cs.error,
        ),
        _StatCard(
          label: l10n.monthlyProfitLabel,
          value: report.profit.toCurrency(locale),
          color: report.profit >= 0 ? cs.primary : cs.error,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
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

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```powershell
git add lib/features/monthly_summary/presentation/widgets/summary_cards_section.dart
git commit -m "feat(monthly): SummaryCardsSection widget (8 stat kartı)"
```

---

## Task 9: MonthlySummaryScreen + router

**Files:**
- Create: `lib/features/monthly_summary/presentation/monthly_summary_screen.dart`
- Modify: `lib/app/router.dart`

- [ ] **Step 1: `monthly_summary_screen.dart` oluştur**

```dart
// lib/features/monthly_summary/presentation/monthly_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/l10n/generated/app_localizations.dart';
import '../application/monthly_providers.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/monthly_credit_table.dart';
import 'widgets/summary_cards_section.dart';

class MonthlySummaryScreen extends ConsumerWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final monthRange = ref.watch(currentMonthRangeProvider);
    final offset = ref.watch(monthOffsetProvider);
    final recordsAsync = ref.watch(monthlyRecordsProvider);
    final creditsAsync = ref.watch(monthlyCreditSalesProvider);
    final reportAsync = ref.watch(monthlyReportProvider);

    final monthLabel =
        intl.DateFormat('MMMM y', locale).format(monthRange.start);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.openMonthlySummary),
        actions: [
          IconButton(
            tooltip: l10n.prevMonth,
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                ref.read(monthOffsetProvider.notifier).previous(),
          ),
          IconButton(
            tooltip: l10n.nextMonth,
            icon: const Icon(Icons.chevron_right),
            onPressed: offset >= 0
                ? null
                : () => ref.read(monthOffsetProvider.notifier).next(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              monthLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Özet kartlar
            reportAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (report) => SummaryCardsSection(report: report),
            ),
            const SizedBox(height: 16),

            // Günlük ciro bar grafiği
            Text(
              l10n.monthlyRevenue,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            recordsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (records) => records.isEmpty
                  ? Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 24),
                        child: Text(l10n.noRecordsThisMonth),
                      ),
                    )
                  : MonthlyBarChart(
                      records: records, monthRange: monthRange),
            ),
            const SizedBox(height: 16),

            // Veresiye tablosu
            Text(
              l10n.monthlyCreditSalesTable,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            creditsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('$e'),
              data: (credits) =>
                  MonthlyCreditTable(credits: credits),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: `router.dart`'ta `/monthly` placeholder'ını değiştir**

`lib/app/router.dart` dosyasında iki değişiklik yap:

1. Import ekle (diğer feature import'larının yanına):
```dart
import '../features/monthly_summary/presentation/monthly_summary_screen.dart';
```

2. `/monthly` rotasını şu hale getir:
```dart
      GoRoute(
        path: '/monthly',
        builder: (context, state) => const MonthlySummaryScreen(),
      ),
```

Ve `_PlaceholderScreen` sınıfını router.dart'tan sil (artık kullanılmıyor).

- [ ] **Step 3: analyze**

```powershell
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Testleri çalıştır**

```powershell
flutter test
```

Expected: 107 civarı test yeşil.

- [ ] **Step 5: Commit**

```powershell
git add lib/features/monthly_summary/presentation/ lib/app/router.dart
git commit -m "feat(monthly): MonthlySummaryScreen + router /monthly"
```

---

## Task 10: Widget testleri + tam doğrulama + PROGRESS

**Files:**
- Create: `test/features/monthly_summary/monthly_summary_screen_test.dart`
- Modify: `PROGRESS.md`

- [ ] **Step 1: Widget test dosyasını oluştur**

```dart
// test/features/monthly_summary/monthly_summary_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/core/utils/date_utils.dart';
import 'package:gilanli_meyhane/features/credit_book/application/credit_book_providers.dart';
import 'package:gilanli_meyhane/features/credit_book/data/mock_credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/application/daily_record_providers.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record_calculator.dart';
import 'package:gilanli_meyhane/features/monthly_summary/presentation/monthly_summary_screen.dart';
import 'package:gilanli_meyhane/features/staff/application/staff_providers.dart';
import 'package:gilanli_meyhane/features/staff/data/mock_staff_repository.dart';

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

Widget _wrap({
  MockDailyRecordRepository? dailyRepo,
  MockCreditSaleRepository? creditRepo,
  MockStaffRepository? staffRepo,
}) {
  return ProviderScope(
    overrides: [
      dailyRecordRepositoryProvider
          .overrideWithValue(dailyRepo ?? MockDailyRecordRepository()),
      creditSaleRepositoryProvider
          .overrideWithValue(creditRepo ?? MockCreditSaleRepository()),
      staffRepositoryProvider
          .overrideWithValue(staffRepo ?? MockStaffRepository()),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('tr'),
      home: MonthlySummaryScreen(),
    ),
  );
}

void main() {
  testWidgets('AppBar başlığı ve navigasyon butonları görünür',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('Aylık Özet'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('Kayıt yoksa noRecordsThisMonth mesajı görünür',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Bu ay kayıt bulunmuyor.'), findsOneWidget);
  });

  testWidgets('Kayıt varsa noRecordsThisMonth mesajı görünmez',
      (tester) async {
    final repo = MockDailyRecordRepository();
    final now = DateTime.now();
    final rec = _rec(DateTime(now.year, now.month, 1), revenue: 500000);
    repo.store[rec.id] = rec;

    await tester.pumpWidget(_wrap(dailyRepo: repo));
    await tester.pumpAndSettle();

    expect(find.text('Bu ay kayıt bulunmuyor.'), findsNothing);
  });

  testWidgets('Veresiye yoksa noCreditSales mesajı görünür',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Henüz veresiye kaydı yok.'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Widget testleri çalıştır**

```powershell
flutter test test/features/monthly_summary/monthly_summary_screen_test.dart
```

Expected: `All tests passed! (4)`

- [ ] **Step 3: Tüm testleri çalıştır**

```powershell
flutter test
```

Expected: 116 civarı test (102 + 5 calculator + 5 providers + 4 widget), hepsi yeşil.

- [ ] **Step 4: analyze**

```powershell
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 5: PROGRESS.md güncelle**

`PROGRESS.md` içinde:
- `Faz 9 — Aylık Özet` satırını `[x]` yap
- `**Aktif faz:**` satırını `Faz 10 — Ayarlar / Bildirim / i18n` yap
- Faz 9 adımlarını ve kabul notunu ekle

```markdown
- [x] **Faz 9 — Aylık Özet** ✅ tamam (116 test, analyze temiz)
```

Günlük log satırı:
```
- **2026-06-03** — ✅ **Faz 9 KABUL**: MonthlyReport + TDD MonthlyReportCalculator (5 test, §3.5) + CreditSaleRepository.getByDateRange + monthly_providers (offset/range/records/credits/wages/report, 5 test) + MonthlyBarChart + MonthlyCreditTable + SummaryCardsSection (8 kart) + MonthlySummaryScreen + router /monthly güncellendi + l10n TR/EN (12 string). `flutter test` **116 yeşil**, `flutter analyze` **0 issue**.
```

Faz 9 adım listesi:
```markdown
## Faz 9 — Adımlar

- [x] T1: ARB TR/EN string'leri (12 yeni) + gen-l10n
- [x] T2: MonthlyReport data class
- [x] T3: TDD MonthlyReportCalculator (5 test, §3.5)
- [x] T4: CreditSaleRepository.getByDateRange (abstract + Firestore + Mock)
- [x] T5: monthly_providers (offset/range/records/credits/wages/report) + 5 provider testi
- [x] T6: MonthlyBarChart widget (fl_chart, günlük ciro)
- [x] T7: MonthlyCreditTable widget
- [x] T8: SummaryCardsSection widget (8 kart)
- [x] T9: MonthlySummaryScreen + router /monthly
- [x] T10: Widget testleri (4) + tam doğrulama + PROGRESS güncelleme
```

- [ ] **Step 6: Commit**

```powershell
git add test/features/monthly_summary/monthly_summary_screen_test.dart PROGRESS.md
git commit -m "test(monthly): MonthlySummaryScreen widget testleri (4) + PROGRESS Faz 9 tamamlandı"
```

---

## Kabul Kriterleri

- `flutter test` yeşil (116 civarı)
- `flutter analyze` 0 issue
- Özet kartlar §3.5 formülüyle birebir (kâr/zarar dahil)
- Patron masrafı ve kasa masrafı **ayrı** kartlarda gösteriliyor
- Bar grafik doğru ay günlerini gösteriyor
- Ay gezinme `<` `>` çalışıyor (bugünden ileriye gidilemez)
- Veresiye tablosu ay içindeki kayıtları gösteriyor
- TR/EN string hardcode yok
