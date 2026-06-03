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
