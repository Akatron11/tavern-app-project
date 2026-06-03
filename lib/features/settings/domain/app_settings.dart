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
