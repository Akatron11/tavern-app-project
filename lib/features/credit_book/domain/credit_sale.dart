import 'package:equatable/equatable.dart';

enum CreditStatus {
  pending,
  partial,
  paid;

  static CreditStatus fromString(String value) =>
      CreditStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => CreditStatus.pending,
      );
}

class CreditPayment extends Equatable {
  final int amount; // kuruş
  final DateTime date;

  const CreditPayment({required this.amount, required this.date});

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory CreditPayment.fromMap(Map<String, dynamic> map) => CreditPayment(
        amount: (map['amount'] as num).toInt(),
        date: DateTime.parse(map['date'] as String),
      );

  @override
  List<Object?> get props => [amount, date];
}

class CreditSale extends Equatable {
  final String id;
  final String customerName;
  final int totalAmount; // kuruş
  final int remainingAmount; // kuruş
  final DateTime date;
  final CreditStatus status;
  final List<CreditPayment> payments;
  final String? linkedDailyRecordId;

  const CreditSale({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.remainingAmount,
    required this.date,
    required this.status,
    this.payments = const [],
    this.linkedDailyRecordId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'customerName': customerName,
        'totalAmount': totalAmount,
        'remainingAmount': remainingAmount,
        'date': date.toIso8601String(),
        'status': status.name,
        'payments': payments.map((p) => p.toMap()).toList(),
        'linkedDailyRecordId': linkedDailyRecordId,
      };

  factory CreditSale.fromMap(String id, Map<String, dynamic> map) => CreditSale(
        id: id,
        customerName: map['customerName'] as String,
        totalAmount: (map['totalAmount'] as num).toInt(),
        remainingAmount: (map['remainingAmount'] as num).toInt(),
        date: DateTime.parse(map['date'] as String),
        status: CreditStatus.fromString(map['status'] as String),
        payments: (map['payments'] as List<dynamic>?)
                ?.map((e) => CreditPayment.fromMap(e as Map<String, dynamic>))
                .toList() ??
            const [],
        linkedDailyRecordId: map['linkedDailyRecordId'] as String?,
      );

  CreditSale copyWith({
    String? id,
    String? customerName,
    int? totalAmount,
    int? remainingAmount,
    DateTime? date,
    CreditStatus? status,
    List<CreditPayment>? payments,
    String? linkedDailyRecordId,
  }) =>
      CreditSale(
        id: id ?? this.id,
        customerName: customerName ?? this.customerName,
        totalAmount: totalAmount ?? this.totalAmount,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        date: date ?? this.date,
        status: status ?? this.status,
        payments: payments ?? this.payments,
        linkedDailyRecordId: linkedDailyRecordId ?? this.linkedDailyRecordId,
      );

  @override
  List<Object?> get props => [
        id,
        customerName,
        totalAmount,
        remainingAmount,
        date,
        status,
        payments,
        linkedDailyRecordId,
      ];
}
