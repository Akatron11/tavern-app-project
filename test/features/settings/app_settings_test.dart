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
