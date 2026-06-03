import 'package:equatable/equatable.dart';

class StaffPayment extends Equatable {
  final String id;
  final String staffId;
  final int amount; // kuruş
  final DateTime date;
  final String notes;

  const StaffPayment({
    required this.id,
    required this.staffId,
    required this.amount,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'type': 'staff',
        'staffId': staffId,
        'amount': amount,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory StaffPayment.fromMap(String id, Map<String, dynamic> map) =>
      StaffPayment(
        id: id,
        staffId: map['staffId'] as String,
        amount: (map['amount'] as num).toInt(),
        date: DateTime.parse(map['date'] as String),
        notes: map['notes'] as String? ?? '',
      );

  StaffPayment copyWith({
    String? id,
    String? staffId,
    int? amount,
    DateTime? date,
    String? notes,
  }) =>
      StaffPayment(
        id: id ?? this.id,
        staffId: staffId ?? this.staffId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [id, staffId, amount, date, notes];
}
