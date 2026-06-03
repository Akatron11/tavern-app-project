import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/l10n/generated/app_localizations.dart';
import 'widgets/today_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateStr =
        intl.DateFormat('d MMMM y, EEEE', locale).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.openSettings,
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              l10n.greeting('Kemal'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const TodaySummaryCard(),
            const SizedBox(height: 16),
            _NavCard(
              icon: Icons.receipt_long,
              label: l10n.openDailyRecord,
              route: '/daily',
            ),
            _NavCard(
              icon: Icons.bar_chart,
              label: l10n.openWeeklySummary,
              route: '/weekly',
            ),
            _NavCard(
              icon: Icons.calendar_month,
              label: l10n.openMonthlySummary,
              route: '/monthly',
            ),
            _NavCard(
              icon: Icons.people,
              label: l10n.openStaff,
              route: '/staff',
            ),
            _NavCard(
              icon: Icons.menu_book_outlined,
              label: l10n.openCreditBook,
              route: '/credit',
            ),
            _NavCard(
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.openPayments,
              route: '/payments',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
