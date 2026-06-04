/// Aylık Kâr/Zarar hesaplama servisi. §3.5 formülü.
/// Tüm parametreler int kuruş. Bahşiş ve **kredi kartı** dahil DEĞİL
/// (kredi kartı zaten ciroya dahildir; kârdan ayrıca düşülmez — BUG-09).
class MonthlyReportCalculator {
  MonthlyReportCalculator._();

  static int monthlyProfit({
    required int revenue,
    required int cashExpenses,
    required int ownerExpenses,
    required int staffWages,
    required int uncollectibleCredit,
  }) =>
      revenue -
      (cashExpenses + ownerExpenses) -
      staffWages -
      uncollectibleCredit;
}
