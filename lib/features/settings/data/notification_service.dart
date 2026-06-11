/// Yerel bildirim platform soyutlaması. UI/provider yalnızca buna bağımlıdır.
abstract class NotificationService {
  /// Eklentiyi başlatır (kanal/ikon ayarları). Uygulama açılışında 1 kez.
  Future<void> init();

  /// Çalışma zamanı bildirim iznini ister (Android 13+). İzin verildi mi döner.
  Future<bool> requestPermission();

  /// Her gün [hour]:[minute] saatinde tekrarlayan hatırlatmayı (yeniden) kurar.
  /// [skipToday] true ise ilk tetik bugünü atlar (yarından başlar) — BUG-16:
  /// o gün kayıt zaten girildiyse bugünkü hatırlatma gösterilmez.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
    bool skipToday,
  });

  /// Tüm zamanlanmış bildirimleri iptal eder.
  Future<void> cancelAll();
}
