import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../application/staff_providers.dart';
import '../domain/staff.dart';

class StaffFormScreen extends ConsumerStatefulWidget {
  const StaffFormScreen({super.key, this.existing});

  final Staff? existing;

  @override
  ConsumerState<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends ConsumerState<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _wageCtrl;
  late Role _selectedRole;
  late bool _isActive;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _selectedRole = s?.role ?? Role.garson;
    _isActive = s?.isActive ?? true;

    // Gösterimde tam lira (kuruş / 100)
    final wageLira = s != null ? kurusToLira(s.dailyWage).toStringAsFixed(0) : '';
    _wageCtrl = TextEditingController(text: wageLira);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _wageCtrl.dispose();
    super.dispose();
  }

  int get _wageKurus => liraToKurus(int.tryParse(_wageCtrl.text) ?? 0);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);

    final ok = await showConfirmDialog(context, title: l10n.saveConfirmTitle);
    if (!ok) return;

    final controller = ref.read(staffControllerProvider.notifier);

    if (_isEdit) {
      final updated = widget.existing!.copyWith(
        name: _nameCtrl.text.trim(),
        role: _selectedRole,
        dailyWage: _wageKurus,
        isActive: _isActive,
      );
      await controller.updateStaff(updated, widget.existing!);
    } else {
      final newStaff = Staff(
        id: '',
        name: _nameCtrl.text.trim(),
        role: _selectedRole,
        dailyWage: _wageKurus,
        isActive: true,
      );
      await controller.addStaff(newStaff);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(staffControllerProvider);

    ref.listen(staffControllerProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editStaff : l10n.addStaff),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ad Soyad
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(labelText: l10n.staffName),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.staffNameRequired : null,
                ),
                const SizedBox(height: 16),

                // Rol
                DropdownButtonFormField<Role>(
                  value: _selectedRole, // ignore: deprecated_member_use
                  decoration: InputDecoration(labelText: l10n.staffRole),
                  items: Role.values.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(_roleLabel(l10n, r)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedRole = v!),
                ),
                const SizedBox(height: 16),

                // Günlük ücret
                TextFormField(
                  controller: _wageCtrl,
                  decoration: InputDecoration(labelText: l10n.dailyWage),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.dailyWageRequired;
                    final parsed = int.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) return l10n.dailyWageInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Aktif toggle (yalnızca düzenleme modunda)
                if (_isEdit)
                  SwitchListTile(
                    title: Text(l10n.isActive),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    contentPadding: EdgeInsets.zero,
                  ),

                // Ücret geçmişi (yalnızca düzenleme modunda ve geçmiş varsa)
                if (_isEdit &&
                    widget.existing!.wageHistory.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.wageHistory,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...widget.existing!.wageHistory.map(
                    (e) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history, size: 18),
                      title: Text(
                        '${kurusToLira(e.dailyWage).toStringAsFixed(0)} ₺',
                      ),
                      subtitle: Text(
                        DateFormat('dd.MM.yyyy').format(e.effectiveDate),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
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
