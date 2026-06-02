/// Günlük kasa hesaplamaları (saf fonksiyonlar, unit-test edilebilir).
///
/// Tüm tutarlar **int kuruş**. Formüller patron tarafından onaylanmıştır
/// (master plan §3.1):
///
/// - `dailyCash = ciro − kredi kartı + bahşiş − kasa masrafı − veresiye`
///   (**patron masrafı günlük kasayı etkilemez**)
/// - `totalCash = dünden kalan + günlük kasa`
class DailyRecordCalculator {
  const DailyRecordCalculator._();

  /// Günlük kasa. Patron masrafı (`ownerExpenses`) bilinçli olarak yoktur;
  /// yalnızca [cashExpenses] düşülür.
  static int dailyCash({
    required int revenue,
    required int creditCard,
    required int tips,
    required int cashExpenses,
    required int creditSales,
  }) =>
      revenue - creditCard + tips - cashExpenses - creditSales;

  /// Toplam kasa = dünden kalan kasa + günlük kasa.
  static int totalCash(int previousDayCash, int dailyCash) =>
      previousDayCash + dailyCash;

  /// Yalnızca gösterim için toplam masraf (kasa + patron). `dailyCash`'i
  /// ETKİLEMEZ; iki kalem UI'da ayrı gösterilir.
  static int totalExpensesDisplay(int ownerExpenses, int cashExpenses) =>
      ownerExpenses + cashExpenses;
}
