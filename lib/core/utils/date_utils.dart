/// Tarih yardımcıları (haftalık/aylık özet ve günlük kayıt anahtarlama için).
///
/// Aralıklar **[start dahil, end hariç)** yarı-açık biçimdedir; sorgularda
/// `date >= start && date < end` kullanılır.

/// Bir tarih aralığı: [start] dahil, [end] hariç.
typedef DateRange = ({DateTime start, DateTime end});

/// İki tarihin (saat yok sayılarak) aynı güne ait olup olmadığını döner.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Tarihi `yyyy-MM-dd` biçiminde, sıfır dolgulu döndürür (gruplama/anahtarlama).
String dayKey(DateTime d) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}

/// Verilen tarihin ait olduğu haftanın aralığı (Pazartesi 00:00 → gelecek
/// Pazartesi 00:00, bitiş hariç).
DateRange weekRange(DateTime d) {
  // weekday: Pazartesi=1 ... Pazar=7
  final monday = DateTime(d.year, d.month, d.day - (d.weekday - 1));
  final nextMonday = DateTime(monday.year, monday.month, monday.day + 7);
  return (start: monday, end: nextMonday);
}

/// Verilen tarihin ait olduğu ayın aralığı (ayın 1'i 00:00 → gelecek ayın 1'i
/// 00:00, bitiş hariç).
DateRange monthRange(DateTime d) {
  final start = DateTime(d.year, d.month, 1);
  final end = DateTime(d.year, d.month + 1, 1);
  return (start: start, end: end);
}
