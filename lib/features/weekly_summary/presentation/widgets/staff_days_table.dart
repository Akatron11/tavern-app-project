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

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          children: [
            _cell(l10n.staffName, bold: true),
            _cell(l10n.staffRole, bold: true),
            _cell(l10n.staffDaysTitle,
                bold: true, align: TextAlign.center),
          ],
        ),
        ...staffDays.map(
          (entry) => TableRow(
            children: [
              _cell(entry.staff.name),
              _cell(_roleLabel(context, entry.staff.role)),
              _cell('${entry.days}', align: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(String text,
      {bool bold = false, TextAlign align = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        textAlign: align,
        style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
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
