import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../auth/application/auth_providers.dart';
import '../application/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      ),
    );
    if (picked != null) {
      await ref
          .read(settingsProvider.notifier)
          .setNotificationTime(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final timeLabel = TimeOfDay(
      hour: settings.notificationHour,
      minute: settings.notificationMinute,
    ).format(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Dil ---
            Text(
              l10n.languageSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RadioGroup<String>(
              groupValue: settings.localeCode,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setLocale(v!),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(l10n.turkish),
                    value: 'tr',
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.english),
                    value: 'en',
                  ),
                ],
              ),
            ),
            const Divider(),

            // --- Bildirimler ---
            Text(
              l10n.notifications,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SwitchListTile(
              title: Text(l10n.notificationsEnabled),
              value: settings.notificationsEnabled,
              onChanged: (v) => ref
                  .read(settingsProvider.notifier)
                  .setNotificationsEnabled(v),
            ),
            ListTile(
              enabled: settings.notificationsEnabled,
              leading: const Icon(Icons.schedule),
              title: Text(l10n.notificationTime),
              trailing: Text(timeLabel),
              onTap: settings.notificationsEnabled
                  ? () => _pickTime(context, ref)
                  : null,
            ),
            const Divider(),

            // --- Çıkış ---
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.logout),
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
