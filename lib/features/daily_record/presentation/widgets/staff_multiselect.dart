import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../staff/application/staff_providers.dart';

/// Aktif personeli FilterChip listesi olarak gösterir; seçilen id'leri
/// [onChanged] ile bildirir.
class StaffMultiSelect extends ConsumerWidget {
  const StaffMultiSelect({
    super.key,
    required this.selectedIds,
    required this.onChanged,
  });

  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final staffAsync = ref.watch(activeStaffProvider);

    return staffAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSizes.spaceSm),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => Text(e.toString()),
      data: (staff) {
        if (staff.isEmpty) {
          return Text(l10n.noActiveStaff);
        }
        return Wrap(
          spacing: AppSizes.spaceSm,
          runSpacing: AppSizes.spaceXs,
          children: staff.map((s) {
            final selected = selectedIds.contains(s.id);
            return FilterChip(
              label: Text(s.name),
              selected: selected,
              onSelected: (value) {
                final next = [...selectedIds];
                if (value) {
                  next.add(s.id);
                } else {
                  next.remove(s.id);
                }
                onChanged(next);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
