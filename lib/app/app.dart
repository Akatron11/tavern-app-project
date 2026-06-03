import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/application/settings_providers.dart';
import 'router.dart';

class GilanliApp extends ConsumerStatefulWidget {
  const GilanliApp({super.key});

  @override
  ConsumerState<GilanliApp> createState() => _GilanliAppState();
}

class _GilanliAppState extends ConsumerState<GilanliApp> {
  @override
  void initState() {
    super.initState();
    // İlk frame sonrası: izin iste (açıksa) + mevcut bildirim tercihini uygula.
    Future.microtask(
      () => ref.read(settingsProvider.notifier).bootstrapNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
