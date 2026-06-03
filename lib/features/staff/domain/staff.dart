import 'package:equatable/equatable.dart';

enum Role {
  garson,
  asci,
  barmen,
  kasiyer,
  diger;

  static Role fromString(String value) {
    return Role.values.firstWhere(
      (r) => r.name == value,
      orElse: () => Role.diger,
    );
  }
}

class WageHistoryEntry extends Equatable {
  final DateTime effectiveDate;
  final int dailyWage; // kuruş

  const WageHistoryEntry({
    required this.effectiveDate,
    required this.dailyWage,
  });

  Map<String, dynamic> toMap() => {
        'effectiveDate': effectiveDate.toIso8601String(),
        'dailyWage': dailyWage,
      };

  factory WageHistoryEntry.fromMap(Map<String, dynamic> map) =>
      WageHistoryEntry(
        effectiveDate: DateTime.parse(map['effectiveDate'] as String),
        dailyWage: (map['dailyWage'] as num).toInt(),
      );

  WageHistoryEntry copyWith({DateTime? effectiveDate, int? dailyWage}) =>
      WageHistoryEntry(
        effectiveDate: effectiveDate ?? this.effectiveDate,
        dailyWage: dailyWage ?? this.dailyWage,
      );

  @override
  List<Object?> get props => [effectiveDate, dailyWage];
}

class Staff extends Equatable {
  final String id;
  final String name;
  final Role role;
  final int dailyWage; // kuruş — güncel ücret
  final List<WageHistoryEntry> wageHistory;
  final bool isActive;

  const Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.dailyWage,
    this.wageHistory = const [],
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'role': role.name,
        'dailyWage': dailyWage,
        'wageHistory': wageHistory.map((e) => e.toMap()).toList(),
        'isActive': isActive,
      };

  factory Staff.fromMap(String id, Map<String, dynamic> map) => Staff(
        id: id,
        name: map['name'] as String,
        role: Role.fromString(map['role'] as String),
        dailyWage: (map['dailyWage'] as num).toInt(),
        wageHistory: (map['wageHistory'] as List<dynamic>?)
                ?.map((e) => WageHistoryEntry.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        isActive: map['isActive'] as bool? ?? true,
      );

  Staff copyWith({
    String? id,
    String? name,
    Role? role,
    int? dailyWage,
    List<WageHistoryEntry>? wageHistory,
    bool? isActive,
  }) =>
      Staff(
        id: id ?? this.id,
        name: name ?? this.name,
        role: role ?? this.role,
        dailyWage: dailyWage ?? this.dailyWage,
        wageHistory: wageHistory ?? this.wageHistory,
        isActive: isActive ?? this.isActive,
      );

  @override
  List<Object?> get props => [id, name, role, dailyWage, wageHistory, isActive];
}
