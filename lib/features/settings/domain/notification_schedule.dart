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
