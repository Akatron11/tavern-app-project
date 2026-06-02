import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

/// Kök uygulama widget'ı.
///
/// Varsayılan dil Türkçe'dir (spec §5). Faz 10'da dil seçimi bir provider
/// üzerinden kullanıcı tarafından değiştirilebilir hâle gelecek.
class GilanliApp extends ConsumerWidget {
  const GilanliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
