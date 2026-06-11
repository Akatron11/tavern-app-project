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
    await _plugin.initialize(settings: settings);
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
    bool skipToday = false,
  }) async {
    final now = DateTime.now();
    var when = nextInstanceOfTime(hour: hour, minute: minute, now: now);
    // BUG-16: bugün kayıt girildiyse ilk tetiği yarına ötele.
    if (skipToday &&
        when.year == now.year &&
        when.month == now.month &&
        when.day == now.day) {
      when = when.add(const Duration(days: 1));
    }
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
      id: _reminderId,
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
