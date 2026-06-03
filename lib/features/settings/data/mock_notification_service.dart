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
