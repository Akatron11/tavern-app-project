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
