import 'package:equatable/equatable.dart';

class TipDistribution extends Equatable {
  final String id;
  final DateTime date;
  final int amount;
  final DateTime periodStart;
  final DateTime periodEnd;

  const TipDistribution({
    required this.id,
    required this.date,
    required this.amount,
    required this.periodStart,
    required this.periodEnd,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
      };

  factory TipDistribution.fromMap(String id, Map<String, dynamic> map) =>
      TipDistribution(
        id: id,
        date: DateTime.parse(map['date'] as String),
        amount: (map['amount'] as num).toInt(),
        periodStart: DateTime.parse(map['periodStart'] as String),
        periodEnd: DateTime.parse(map['periodEnd'] as String),
      );

  TipDistribution copyWith({
    String? id,
    DateTime? date,
    int? amount,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) =>
      TipDistribution(
        id: id ?? this.id,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        periodStart: periodStart ?? this.periodStart,
        periodEnd: periodEnd ?? this.periodEnd,
      );

  @override
  List<Object?> get props => [id, date, amount, periodStart, periodEnd];
}
