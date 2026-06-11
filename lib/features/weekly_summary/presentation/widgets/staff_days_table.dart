import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../staff/domain/staff.dart';

class StaffDaysTable extends StatelessWidget {
  const StaffDaysTable({
    super.key,
    required this.staffDays,
  });

  final List<({Staff staff, int days})> staffDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (staffDays.isEmpty) {
      return const SizedBox.shrink();
    }

    // BUG-13: Table yerine kompakt ListTile + gün chip'i (taşma/düzensizlik yok).
    return Column(
      children: staffDays.map((entry) {
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(entry.staff.name),
          subtitle: Text(_roleLabel(context, entry.staff.role)),
          trailing: Chip(
            label: Text('${entry.days} ${l10n.dayUnit}'),
            visualDensity: VisualDensity.compact,
          ),
        );
      }).toList(),
    );
  }

  String _roleLabel(BuildContext context, Role role) {
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case Role.garson:
        return l10n.roleGarson;
      case Role.asci:
        return l10n.roleAsci;
      case Role.barmen:
        return l10n.roleBarmen;
      case Role.kasiyer:
        return l10n.roleKasiyer;
      case Role.diger:
        return l10n.roleDiger;
    }
  }
}
