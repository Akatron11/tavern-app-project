import 'package:equatable/equatable.dart';

class PayrollSummary extends Equatable {
  final String staffId;
  final String staffName;
  final int workedDays;
  final int accruedWage; // kuruş

  const PayrollSummary({
    required this.staffId,
    required this.staffName,
    required this.workedDays,
    required this.accruedWage,
  });

  @override
  List<Object?> get props => [staffId, staffName, workedDays, accruedWage];
}

/// UI katmanı için türetilmiş satır (provider'da hesaplanır).
class StaffPayrollRow extends Equatable {
  final String staffId;
  final String staffName;
  final int workedDays;
  final int accruedWage; // kuruş — PayrollCalculator
  final int totalPaid; // kuruş — Σ StaffPayment.amount
  final int remaining; // max(0, accruedWage − totalPaid)

  const StaffPayrollRow({
    required this.staffId,
    required this.staffName,
    required this.workedDays,
    required this.accruedWage,
    required this.totalPaid,
    required this.remaining,
  });

  @override
  List<Object?> get props =>
      [staffId, staffName, workedDays, accruedWage, totalPaid, remaining];
}
