import 'package:equatable/equatable.dart';

/// Bir iş gününün kasa kaydı. Tüm tutarlar **int kuruş**.
/// Belge kimliği `id` = `dayKey(date)` (yyyy-MM-dd) → gün başına tek kayıt.
class DailyRecord extends Equatable {
  final String id;
  final DateTime date;
  final int revenue; // toplam ciro (+)
  final int creditCard; // kredi kartı toplamı (−)
  final int tips; // toplam bahşiş (+)
  final int ownerExpenses; // masraf — patron karşılar (kasayı ETKİLEMEZ)
  final int cashExpenses; // masraf — kasadan çıkar (−)
  final int creditSales; // veresiye (−)
  final String creditCustomerName; // veresiye müşteri adı ('' = yok)
  final int previousDayCash; // dünden kalan kasa (+)
  final int dailyCash; // hesaplanmış günlük kasa (saklanır)
  final int totalCash; // hesaplanmış toplam kasa (saklanır)
  final List<String> workingStaffIds; // o gün çalışan personel id'leri
  final String? linkedCreditSaleId; // bağlı creditSales dokümanı (varsa)
  final String notes;

  const DailyRecord({
    required this.id,
    required this.date,
    required this.revenue,
    required this.creditCard,
    required this.tips,
    required this.ownerExpenses,
    required this.cashExpenses,
    required this.creditSales,
    this.creditCustomerName = '',
    required this.previousDayCash,
    required this.dailyCash,
    required this.totalCash,
    this.workingStaffIds = const [],
    this.linkedCreditSaleId,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'revenue': revenue,
        'creditCard': creditCard,
        'tips': tips,
        'ownerExpenses': ownerExpenses,
        'cashExpenses': cashExpenses,
        'creditSales': creditSales,
        'creditCustomerName': creditCustomerName,
        'previousDayCash': previousDayCash,
        'dailyCash': dailyCash,
        'totalCash': totalCash,
        'workingStaffIds': workingStaffIds,
        'linkedCreditSaleId': linkedCreditSaleId,
        'notes': notes,
      };

  factory DailyRecord.fromMap(String id, Map<String, dynamic> map) =>
      DailyRecord(
        id: id,
        date: DateTime.parse(map['date'] as String),
        revenue: (map['revenue'] as num).toInt(),
        creditCard: (map['creditCard'] as num).toInt(),
        tips: (map['tips'] as num).toInt(),
        ownerExpenses: (map['ownerExpenses'] as num).toInt(),
        cashExpenses: (map['cashExpenses'] as num).toInt(),
        creditSales: (map['creditSales'] as num).toInt(),
        creditCustomerName: map['creditCustomerName'] as String? ?? '',
        previousDayCash: (map['previousDayCash'] as num).toInt(),
        dailyCash: (map['dailyCash'] as num).toInt(),
        totalCash: (map['totalCash'] as num).toInt(),
        workingStaffIds:
            (map['workingStaffIds'] as List<dynamic>?)?.cast<String>() ??
                const [],
        linkedCreditSaleId: map['linkedCreditSaleId'] as String?,
        notes: map['notes'] as String? ?? '',
      );

  DailyRecord copyWith({
    String? id,
    DateTime? date,
    int? revenue,
    int? creditCard,
    int? tips,
    int? ownerExpenses,
    int? cashExpenses,
    int? creditSales,
    String? creditCustomerName,
    int? previousDayCash,
    int? dailyCash,
    int? totalCash,
    List<String>? workingStaffIds,
    String? linkedCreditSaleId,
    String? notes,
  }) =>
      DailyRecord(
        id: id ?? this.id,
        date: date ?? this.date,
        revenue: revenue ?? this.revenue,
        creditCard: creditCard ?? this.creditCard,
        tips: tips ?? this.tips,
        ownerExpenses: ownerExpenses ?? this.ownerExpenses,
        cashExpenses: cashExpenses ?? this.cashExpenses,
        creditSales: creditSales ?? this.creditSales,
        creditCustomerName: creditCustomerName ?? this.creditCustomerName,
        previousDayCash: previousDayCash ?? this.previousDayCash,
        dailyCash: dailyCash ?? this.dailyCash,
        totalCash: totalCash ?? this.totalCash,
        workingStaffIds: workingStaffIds ?? this.workingStaffIds,
        linkedCreditSaleId: linkedCreditSaleId ?? this.linkedCreditSaleId,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [
        id,
        date,
        revenue,
        creditCard,
        tips,
        ownerExpenses,
        cashExpenses,
        creditSales,
        creditCustomerName,
        previousDayCash,
        dailyCash,
        totalCash,
        workingStaffIds,
        linkedCreditSaleId,
        notes,
      ];
}
