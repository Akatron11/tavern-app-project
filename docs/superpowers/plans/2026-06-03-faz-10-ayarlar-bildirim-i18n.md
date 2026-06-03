# Faz 10 — Ayarlar / Bildirim / i18n Tamamlama — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Kemal'in dil (TR/EN, yeniden başlatmadan), günlük bildirim saati ve bildirim aç/kapa tercihlerini kalıcı (shared_preferences) olarak yönetebildiği bir Ayarlar ekranı + kullanıcı saatinde tekrarlayan yerel hatırlatma eklemek ve uygulamada kalan hardcoded string'leri temizlemek.

**Architecture:** Tercihler tek bir immutable `AppSettings` (equatable) nesnesinde toplanır; `SharedPreferences` ile kalıcılaşır (`sharedPreferencesProvider` main()'de override edilir). `SettingsNotifier` (NotifierProvider) durumu senkron tutar, setter'lar prefs'e yazar ve bildirim yan etkisini tetikler. Bildirim platform katmanı `NotificationService` abstract arayüzü arkasına alınır (`LocalNotificationService` gerçek impl, `MockNotificationService` test/dev) — böylece orkestrasyon TDD ile test edilir. `localeProvider`, `settingsProvider`'dan türetilir; `app.dart` bunu izleyerek dili anında uygular. Saf hesaplama (`nextInstanceOfTime`) ve model dönüşümleri TDD ile yazılır; Android platform konfigürasyonu (desugaring, manifest) açık adımlarla elle yapılır.

**Tech Stack:** Flutter · Riverpod 3 (NotifierProvider/Provider) · shared_preferences · flutter_local_notifications 21 + timezone + flutter_timezone · go_router · flutter gen-l10n (TR/EN) · equatable. Test: flutter_test, SharedPreferences.setMockInitialValues, ProviderContainer + inline overrides.

---

## Dosya / Klasör Yapısı

**Yeni dosyalar:**
- `lib/shared/providers/preferences_providers.dart` — `sharedPreferencesProvider` (main()'de override edilen, varsayılanı fırlatan Provider).
- `lib/features/settings/domain/app_settings.dart` — `AppSettings` immutable model + `fromPrefs` + `copyWith` (equatable).
- `lib/features/settings/domain/notification_schedule.dart` — `nextInstanceOfTime(...)` saf yardımcı.
- `lib/features/settings/data/notification_service.dart` — `NotificationService` abstract arayüz.
- `lib/features/settings/data/local_notification_service.dart` — `LocalNotificationService` (flutter_local_notifications sarmalayıcı).
- `lib/features/settings/data/mock_notification_service.dart` — `MockNotificationService` (çağrı sayan; test/dev).
- `lib/features/settings/application/settings_providers.dart` — `notificationServiceProvider`, `settingsProvider`/`SettingsNotifier`, `localeProvider`.
- `lib/features/settings/presentation/settings_screen.dart` — Ayarlar ekranı (dil, bildirim, çıkış).
- `test/features/settings/app_settings_test.dart`
- `test/features/settings/notification_schedule_test.dart`
- `test/features/settings/settings_providers_test.dart`
- `test/features/settings/settings_screen_test.dart`

**Değişen dosyalar:**
- `lib/core/l10n/app_tr.arb` + `lib/core/l10n/app_en.arb` — yeni string'ler (Task 1).
- `lib/main.dart` — prefs yükle + notification init + ProviderScope override'ları (Task 8).
- `lib/app/app.dart` — `locale: ref.watch(localeProvider)` + ConsumerStatefulWidget bootstrap (Task 8).
- `lib/app/router.dart` — `/settings` rotası (Task 9).
- `lib/features/dashboard/presentation/dashboard_screen.dart` — AppBar'daki çıkış ikonu yerine ayarlar ikonu; çıkış mantığı Ayarlar'a taşınır (Task 9).
- `android/app/build.gradle.kts` — core library desugaring (Task 7).
- `android/app/src/main/AndroidManifest.xml` — bildirim izinleri + boot receiver (Task 7).

**İç gruplama (sıra):** Task 1–6 saf Dart + TDD (cihaz gerektirmez). Task 7–8 platform & bootstrap kablolaması. Task 9 UI. Task 10 temizlik. Task 11 doğrulama + merge.

---

## Önemli Kararlar (bu fazda sabitlenen)

1. **Varsayılanlar:** `localeCode='tr'`, `notificationsEnabled=true`, `notificationHour=21`, `notificationMinute=0`. (Tek kullanıcılı uygulama; ARB/constant ile kolayca değişir.)
2. **Bildirim metni** ARB'de: başlık = `appTitle`, gövde = yeni `notificationBody`. Arka planda `lookupAppLocalizations(Locale(localeCode))` ile context'siz çözülür.
3. **Exact alarm yok:** `AndroidScheduleMode.inexactAllowWhileIdle` + `matchDateTimeComponents: DateTimeComponents.time` → `SCHEDULE_EXACT_ALARM` izni gerekmez; günlük tekrarlı.
4. **Çıkış (logout)** Ayarlar ekranına taşınır; Dashboard AppBar'a ayarlar (dişli) ikonu eklenir.
5. **`'Kemal'` özel adı** (greeting parametresi) hardcoded sayılmaz — kullanıcının kimliği, çevrilebilir UI metni değil; ARB'ye taşınmaz (Task 10'da belgelenir).
6. **SharedPreferences senkron erişim:** main()'de `getInstance()` ile yüklenir, `sharedPreferencesProvider.overrideWithValue(prefs)` ile sağlanır; `SettingsNotifier.build()` senkron okur.

---

## Task 1: ARB string'leri (TR/EN) + gen-l10n

**Files:**
- Modify: `lib/core/l10n/app_tr.arb`
- Modify: `lib/core/l10n/app_en.arb`

- [ ] **Step 1: TR ARB'ye yeni anahtarları ekle**

`lib/core/l10n/app_tr.arb` içinde son anahtar `monthlyCreditSalesTable` bloğundan sonra (kapanış `}` öncesi) virgül ekleyerek şunları ekle:

```json
  ,
  "notifications": "Bildirimler",
  "@notifications": { "description": "Ayarlar — bildirim bölümü başlığı" },
  "notificationsEnabled": "Günlük Hatırlatma",
  "@notificationsEnabled": { "description": "Ayarlar — günlük hatırlatma aç/kapa switch etiketi" },
  "notificationTime": "Hatırlatma Saati",
  "@notificationTime": { "description": "Ayarlar — hatırlatma saati seçici etiketi" },
  "notificationBody": "Bugünün kasa kaydını girmeyi unutmayın.",
  "@notificationBody": { "description": "Günlük hatırlatma bildirim gövdesi" },
  "languageSection": "Dil",
  "@languageSection": { "description": "Ayarlar — dil bölümü başlığı" },
  "turkish": "Türkçe",
  "@turkish": { "description": "Dil seçeneği — Türkçe" },
  "english": "İngilizce",
  "@english": { "description": "Dil seçeneği — İngilizce" },
  "openSettings": "Ayarlar",
  "@openSettings": { "description": "Dashboard — ayarlar ikonu tooltip" }
```

- [ ] **Step 2: EN ARB'ye karşılıklarını ekle**

`lib/core/l10n/app_en.arb` içinde son anahtar `monthlyCreditSalesTable` satırından sonra (kapanış `}` öncesi) virgül ekleyerek:

```json
  ,
  "notifications": "Notifications",
  "notificationsEnabled": "Daily Reminder",
  "notificationTime": "Reminder Time",
  "notificationBody": "Don't forget to enter today's cash record.",
  "languageSection": "Language",
  "turkish": "Turkish",
  "english": "English",
  "openSettings": "Settings"
```

- [ ] **Step 3: Kod üretimi**

Run: `flutter gen-l10n`
Expected: Hata yok; `lib/core/l10n/generated/app_localizations.dart` içinde `String get notificationBody;` vb. getter'lar oluşur.

- [ ] **Step 4: Analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/core/l10n/app_tr.arb lib/core/l10n/app_en.arb lib/core/l10n/generated
git commit -m "feat(settings): Faz 10 ARB string'leri (ayarlar/bildirim, TR/EN)"
```

---

## Task 2: `sharedPreferencesProvider`

**Files:**
- Create: `lib/shared/providers/preferences_providers.dart`

- [ ] **Step 1: Provider'ı yaz**

`lib/shared/providers/preferences_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// main() içinde gerçek instance ile override edilir.
/// (SharedPreferences.getInstance() async olduğu için uygulama başlarken
/// yüklenip override edilir; böylece tercihler senkron okunabilir.)
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPreferencesProvider main() içinde override edilmelidir',
  ),
);
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/shared/providers/preferences_providers.dart
git commit -m "feat(settings): sharedPreferencesProvider (main override)"
```

---

## Task 3: `AppSettings` modeli (TDD)

**Files:**
- Create: `lib/features/settings/domain/app_settings.dart`
- Test: `test/features/settings/app_settings_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/settings/app_settings_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/settings/domain/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppSettings.fromPrefs', () {
    test('boş prefs için varsayılanları döner', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final settings = AppSettings.fromPrefs(prefs);

      expect(settings.localeCode, 'tr');
      expect(settings.notificationsEnabled, true);
      expect(settings.notificationHour, 21);
      expect(settings.notificationMinute, 0);
    });

    test('kayıtlı değerleri okur', () async {
      SharedPreferences.setMockInitialValues({
        'settings.localeCode': 'en',
        'settings.notificationsEnabled': false,
        'settings.notificationHour': 8,
        'settings.notificationMinute': 30,
      });
      final prefs = await SharedPreferences.getInstance();

      final settings = AppSettings.fromPrefs(prefs);

      expect(settings.localeCode, 'en');
      expect(settings.notificationsEnabled, false);
      expect(settings.notificationHour, 8);
      expect(settings.notificationMinute, 30);
    });
  });

  group('AppSettings.copyWith', () {
    test('yalnızca verilen alanları değiştirir', () {
      const base = AppSettings();
      final updated = base.copyWith(localeCode: 'en', notificationHour: 9);

      expect(updated.localeCode, 'en');
      expect(updated.notificationHour, 9);
      expect(updated.notificationsEnabled, true); // değişmedi
      expect(updated.notificationMinute, 0); // değişmedi
      expect(base.localeCode, 'tr'); // orijinal bozulmadı
    });
  });
}
```

- [ ] **Step 2: Testi çalıştır, fail görmeli**

Run: `flutter test test/features/settings/app_settings_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'app_settings.dart'`.

- [ ] **Step 3: Modeli yaz**

`lib/features/settings/domain/app_settings.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcı tercihleri (dil + bildirim). SharedPreferences ile kalıcı.
class AppSettings extends Equatable {
  const AppSettings({
    this.localeCode = 'tr',
    this.notificationsEnabled = true,
    this.notificationHour = 21,
    this.notificationMinute = 0,
  });

  final String localeCode;
  final bool notificationsEnabled;
  final int notificationHour;
  final int notificationMinute;

  static const String keyLocale = 'settings.localeCode';
  static const String keyEnabled = 'settings.notificationsEnabled';
  static const String keyHour = 'settings.notificationHour';
  static const String keyMinute = 'settings.notificationMinute';

  factory AppSettings.fromPrefs(SharedPreferences prefs) {
    return AppSettings(
      localeCode: prefs.getString(keyLocale) ?? 'tr',
      notificationsEnabled: prefs.getBool(keyEnabled) ?? true,
      notificationHour: prefs.getInt(keyHour) ?? 21,
      notificationMinute: prefs.getInt(keyMinute) ?? 0,
    );
  }

  AppSettings copyWith({
    String? localeCode,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
  }) {
    return AppSettings(
      localeCode: localeCode ?? this.localeCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
    );
  }

  @override
  List<Object?> get props =>
      [localeCode, notificationsEnabled, notificationHour, notificationMinute];
}
```

- [ ] **Step 4: Testi çalıştır, pass görmeli**

Run: `flutter test test/features/settings/app_settings_test.dart`
Expected: PASS (3 test).

- [ ] **Step 5: Commit**

```bash
git add lib/features/settings/domain/app_settings.dart test/features/settings/app_settings_test.dart
git commit -m "feat(settings): AppSettings modeli + fromPrefs/copyWith (TDD, 3 test)"
```

---

## Task 4: `nextInstanceOfTime` saf yardımcı (TDD)

**Files:**
- Create: `lib/features/settings/domain/notification_schedule.dart`
- Test: `test/features/settings/notification_schedule_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/settings/notification_schedule_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/settings/domain/notification_schedule.dart';

void main() {
  group('nextInstanceOfTime', () {
    test('hedef saat bugün ileride ise bugünü döner', () {
      final now = DateTime(2026, 6, 3, 10, 0);
      final result = nextInstanceOfTime(hour: 21, minute: 0, now: now);
      expect(result, DateTime(2026, 6, 3, 21, 0));
    });

    test('hedef saat bugün geçmişte ise yarını döner', () {
      final now = DateTime(2026, 6, 3, 22, 0);
      final result = nextInstanceOfTime(hour: 21, minute: 0, now: now);
      expect(result, DateTime(2026, 6, 4, 21, 0));
    });

    test('hedef saat tam şu an ise yarını döner (geçmiş sayılır)', () {
      final now = DateTime(2026, 6, 3, 21, 0);
      final result = nextInstanceOfTime(hour: 21, minute: 0, now: now);
      expect(result, DateTime(2026, 6, 4, 21, 0));
    });
  });
}
```

- [ ] **Step 2: Testi çalıştır, fail görmeli**

Run: `flutter test test/features/settings/notification_schedule_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'notification_schedule.dart'`.

- [ ] **Step 3: Yardımcıyı yaz**

`lib/features/settings/domain/notification_schedule.dart`:

```dart
/// Verilen saat/dakika için bir sonraki tetiklenme anını döner.
/// Hedef bugün hâlâ ileride ise bugünü, aksi halde (geçmiş veya tam şu an)
/// yarını verir. Saf fonksiyon — timezone dönüşümü çağıran katmanda yapılır.
DateTime nextInstanceOfTime({
  required int hour,
  required int minute,
  required DateTime now,
}) {
  var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
  if (!scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}
```

- [ ] **Step 4: Testi çalıştır, pass görmeli**

Run: `flutter test test/features/settings/notification_schedule_test.dart`
Expected: PASS (3 test).

- [ ] **Step 5: Commit**

```bash
git add lib/features/settings/domain/notification_schedule.dart test/features/settings/notification_schedule_test.dart
git commit -m "feat(settings): nextInstanceOfTime saf yardımcı (TDD, 3 test)"
```

---

## Task 5: `NotificationService` (abstract + gerçek + mock)

**Files:**
- Create: `lib/features/settings/data/notification_service.dart`
- Create: `lib/features/settings/data/local_notification_service.dart`
- Create: `lib/features/settings/data/mock_notification_service.dart`

> Gerçek impl platform eklentisi olduğundan unit test edilmez; orkestrasyon Task 6'da `MockNotificationService` ile test edilir.

- [ ] **Step 1: Abstract arayüzü yaz**

`lib/features/settings/data/notification_service.dart`:

```dart
/// Yerel bildirim platform soyutlaması. UI/provider yalnızca buna bağımlıdır.
abstract class NotificationService {
  /// Eklentiyi başlatır (kanal/ikon ayarları). Uygulama açılışında 1 kez.
  Future<void> init();

  /// Çalışma zamanı bildirim iznini ister (Android 13+). İzin verildi mi döner.
  Future<bool> requestPermission();

  /// Her gün [hour]:[minute] saatinde tekrarlayan hatırlatmayı (yeniden) kurar.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  });

  /// Tüm zamanlanmış bildirimleri iptal eder.
  Future<void> cancelAll();
}
```

- [ ] **Step 2: Gerçek impl'i yaz**

`lib/features/settings/data/local_notification_service.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/notification_schedule.dart';
import 'notification_service.dart';

class LocalNotificationService implements NotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const int _reminderId = 1001;
  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Günlük Hatırlatma';
  static const String _channelDesc = 'Günlük kasa kaydı hatırlatması';

  @override
  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final when = nextInstanceOfTime(
      hour: hour,
      minute: minute,
      now: DateTime.now(),
    );
    final scheduled = tz.TZDateTime.from(when, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      _reminderId,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
```

- [ ] **Step 3: Mock impl'i yaz**

`lib/features/settings/data/mock_notification_service.dart`:

```dart
import 'notification_service.dart';

/// Çağrıları kaydeden bellek-içi bildirim servisi (test/dev).
class MockNotificationService implements NotificationService {
  int initCount = 0;
  int requestPermissionCount = 0;
  int scheduleCount = 0;
  int cancelCount = 0;

  bool permissionResult = true;
  int? lastHour;
  int? lastMinute;
  String? lastTitle;
  String? lastBody;

  @override
  Future<void> init() async {
    initCount++;
  }

  @override
  Future<bool> requestPermission() async {
    requestPermissionCount++;
    return permissionResult;
  }

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    scheduleCount++;
    lastHour = hour;
    lastMinute = minute;
    lastTitle = title;
    lastBody = body;
  }

  @override
  Future<void> cancelAll() async {
    cancelCount++;
  }
}
```

- [ ] **Step 4: Analyze**

Run: `flutter analyze`
Expected: `No issues found!` (kullanılmayan import/uyarı olmamalı).

- [ ] **Step 5: Commit**

```bash
git add lib/features/settings/data
git commit -m "feat(settings): NotificationService (abstract + Local impl + Mock)"
```

---

## Task 6: `settings_providers` — SettingsNotifier + localeProvider (TDD)

**Files:**
- Create: `lib/features/settings/application/settings_providers.dart`
- Test: `test/features/settings/settings_providers_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/settings/settings_providers_test.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/settings/application/settings_providers.dart';
import 'package:gilanli_meyhane/features/settings/data/mock_notification_service.dart';
import 'package:gilanli_meyhane/shared/providers/preferences_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _makeContainer(
  Map<String, Object> initialPrefs,
  MockNotificationService service,
) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
    notificationServiceProvider.overrideWithValue(service),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('başlangıç durumu prefs varsayılanları', () async {
    final service = MockNotificationService();
    final c = await _makeContainer({}, service);

    final settings = c.read(settingsProvider);
    expect(settings.localeCode, 'tr');
    expect(settings.notificationsEnabled, true);
    expect(c.read(localeProvider), const Locale('tr'));
  });

  test('setLocale state + localeProvider günceller ve EN gövdeyle yeniden kurar',
      () async {
    final service = MockNotificationService();
    final c = await _makeContainer({}, service);

    await c.read(settingsProvider.notifier).setLocale('en');

    expect(c.read(settingsProvider).localeCode, 'en');
    expect(c.read(localeProvider), const Locale('en'));
    // enabled=true varsayılan → yeniden kuruldu, gövde İngilizce
    expect(service.scheduleCount, greaterThanOrEqualTo(1));
    expect(service.lastBody, "Don't forget to enter today's cash record.");
  });

  test('setNotificationsEnabled(false) → cancelAll çağrılır', () async {
    final service = MockNotificationService();
    final c = await _makeContainer({}, service);

    await c.read(settingsProvider.notifier).setNotificationsEnabled(false);

    expect(c.read(settingsProvider).notificationsEnabled, false);
    expect(service.cancelCount, 1);
  });

  test('setNotificationsEnabled(true) → izin ister ve kurar', () async {
    final service = MockNotificationService();
    final c = await _makeContainer(
      {'settings.notificationsEnabled': false},
      service,
    );

    await c.read(settingsProvider.notifier).setNotificationsEnabled(true);

    expect(c.read(settingsProvider).notificationsEnabled, true);
    expect(service.requestPermissionCount, 1);
    expect(service.scheduleCount, greaterThanOrEqualTo(1));
  });

  test('setNotificationTime saat/dakikayı kaydeder ve yeniden kurar', () async {
    final service = MockNotificationService();
    final c = await _makeContainer({}, service);

    await c.read(settingsProvider.notifier).setNotificationTime(8, 30);

    final s = c.read(settingsProvider);
    expect(s.notificationHour, 8);
    expect(s.notificationMinute, 30);
    expect(service.lastHour, 8);
    expect(service.lastMinute, 30);
  });
}
```

- [ ] **Step 2: Testi çalıştır, fail görmeli**

Run: `flutter test test/features/settings/settings_providers_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'settings_providers.dart'`.

- [ ] **Step 3: Provider'ları yaz**

`lib/features/settings/application/settings_providers.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../shared/providers/preferences_providers.dart';
import '../data/local_notification_service.dart';
import '../data/notification_service.dart';
import '../domain/app_settings.dart';

/// Bildirim servisi — main()'de gerçek instance ile override edilir.
final notificationServiceProvider = Provider<NotificationService>((_) {
  return LocalNotificationService();
});

/// Kullanıcı tercihleri durumu.
final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings.fromPrefs(prefs);
  }

  Future<void> setLocale(String code) async {
    state = state.copyWith(localeCode: code);
    await ref.read(sharedPreferencesProvider).setString(
          AppSettings.keyLocale,
          code,
        );
    // Bildirim gövdesi dile bağlı → yeniden kur.
    await _applyNotifications();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await ref.read(sharedPreferencesProvider).setBool(
          AppSettings.keyEnabled,
          enabled,
        );
    if (enabled) {
      await ref.read(notificationServiceProvider).requestPermission();
    }
    await _applyNotifications();
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    state = state.copyWith(notificationHour: hour, notificationMinute: minute);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(AppSettings.keyHour, hour);
    await prefs.setInt(AppSettings.keyMinute, minute);
    await _applyNotifications();
  }

  /// Uygulama açılışında bir kez: izin iste (açıksa) + mevcut tercihi uygula.
  Future<void> bootstrapNotifications() async {
    if (state.notificationsEnabled) {
      await ref.read(notificationServiceProvider).requestPermission();
    }
    await _applyNotifications();
  }

  Future<void> _applyNotifications() async {
    final service = ref.read(notificationServiceProvider);
    if (state.notificationsEnabled) {
      final l10n = lookupAppLocalizations(Locale(state.localeCode));
      await service.scheduleDailyReminder(
        hour: state.notificationHour,
        minute: state.notificationMinute,
        title: l10n.appTitle,
        body: l10n.notificationBody,
      );
    } else {
      await service.cancelAll();
    }
  }
}

/// Aktif dil — `settingsProvider`'dan türetilir; app.dart bunu izler.
final localeProvider = Provider<Locale>((ref) {
  return Locale(ref.watch(settingsProvider).localeCode);
});
```

- [ ] **Step 4: Testi çalıştır, pass görmeli**

Run: `flutter test test/features/settings/settings_providers_test.dart`
Expected: PASS (5 test).

- [ ] **Step 5: Analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/settings/application/settings_providers.dart test/features/settings/settings_providers_test.dart
git commit -m "feat(settings): SettingsNotifier + localeProvider orkestrasyon (TDD, 5 test)"
```

---

## Task 7: Android platform konfigürasyonu (desugaring + manifest)

> Bu adım cihazda bildirimlerin derlenip çalışması için zorunlu. Unit test yok; doğrulama Task 11'deki `flutter build apk --debug` ile yapılır.

**Files:**
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: `compileOptions`'a core library desugaring ekle**

`android/app/build.gradle.kts` içindeki `compileOptions { ... }` bloğunu şu şekilde değiştir:

```kotlin
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
```

- [ ] **Step 2: `dependencies` bloğu ekle**

Aynı dosyada, en sondaki `flutter { source = "../.." }` bloğundan **sonra** şunu ekle:

```kotlin

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

> Gradle daha yüksek bir minimum sürüm isterse hatadaki sürüme yükselt.

- [ ] **Step 3: Manifest izinleri ekle**

`android/app/src/main/AndroidManifest.xml` içinde, açılış `<manifest ...>` satırından hemen sonra, `<application>`'dan **önce** ekle:

```xml
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
```

- [ ] **Step 4: Boot receiver ekle (yeniden başlatma sonrası tekrar kurulum)**

Aynı dosyada, `<application>` kapanış `</application>` etiketinden **hemen önce** ekle:

```xml
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
```

- [ ] **Step 5: Pub get (eklenti yerel kaydı senkron olsun)**

Run: `flutter pub get`
Expected: `Got dependencies!` (hata yok).

- [ ] **Step 6: Commit**

```bash
git add android/app/build.gradle.kts android/app/src/main/AndroidManifest.xml
git commit -m "build(android): bildirim için desugaring + manifest izinleri/boot receiver"
```

---

## Task 8: main.dart + app.dart kablolaması (prefs override, notif init/bootstrap, locale)

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/app/app.dart`

- [ ] **Step 1: `main.dart`'ı güncelle**

`lib/main.dart` tamamını şu içerikle değiştir:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app/app.dart';
import 'features/settings/application/settings_providers.dart';
import 'features/settings/data/local_notification_service.dart';
import 'firebase_options.dart';
import 'shared/providers/preferences_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  final prefs = await SharedPreferences.getInstance();
  final notificationService = LocalNotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const GilanliApp(),
    ),
  );
}
```

- [ ] **Step 2: `app.dart`'ı güncelle (locale izle + açılış bootstrap)**

`lib/app/app.dart` tamamını şu içerikle değiştir:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/application/settings_providers.dart';
import 'router.dart';

class GilanliApp extends ConsumerStatefulWidget {
  const GilanliApp({super.key});

  @override
  ConsumerState<GilanliApp> createState() => _GilanliAppState();
}

class _GilanliAppState extends ConsumerState<GilanliApp> {
  @override
  void initState() {
    super.initState();
    // İlk frame sonrası: izin iste (açıksa) + mevcut bildirim tercihini uygula.
    Future.microtask(
      () => ref.read(settingsProvider.notifier).bootstrapNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 3: Analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Mevcut test paketini çalıştır (regresyon yok)**

Run: `flutter test`
Expected: Tüm testler PASS (önceki 116 + Task 3/4/6'dan eklenen 11 = 127).

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart lib/app/app.dart
git commit -m "feat(settings): main/app kablolaması — prefs override, notif init, locale izleme"
```

---

## Task 9: SettingsScreen + router /settings + dashboard ayarlar ikonu

**Files:**
- Create: `lib/features/settings/presentation/settings_screen.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/features/dashboard/presentation/dashboard_screen.dart`
- Test: `test/features/settings/settings_screen_test.dart`

- [ ] **Step 1: SettingsScreen'i yaz**

`lib/features/settings/presentation/settings_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../auth/application/auth_providers.dart';
import '../application/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      ),
    );
    if (picked != null) {
      await ref
          .read(settingsProvider.notifier)
          .setNotificationTime(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final timeLabel = TimeOfDay(
      hour: settings.notificationHour,
      minute: settings.notificationMinute,
    ).format(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Dil ---
            Text(
              l10n.languageSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RadioListTile<String>(
              title: Text(l10n.turkish),
              value: 'tr',
              groupValue: settings.localeCode,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setLocale(v!),
            ),
            RadioListTile<String>(
              title: Text(l10n.english),
              value: 'en',
              groupValue: settings.localeCode,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setLocale(v!),
            ),
            const Divider(),

            // --- Bildirimler ---
            Text(
              l10n.notifications,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SwitchListTile(
              title: Text(l10n.notificationsEnabled),
              value: settings.notificationsEnabled,
              onChanged: (v) => ref
                  .read(settingsProvider.notifier)
                  .setNotificationsEnabled(v),
            ),
            ListTile(
              enabled: settings.notificationsEnabled,
              leading: const Icon(Icons.schedule),
              title: Text(l10n.notificationTime),
              trailing: Text(timeLabel),
              onTap: settings.notificationsEnabled
                  ? () => _pickTime(context, ref)
                  : null,
            ),
            const Divider(),

            // --- Çıkış ---
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.logout),
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Router'a `/settings` ekle**

`lib/app/router.dart` — import bloğuna ekle (mevcut feature import'larının yanına):

```dart
import '../features/settings/presentation/settings_screen.dart';
```

`routes: [ ... ]` listesinde `/monthly` GoRoute'undan sonra ekle:

```dart
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
```

- [ ] **Step 3: Dashboard AppBar'ı güncelle (çıkış ikonu → ayarlar ikonu)**

`lib/features/dashboard/presentation/dashboard_screen.dart`:

(a) `_confirmLogout` metodunu **sil** (çıkış artık Ayarlar'da).

(b) İmport'lara go_router zaten var; `auth_providers` import'u artık kullanılmıyorsa **kaldır** (analyze uyarısını önlemek için):

```dart
// SİL: import '../../auth/application/auth_providers.dart';
```

(c) AppBar `actions`'ı şu şekilde değiştir:

```dart
        actions: [
          IconButton(
            tooltip: l10n.openSettings,
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
```

> Not: `build` içindeki `WidgetRef ref` parametresi `TodaySummaryCard` ve diğer `ref.watch` kullanımları için hâlâ gereklidir; imzayı değiştirme.

- [ ] **Step 4: Widget testini yaz**

`test/features/settings/settings_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/settings/application/settings_providers.dart';
import 'package:gilanli_meyhane/features/settings/data/mock_notification_service.dart';
import 'package:gilanli_meyhane/features/settings/presentation/settings_screen.dart';
import 'package:gilanli_meyhane/shared/providers/preferences_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _wrap(MockNotificationService service) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      notificationServiceProvider.overrideWithValue(service),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('tr'),
      home: SettingsScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dil seçenekleri, bildirim switch ve çıkış görünür',
      (tester) async {
    await tester.pumpWidget(await _wrap(MockNotificationService()));
    await tester.pump();

    expect(find.text('Türkçe'), findsOneWidget);
    expect(find.text('İngilizce'), findsOneWidget);
    expect(find.text('Günlük Hatırlatma'), findsOneWidget);
    expect(find.text('Çıkış Yap'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
  });

  testWidgets('switch kapatınca cancelAll çağrılır', (tester) async {
    final service = MockNotificationService();
    await tester.pumpWidget(await _wrap(service));
    await tester.pump();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(service.cancelCount, 1);
  });
}
```

- [ ] **Step 5: Testi çalıştır, pass görmeli**

Run: `flutter test test/features/settings/settings_screen_test.dart`
Expected: PASS (2 test).

- [ ] **Step 6: Tüm testler + analyze**

Run: `flutter test`
Expected: Tüm testler PASS (129).
Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/features/settings/presentation/settings_screen.dart lib/app/router.dart lib/features/dashboard/presentation/dashboard_screen.dart test/features/settings/settings_screen_test.dart
git commit -m "feat(settings): SettingsScreen (dil/bildirim/çıkış) + /settings + dashboard ayarlar ikonu (2 widget test)"
```

---

## Task 10: Hardcoded string taraması

**Files:**
- (Tarama) `lib/**` ; bulguya göre düzeltme.

- [ ] **Step 1: Türkçe karakterli string literalleri tara**

Grep tool ile (generated ve arb hariç) Türkçe karakter içeren string literallerini ara:
- Pattern: `'[^']*[çğıöşüÇĞİÖŞÜ][^']*'`
- Path: `lib`
- Glob filtresi yok; sonuçlardan `lib/core/l10n/generated/` yollarını ele.

Run (alternatif, terminalden): `flutter analyze` çıktısı temiz olmalı; ek olarak yukarıdaki Grep ile manuel kontrol.

- [ ] **Step 2: Bulguları değerlendir**

Beklenen tek aday: `dashboard_screen.dart` içindeki `l10n.greeting('Kemal')`. **Karar:** `'Kemal'` kullanıcının özel adıdır (çevrilebilir UI metni değil) → ARB'ye taşınmaz, olduğu gibi kalır (Önemli Kararlar §5).

Başka bir hardcoded **UI** string'i (buton/etiket/başlık) bulunursa: ilgili anahtarı `app_tr.arb` + `app_en.arb`'ye ekle, `flutter gen-l10n` çalıştır, kullanım yerini `l10n.<key>` ile değiştir.

- [ ] **Step 3: Doğrula**

Run: `flutter analyze`
Expected: `No issues found!`
Run: `flutter test`
Expected: Tüm testler PASS.

- [ ] **Step 4: Commit (yalnızca değişiklik varsa)**

```bash
git add -A
git commit -m "chore(i18n): hardcoded string taraması — kalan UI string'leri ARB'ye taşındı"
```

> Düzeltilecek bir şey çıkmazsa bu task'ta commit atma; bir sonraki adıma geç.

---

## Task 11: Tam doğrulama + PROGRESS + merge

**Files:**
- Modify: `PROGRESS.md`

- [ ] **Step 1: Tam test paketi**

Run: `flutter test`
Expected: Tüm testler PASS (~129). Sayıyı not al.

- [ ] **Step 2: Analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Android derleme doğrulaması (bildirim platform config)**

Run: `flutter build apk --debug`
Expected: `Built build\app\outputs\flutter-apk\app-debug.apk` (BUILD SUCCESSFUL). Desugaring/manifest hatası yok.

> Hata `desugar_jdk_libs` sürümüyle ilgiliyse Task 7 Step 2'deki sürümü yükselt ve tekrar dene.

- [ ] **Step 4: PROGRESS.md güncelle**

`PROGRESS.md` içinde:
- "Aktif faz" satırını `Faz 11 — Sağlamlaştırma & Cila` yap.
- Faz Durumu listesinde `- [ ] Faz 10 ...` → `- [x] **Faz 10 — Ayarlar / Bildirim / i18n** ✅ tamam (~129 test, analyze temiz)`.
- "Kayıt / Notlar" altına yeni bir `**2026-06-03**` satırı ekle (özet: AppSettings + nextInstanceOfTime + NotificationService üçlüsü + SettingsNotifier/localeProvider + SettingsScreen + main/app kablolaması + Android desugaring/manifest + ARB taraması).
- Yeni bir `## Faz 10 — Adımlar` bölümü ekle (T1–T11 işaretli).

- [ ] **Step 5: Commit**

```bash
git add PROGRESS.md docs/superpowers/plans/2026-06-03-faz-10-ayarlar-bildirim-i18n.md
git commit -m "docs: Faz 10 tamamlandı — PROGRESS + plan"
```

- [ ] **Step 6: Branch'i main'e merge (executing-plans/finishing-a-development-branch akışına göre)**

`superpowers:finishing-a-development-branch` ile tamamla (FF merge `phase-10-settings` → `main`, dalı sil). Önceki fazların kalıbını izle.

---

## Self-Review (spec coverage)

Master plan §5 Faz 10 kabul kriterlerine karşı:

| Gereksinim | Karşılayan task |
|---|---|
| `settings_providers.dart`: localeProvider, notificationTimeProvider, enable toggle (shared_preferences kalıcı) | Task 2 (prefs provider), Task 3 (model+persist), Task 6 (settingsProvider/localeProvider + setNotificationTime/Enabled) |
| `settings_screen.dart`: dil seçimi (yeniden başlatmadan), bildirim saati picker, aç/kapa, çıkış | Task 9 (SettingsScreen + RadioListTile dil + showTimePicker + SwitchListTile + çıkış); anında uygulama Task 8 (app.dart localeProvider izler) |
| flutter_local_notifications + timezone: kullanıcı saatinde günlük tekrarlı hatırlatma | Task 4 (nextInstanceOfTime), Task 5 (zonedSchedule + matchDateTimeComponents.time), Task 7 (Android config), Task 8 (init + bootstrap) |
| ARB taraması: hardcoded string yok; EN paritesi | Task 1 (TR/EN paritesi), Task 10 (tarama) |
| **Kabul:** Dil anında değişiyor | Task 8 — MaterialApp.locale `ref.watch(localeProvider)`; settings değişince rebuild |
| **Kabul:** Bildirim kullanıcı saatinde geliyor | Task 5/7/8 — gerçek cihaz davranışı; orkestrasyon Task 6 testleriyle, derleme Task 11 Step 3 ile doğrulanır |
| **Kabul:** Hardcoded string yok | Task 10 |

**Placeholder taraması:** Tüm kod blokları tam; "TODO/TBD/benzeri" yok. Saf parçalar (AppSettings, nextInstanceOfTime, SettingsNotifier) TDD ile; platform parçaları (LocalNotificationService, Android config) test edilemez ama tam kodlu ve derleme ile doğrulanır.

**Tip tutarlılığı:** `AppSettings` alan adları (`localeCode`, `notificationsEnabled`, `notificationHour`, `notificationMinute`) ve pref anahtarları (`keyLocale/keyEnabled/keyHour/keyMinute`) tüm task'larda birebir aynı. `NotificationService` imzaları (`init/requestPermission/scheduleDailyReminder({hour,minute,title,body})/cancelAll`) gerçek + mock + çağıran tarafta tutarlı. `nextInstanceOfTime({hour,minute,now})` tanımı ve kullanımı eşleşiyor.
```