import 'package:equatable/equatable.dart';

/// Bir ay için hesaplanmış özet rapor. Tüm tutarlar int kuruş.
class MonthlyReport extends Equatable {
  const MonthlyReport({
    required this.revenue,
    required this.creditCard,
    required this.cashExpenses,
    required this.ownerExpenses,
    required this.staffWages,
    required this.creditSalesTotal,
    required this.uncollectibleCredit,
    required this.profit,
  });

  final int revenue;
  final int creditCard;
  final int cashExpenses;
  final int ownerExpenses;
  final int staffWages;
  final int creditSalesTotal;
  final int uncollectibleCredit;
  final int profit;

  @override
  List<Object?> get props => [
        revenue,
        creditCard,
        cashExpenses,
        ownerExpenses,
        staffWages,
        creditSalesTotal,
        uncollectibleCredit,
        profit,
      ];
}
