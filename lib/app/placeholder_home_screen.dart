import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../features/auth/application/auth_providers.dart';

/// Geçici ana ekran — Faz 7'de Dashboard ile değiştirilecek.
class PlaceholderHomeScreen extends ConsumerWidget {
  const PlaceholderHomeScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(logoutControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.greeting('Kemal'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(l10n.openDailyRecord),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/daily'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.people),
                title: Text(l10n.openStaff),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/staff'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(l10n.openCreditBook),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/credit'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(l10n.openPayments),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/payments'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
