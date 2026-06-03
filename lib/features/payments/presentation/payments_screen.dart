import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import 'widgets/pending_expenses_tab.dart';
import 'widgets/staff_payments_tab.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.payments),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.staffPaymentsTab),
              Tab(text: l10n.expensesTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StaffPaymentsTab(),
            PendingExpensesTab(),
          ],
        ),
      ),
    );
  }
}
