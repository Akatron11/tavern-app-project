import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../application/staff_providers.dart';
import '../domain/staff.dart';
import 'staff_form_screen.dart';

class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final staffAsync = ref.watch(allStaffProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.staffList)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_staff',
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.person_add),
      ),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text(
                l10n.noStaff,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (ctx, i) => _StaffTile(staff: list[i]),
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, Staff? staff) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StaffFormScreen(existing: staff),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _StaffTile extends ConsumerWidget {
  const _StaffTile({required this.staff});
  final Staff staff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(staffControllerProvider.notifier);

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
        ),
      ),
      title: Text(
        staff.name,
        style: staff.isActive
            ? null
            : TextStyle(
                color: Theme.of(context).disabledColor,
                decoration: TextDecoration.lineThrough,
              ),
      ),
      subtitle: Text(_roleLabel(l10n, staff.role)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!staff.isActive)
            Chip(
              label: Text(l10n.inactive),
              visualDensity: VisualDensity.compact,
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.editStaff,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StaffFormScreen(existing: staff),
              ),
            ),
          ),
          if (staff.isActive)
            IconButton(
              icon: const Icon(Icons.person_off),
              tooltip: l10n.deactivate,
              onPressed: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: l10n.deactivateConfirmTitle,
                  body: l10n.deactivateConfirmBody,
                );
                if (ok) await controller.deactivateStaff(staff.id);
              },
            ),
        ],
      ),
    );
  }

  String _roleLabel(AppLocalizations l10n, Role role) {
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
