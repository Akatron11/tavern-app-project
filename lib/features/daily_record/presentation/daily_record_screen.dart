import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/money_input_field.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../../monthly_summary/application/monthly_providers.dart';
import '../application/daily_record_providers.dart';
import 'widgets/live_totals_card.dart';
import 'widgets/staff_multiselect.dart';

class DailyRecordScreen extends ConsumerStatefulWidget {
  const DailyRecordScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  ConsumerState<DailyRecordScreen> createState() => _DailyRecordScreenState();
}

class _DailyRecordScreenState extends ConsumerState<DailyRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _revenueCtrl = TextEditingController();
  final _creditCardCtrl = TextEditingController();
  final _tipsCtrl = TextEditingController();
  final _ownerExpenseCtrl = TextEditingController();
  final _cashExpenseCtrl = TextEditingController();
  final _creditSaleCtrl = TextEditingController();
  final _creditCustomerCtrl = TextEditingController();
  final _previousDayCashCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late DateTime _date;
  List<String> _selectedStaffIds = [];

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
    _loadForDate(_date);
  }

  @override
  void dispose() {
    _revenueCtrl.dispose();
    _creditCardCtrl.dispose();
    _tipsCtrl.dispose();
    _ownerExpenseCtrl.dispose();
    _cashExpenseCtrl.dispose();
    _creditSaleCtrl.dispose();
    _creditCustomerCtrl.dispose();
    _previousDayCashCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  int _kurus(TextEditingController c) => MoneyInputField.kurusOf(c);
  String _lira(int kurus) => kurus == 0 ? '' : (kurus ~/ 100).toString();

  Future<void> _loadForDate(DateTime date) async {
    final key = dayKey(DateTime(date.year, date.month, date.day));
    final rec = await ref.read(dailyRecordRepositoryProvider).getByDay(key);
    if (!mounted) return;
    setState(() {
      _revenueCtrl.text = _lira(rec?.revenue ?? 0);
      _creditCardCtrl.text = _lira(rec?.creditCard ?? 0);
      _tipsCtrl.text = _lira(rec?.tips ?? 0);
      _ownerExpenseCtrl.text = _lira(rec?.ownerExpenses ?? 0);
      _cashExpenseCtrl.text = _lira(rec?.cashExpenses ?? 0);
      _creditSaleCtrl.text = _lira(rec?.creditSales ?? 0);
      _creditCustomerCtrl.text = rec?.creditCustomerName ?? '';
      _previousDayCashCtrl.text = _lira(rec?.previousDayCash ?? 0);
      _notesCtrl.text = rec?.notes ?? '';
      _selectedStaffIds = List<String>.from(rec?.workingStaffIds ?? const []);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
      await _loadForDate(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);

    final ok = await showConfirmDialog(context, title: l10n.saveConfirmTitle);
    if (!ok) return;

    await ref.read(dailyRecordControllerProvider.notifier).saveRecord(
          date: _date,
          revenue: _kurus(_revenueCtrl),
          creditCard: _kurus(_creditCardCtrl),
          tips: _kurus(_tipsCtrl),
          ownerExpenses: _kurus(_ownerExpenseCtrl),
          cashExpenses: _kurus(_cashExpenseCtrl),
          creditSales: _kurus(_creditSaleCtrl),
          creditCustomerName: _creditCustomerCtrl.text.trim(),
          previousDayCash: _kurus(_previousDayCashCtrl),
          workingStaffIds: _selectedStaffIds,
          notes: _notesCtrl.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(dailyRecordControllerProvider);
    if (state is! AsyncError) {
      // BUG-03: bağımlı okuma sağlayıcılarını tazele (dashboard + aylık özet).
      ref.invalidate(todayRecordProvider);
      ref.invalidate(monthlyRecordsProvider);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.dailyRecordSaved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saving = ref.watch(dailyRecordControllerProvider).isLoading;

    // BUG-02: zorunlu sayısal alanlar boş bırakılamaz (0 girilebilir).
    String? requiredValidator(String? v) {
      final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      return digits.isEmpty ? l10n.requiredField : null;
    }

    ref.listen(dailyRecordControllerProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dailyRecord)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}), // canlı toplam için
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            children: [
              // Tarih
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(l10n.recordDate),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(_date)),
                trailing: const Icon(Icons.edit),
                onTap: _pickDate,
              ),
              const SizedBox(height: AppSizes.spaceSm),

              MoneyInputField(
                  controller: _revenueCtrl,
                  label: l10n.revenue,
                  validator: requiredValidator),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(
                  controller: _creditCardCtrl,
                  label: l10n.creditCardTotal,
                  validator: requiredValidator),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(controller: _tipsCtrl, label: l10n.totalTips),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(
                  controller: _ownerExpenseCtrl,
                  label: l10n.ownerExpense,
                  validator: requiredValidator),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(
                  controller: _cashExpenseCtrl,
                  label: l10n.cashExpense,
                  validator: requiredValidator),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(
                  controller: _creditSaleCtrl, label: l10n.creditSale),
              const SizedBox(height: AppSizes.spaceMd),
              TextFormField(
                controller: _creditCustomerCtrl,
                decoration: InputDecoration(labelText: l10n.creditCustomer),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  // Veresiye girilmişse müşteri adı zorunlu
                  if (_kurus(_creditSaleCtrl) > 0 &&
                      (v == null || v.trim().isEmpty)) {
                    return l10n.creditCustomerRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spaceMd),
              MoneyInputField(
                controller: _previousDayCashCtrl,
                label: l10n.previousDayCash,
                textInputAction: TextInputAction.done,
                validator: requiredValidator,
              ),
              const SizedBox(height: AppSizes.spaceLg),

              // Çalışan personeller
              Text(l10n.workingStaff,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSizes.spaceSm),
              StaffMultiSelect(
                selectedIds: _selectedStaffIds,
                onChanged: (ids) => setState(() => _selectedStaffIds = ids),
              ),
              const SizedBox(height: AppSizes.spaceLg),

              // Notlar
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(labelText: l10n.notes),
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.spaceLg),

              // Canlı toplamlar
              LiveTotalsCard(
                revenue: _kurus(_revenueCtrl),
                creditCard: _kurus(_creditCardCtrl),
                tips: _kurus(_tipsCtrl),
                ownerExpenses: _kurus(_ownerExpenseCtrl),
                cashExpenses: _kurus(_cashExpenseCtrl),
                creditSales: _kurus(_creditSaleCtrl),
                previousDayCash: _kurus(_previousDayCashCtrl),
              ),
              const SizedBox(height: AppSizes.spaceLg),

              SizedBox(
                height: AppSizes.minTouchTarget,
                child: ElevatedButton(
                  onPressed: saving ? null : _submit,
                  child: saving
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
    );
  }
}
