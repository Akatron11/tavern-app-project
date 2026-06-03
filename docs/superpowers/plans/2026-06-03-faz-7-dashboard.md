# Faz 7 — Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `PlaceholderHomeScreen`'i gerçek bir Dashboard ekranıyla değiştirmek — tarih + selamlama, bugünün kısa özeti (günlük kasa + çalışan sayısı), tüm özelliklere hızlı erişim kartları.

**Architecture:** `dashboard_providers.dart` bugünün kaydını `DailyRecordRepository.getByDay` ile çeker. `TodaySummaryCard` widget bu provider'ı izler ve AsyncValue durumlarını işler. `DashboardScreen` selamlama, özet kart ve navigasyon kartlarını birleştirir. `PlaceholderHomeScreen` silinir, router'daki `/` rotası `DashboardScreen`'e bağlanır. `/weekly` ve `/monthly` rotaları bu fazda placeholder ekranla eklenir (Faz 8/9'da değiştirilecek).

**Tech Stack:** Flutter · Riverpod (FutureProvider) · GoRouter · flutter_localizations · intl (DateFormat) · mocktail · fake_cloud_firestore

---

## Dosya Yapısı

```
Oluşturulacak:
  lib/features/dashboard/application/dashboard_providers.dart
  lib/features/dashboard/presentation/dashboard_screen.dart
  lib/features/dashboard/presentation/widgets/today_summary_card.dart
  test/features/dashboard/dashboard_screen_test.dart

Değiştirilecek:
  lib/app/router.dart           — `/` → DashboardScreen; /weekly + /monthly placeholder eklenir
  lib/main.dart                 — initializeDateFormatting() eklenir
  lib/core/l10n/app_tr.arb
  lib/core/l10n/app_en.arb

Silinecek:
  lib/app/placeholder_home_screen.dart
```

---

## Task 1: Branch + l10n Stringleri

**Files:**
- Modify: `lib/core/l10n/app_tr.arb`
- Modify: `lib/core/l10n/app_en.arb`

- [ ] **Step 1.1: Branch aç**

```powershell
git checkout -b phase-7-dashboard
```

- [ ] **Step 1.2: `app_tr.arb`'nin sonuna yeni stringleri ekle**

`}` kapama parantezinden hemen önce, `"expenseStatusPaid": "Ödendi"` satırının arkasına virgül koy ve şu stringleri ekle:

```json
  "expenseStatusPaid": "Ödendi",

  "todaySummary": "Bugünün Özeti",
  "@todaySummary": { "description": "Bugünün özet kart başlığı" },
  "noRecordToday": "Bugün kayıt girilmemiş.",
  "@noRecordToday": { "description": "Bugün kayıt yoksa gösterilen metin" },
  "workingStaffCountLabel": "Çalışan Personel",
  "@workingStaffCountLabel": { "description": "Dashboard özet — çalışan personel sayısı etiketi" },
  "openWeeklySummary": "Haftalık Özet",
  "@openWeeklySummary": { "description": "Dashboard hızlı erişim — haftalık özet kartı" },
  "openMonthlySummary": "Aylık Özet",
  "@openMonthlySummary": { "description": "Dashboard hızlı erişim — aylık özet kartı" }
}
```

- [ ] **Step 1.3: `app_en.arb`'nin sonuna yeni stringleri ekle**

`}` kapama parantezinden hemen önce, `"expenseStatusPaid": "Paid"` satırının arkasına virgül koy ve şu stringleri ekle:

```json
  "expenseStatusPaid": "Paid",

  "todaySummary": "Today's Summary",
  "noRecordToday": "No record entered for today.",
  "workingStaffCountLabel": "Working Staff",
  "openWeeklySummary": "Weekly Summary",
  "openMonthlySummary": "Monthly Summary"
}
```

- [ ] **Step 1.4: Kod üret ve doğrula**

```powershell
flutter gen-l10n
```

Beklenen: hata yok. `lib/core/l10n/generated/app_localizations_tr.dart` ve `app_localizations_en.dart` dosyalarında yeni getter'lar görünmeli.

- [ ] **Step 1.5: Commit**

```powershell
git add lib/core/l10n/app_tr.arb lib/core/l10n/app_en.arb lib/core/l10n/generated/
git commit -m "feat(dashboard): l10n TR/EN stringleri (todaySummary, noRecordToday, weekly/monthly)"
```

---

## Task 2: `dashboard_providers.dart`

**Files:**
- Create: `lib/features/dashboard/application/dashboard_providers.dart`

- [ ] **Step 2.1: Dosyayı oluştur**

```dart
// lib/features/dashboard/application/dashboard_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../daily_record/application/daily_record_providers.dart';
import '../../daily_record/domain/daily_record.dart';

/// Bugünün günlük kaydını çeker; yoksa `null` döner.
final todayRecordProvider = FutureProvider<DailyRecord?>((ref) {
  final repo = ref.watch(dailyRecordRepositoryProvider);
  return repo.getByDay(dayKey(DateTime.now()));
});
```

- [ ] **Step 2.2: `flutter analyze` çalıştır**

```powershell
flutter analyze
```

Beklenen: 0 issue.

- [ ] **Step 2.3: Commit**

```powershell
git add lib/features/dashboard/
git commit -m "feat(dashboard): todayRecordProvider (bugünün kaydını çeker)"
```

---

## Task 3: `TodaySummaryCard` Widget + Testi

**Files:**
- Create: `lib/features/dashboard/presentation/widgets/today_summary_card.dart`
- Create: `test/features/dashboard/dashboard_screen_test.dart`

- [ ] **Step 3.1: Önce testi yaz (kırmızı)**

```dart
// test/features/dashboard/dashboard_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/dashboard/application/dashboard_providers.dart';
import 'package:gilanli_meyhane/features/dashboard/presentation/widgets/today_summary_card.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';

Widget _wrapCard(Widget child, {required Override override}) {
  return ProviderScope(
    overrides: [override],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('tr'),
      home: Scaffold(body: child),
    ),
  );
}

DailyRecord _fakeRecord() => const DailyRecord(
      id: '2026-06-03',
      date: null, // DateTime kullanmak için aşağıya bak
      revenue: 1000000,
      creditCard: 300000,
      tips: 50000,
      ownerExpenses: 20000,
      cashExpenses: 30000,
      creditSales: 0,
      previousDayCash: 0,
      dailyCash: 720000,
      totalCash: 720000,
    );

void main() {
  group('TodaySummaryCard', () {
    test('placeholder — bu test dosyası Task 3\'te doldurulacak', () {
      expect(1, 1);
    });
  });
}
```

> **Not:** Yukarıdaki `_fakeRecord` null `date` içeriyor — gerçek testi aşağıda düzelt.

- [ ] **Step 3.2: Gerçek test içeriğini yaz (testi sil, düzeltilmişiyle değiştir)**

Dosyanın tamamını şununla değiştir:

```dart
// test/features/dashboard/dashboard_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/dashboard/application/dashboard_providers.dart';
import 'package:gilanli_meyhane/features/dashboard/presentation/widgets/today_summary_card.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';

Widget _wrapCard({required Override override}) {
  return ProviderScope(
    overrides: [override],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('tr'),
      home: Scaffold(body: TodaySummaryCard()),
    ),
  );
}

final _record = DailyRecord(
  id: '2026-06-03',
  date: DateTime(2026, 6, 3),
  revenue: 1000000,
  creditCard: 300000,
  tips: 50000,
  ownerExpenses: 20000,
  cashExpenses: 30000,
  creditSales: 0,
  previousDayCash: 0,
  dailyCash: 720000,
  totalCash: 720000,
  workingStaffIds: const ['s1', 's2', 's3'],
);

void main() {
  group('TodaySummaryCard —', () {
    testWidgets('kayıt yoksa noRecordToday mesajı gösterilir', (tester) async {
      await tester.pumpWidget(
        _wrapCard(
          override: todayRecordProvider.overrideWith((_) async => null),
        ),
      );
      await tester.pump(); // FutureProvider settle
      expect(find.text('Bugün kayıt girilmemiş.'), findsOneWidget);
    });

    testWidgets('kayıt varsa dailyCash ve çalışan sayısı gösterilir',
        (tester) async {
      await tester.pumpWidget(
        _wrapCard(
          override: todayRecordProvider.overrideWith((_) async => _record),
        ),
      );
      await tester.pump();
      // Günlük Kasa etiketi
      expect(find.text('Günlük Kasa'), findsOneWidget);
      // Çalışan Personel etiketi
      expect(find.text('Çalışan Personel'), findsOneWidget);
      // 3 çalışan
      expect(find.text('3'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 3.3: Testi çalıştır — KIRMIZI bekleniyor**

```powershell
flutter test test/features/dashboard/dashboard_screen_test.dart
```

Beklenen: derleme hatası (`TodaySummaryCard` henüz yok).

- [ ] **Step 3.4: `TodaySummaryCard`'ı oluştur**

```dart
// lib/features/dashboard/presentation/widgets/today_summary_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../application/dashboard_providers.dart';

class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final async = ref.watch(todayRecordProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
          data: (record) {
            if (record == null) {
              return Text(
                l10n.noRecordToday,
                style: Theme.of(context).textTheme.bodyMedium,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.todaySummary,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.dailyCash),
                    Text(record.dailyCash.toCurrency(locale)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.workingStaffCountLabel),
                    Text('${record.workingStaffIds.length}'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 3.5: Testi çalıştır — YEŞİL bekleniyor**

```powershell
flutter test test/features/dashboard/dashboard_screen_test.dart
```

Beklenen: 2 test geçti.

- [ ] **Step 3.6: Commit**

```powershell
git add lib/features/dashboard/ test/features/dashboard/
git commit -m "feat(dashboard): TodaySummaryCard + 2 widget testi"
```

---

## Task 4: `DashboardScreen` + Router Güncellemesi

**Files:**
- Create: `lib/features/dashboard/presentation/dashboard_screen.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/main.dart`
- Delete: `lib/app/placeholder_home_screen.dart`

- [ ] **Step 4.1: `main.dart`'a `initializeDateFormatting` ekle**

`main.dart` içindeki `main()` fonksiyonunun en başına (Firebase.initializeApp'tan önce) ekle:

```dart
import 'package:intl/date_symbol_data_local.dart';
```

ve `WidgetsFlutterBinding.ensureInitialized();` satırından hemen sonra:

```dart
await initializeDateFormatting();
```

Tam `main()` fonksiyonu şöyle görünmeli:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  runApp(const ProviderScope(child: GilanliApp()));
}
```

- [ ] **Step 4.2: `DashboardScreen`'i oluştur**

```dart
// lib/features/dashboard/presentation/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/l10n/generated/app_localizations.dart';
import '../../auth/application/auth_providers.dart';
import 'widgets/today_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(logoutControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateStr =
        intl.DateFormat('d MMMM y, EEEE', locale).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(dateStr,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              l10n.greeting('Kemal'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const TodaySummaryCard(),
            const SizedBox(height: 16),
            _NavCard(
              icon: Icons.receipt_long,
              label: l10n.openDailyRecord,
              route: '/daily',
            ),
            _NavCard(
              icon: Icons.bar_chart,
              label: l10n.openWeeklySummary,
              route: '/weekly',
            ),
            _NavCard(
              icon: Icons.calendar_month,
              label: l10n.openMonthlySummary,
              route: '/monthly',
            ),
            _NavCard(
              icon: Icons.people,
              label: l10n.openStaff,
              route: '/staff',
            ),
            _NavCard(
              icon: Icons.menu_book_outlined,
              label: l10n.openCreditBook,
              route: '/credit',
            ),
            _NavCard(
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.openPayments,
              route: '/payments',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
```

- [ ] **Step 4.3: `router.dart`'ı güncelle**

`router.dart`'ta:
1. `import 'placeholder_home_screen.dart';` satırını kaldır
2. `import '../features/dashboard/presentation/dashboard_screen.dart';` ekle
3. `/` rotasında `PlaceholderHomeScreen()` → `DashboardScreen()` değiştir
4. `/payments/expense/edit` rotasının altına iki yeni rota ekle:

```dart
GoRoute(
  path: '/weekly',
  builder: (context, state) => const _PlaceholderScreen(title: 'Haftalık Özet'),
),
GoRoute(
  path: '/monthly',
  builder: (context, state) => const _PlaceholderScreen(title: 'Aylık Özet'),
),
```

5. Dosyanın en sonuna (`routerProvider`'ın dışında) şu private widget'ı ekle:

```dart
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Yakında...')),
    );
  }
}
```

Tam güncellenmiş `router.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/credit_book/domain/credit_sale.dart';
import '../features/credit_book/presentation/credit_form.dart';
import '../features/credit_book/presentation/credit_list_screen.dart';
import '../features/daily_record/presentation/daily_record_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/payments/domain/pending_expense.dart';
import '../features/payments/presentation/expense_form_screen.dart';
import '../features/payments/presentation/payments_screen.dart';
import '../features/staff/presentation/staff_list_screen.dart';

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
        builder: (context, state) => const DashboardScreen(),
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
      GoRoute(
        path: '/weekly',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Haftalık Özet'),
      ),
      GoRoute(
        path: '/monthly',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Aylık Özet'),
      ),
    ],
  );

  ref.listen(authStateChangesProvider, (prev, next) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
});

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Yakında...')),
    );
  }
}
```

- [ ] **Step 4.4: `placeholder_home_screen.dart`'ı sil**

```powershell
Remove-Item lib\app\placeholder_home_screen.dart
```

- [ ] **Step 4.5: `flutter analyze` çalıştır**

```powershell
flutter analyze
```

Beklenen: 0 issue.

- [ ] **Step 4.6: Tüm testleri çalıştır**

```powershell
flutter test
```

Beklenen: tüm testler yeşil (89+ test).

- [ ] **Step 4.7: Commit**

```powershell
git add lib/app/router.dart lib/app/ lib/features/dashboard/ lib/main.dart
git commit -m "feat(dashboard): DashboardScreen + router / → Dashboard + /weekly /monthly placeholder"
```

---

## Task 5: DashboardScreen Widget Testi (Navigasyon Kartları)

**Files:**
- Modify: `test/features/dashboard/dashboard_screen_test.dart`

- [ ] **Step 5.1: DashboardScreen navigasyon testi ekle**

`dashboard_screen_test.dart` dosyasının sonuna (mevcut `main()` bloğunun içine, son `});`'dan önce) şu `group`'u ekle:

```dart
  group('DashboardScreen —', () {
    testWidgets('selamlama ve navigasyon kartları görünür', (tester) async {
      // DashboardScreen tam router gerektirdiğinden basit bir ProviderScope
      // ile render alıyoruz; sadece greeting + kart etiketlerini kontrol et.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayRecordProvider.overrideWith((_) async => null),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Merhabalar Kemal Bey'), findsOneWidget);
      expect(find.text('Günlük Kayıt'), findsOneWidget);
      expect(find.text('Haftalık Özet'), findsOneWidget);
      expect(find.text('Aylık Özet'), findsOneWidget);
      expect(find.text('Personel'), findsOneWidget);
      expect(find.text('Veresiye Defteri'), findsOneWidget);
      expect(find.text('Ödemeler'), findsOneWidget);
    });
  });
```

Aynı zamanda dosyanın import listesine şunu ekle:

```dart
import 'package:gilanli_meyhane/features/dashboard/presentation/dashboard_screen.dart';
```

- [ ] **Step 5.2: Testi çalıştır — YEŞİL bekleniyor**

```powershell
flutter test test/features/dashboard/dashboard_screen_test.dart
```

Beklenen: 3 test geçti.

- [ ] **Step 5.3: Tüm testler**

```powershell
flutter test
```

Beklenen: tüm testler yeşil (92 test — 89 + 3 yeni).

- [ ] **Step 5.4: Commit**

```powershell
git add test/features/dashboard/
git commit -m "test(dashboard): DashboardScreen navigasyon widget testi (3 test)"
```

---

## Task 6: PROGRESS.md Güncelleme + Kabul Doğrulaması

**Files:**
- Modify: `PROGRESS.md`

- [ ] **Step 6.1: Son test + analyze**

```powershell
flutter test
flutter analyze
```

Beklenen: tüm testler yeşil, 0 issue.

- [ ] **Step 6.2: PROGRESS.md güncelle**

`PROGRESS.md`'de:
1. `Aktif faz:` → `Faz 8 — Haftalık Özet`
2. `Branch:` → `phase-7-dashboard (main'e merge bekliyor)`
3. `- [ ] Faz 7 — Dashboard` → `- [x] **Faz 7 — Dashboard** ✅ tamam (92 test, analyze temiz)`
4. Kayıt/Notlar'a satır ekle (tarih: 2026-06-03).
5. "Faz 7 — Adımlar" bölümü ekle (T1–T6 tamam).

- [ ] **Step 6.3: Commit**

```powershell
git add PROGRESS.md
git commit -m "docs(progress): Faz 7 tamam - dashboard (92 test, analyze temiz)"
```

- [ ] **Step 6.4: `phase-7-dashboard` → `main` (FF merge)**

```powershell
git checkout main
git merge --ff-only phase-7-dashboard
git branch -d phase-7-dashboard
```

---

## Kabul Kriterleri Kontrol Listesi

- [ ] `DashboardScreen` `/` rotasında açılıyor
- [ ] Tarih + "Merhabalar Kemal Bey" görünüyor
- [ ] Bugün kayıt yoksa `TodaySummaryCard` → "Bugün kayıt girilmemiş."
- [ ] Bugün kayıt varsa → Günlük Kasa + Çalışan Personel sayısı
- [ ] 6 navigasyon kartı var: Günlük Kayıt, Haftalık Özet, Aylık Özet, Personel, Veresiye Defteri, Ödemeler
- [ ] `/weekly` ve `/monthly` rotaları çalışıyor (placeholder ekran)
- [ ] `flutter test` → tüm testler yeşil (92)
- [ ] `flutter analyze` → 0 issue
- [ ] `PlaceholderHomeScreen` silindi
