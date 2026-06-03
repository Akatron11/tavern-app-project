/// Aylık Kâr/Zarar hesaplama servisi. §3.5 formülü.
/// Tüm parametreler int kuruş. Bahşiş dahil DEĞİL.
class MonthlyReportCalculator {
  MonthlyReportCalculator._();

  static int monthlyProfit({
    required int revenue,
    required int creditCard,
    required int cashExpenses,
    required int ownerExpenses,
    required int staffWages,
    required int uncollectibleCredit,
  }) =>
      revenue -
      creditCard -
      (cashExpenses + ownerExpenses) -
      staffWages -
      uncollectibleCredit;
}
