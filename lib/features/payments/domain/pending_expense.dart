import 'package:equatable/equatable.dart';

enum ExpenseStatus {
  pending,
  partial,
  paid;

  static ExpenseStatus fromString(String v) =>
      ExpenseStatus.values.firstWhere((e) => e.name == v,
          orElse: () => ExpenseStatus.pending);
}

class ExpensePayment extends Equatable {
  final int amount; // kuruş
  final DateTime date;

  const ExpensePayment({required this.amount, required this.date});

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory ExpensePayment.fromMap(Map<String, dynamic> map) => ExpensePayment(
        amount: (map['amount'] as num).toInt(),
        date: DateTime.parse(map['date'] as String),
      );

  @override
  List<Object?> get props => [amount, date];
}

class PendingExpense extends Equatable {
  final String id;
  final String description;
  final int totalAmount; // kuruş
  final int remainingAmount; // kuruş
  final List<ExpensePayment> payments;
  final ExpenseStatus status;
  final DateTime date;

  const PendingExpense({
    required this.id,
    required this.description,
    required this.totalAmount,
    required this.remainingAmount,
    this.payments = const [],
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'type': 'expense',
        'description': description,
        'totalAmount': totalAmount,
        'remainingAmount': remainingAmount,
        'payments': payments.map((p) => p.toMap()).toList(),
        'status': status.name,
        'date': date.toIso8601String(),
      };

  factory PendingExpense.fromMap(String id, Map<String, dynamic> map) =>
      PendingExpense(
        id: id,
        description: map['description'] as String,
        totalAmount: (map['totalAmount'] as num).toInt(),
        remainingAmount: (map['remainingAmount'] as num).toInt(),
        payments: (map['payments'] as List<dynamic>? ?? [])
            .map((p) => ExpensePayment.fromMap(p as Map<String, dynamic>))
            .toList(),
        status: ExpenseStatus.fromString(map['status'] as String? ?? 'pending'),
        date: DateTime.parse(map['date'] as String),
      );

  PendingExpense copyWith({
    String? id,
    String? description,
    int? totalAmount,
    int? remainingAmount,
    List<ExpensePayment>? payments,
    ExpenseStatus? status,
    DateTime? date,
  }) =>
      PendingExpense(
        id: id ?? this.id,
        description: description ?? this.description,
        totalAmount: totalAmount ?? this.totalAmount,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        payments: payments ?? this.payments,
        status: status ?? this.status,
        date: date ?? this.date,
      );

  @override
  List<Object?> get props =>
      [id, description, totalAmount, remainingAmount, payments, status, date];
}
