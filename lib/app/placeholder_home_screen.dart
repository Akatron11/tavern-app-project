import 'package:flutter/material.dart';

import '../core/l10n/generated/app_localizations.dart';

/// Geçici ana ekran (Faz 7'de Dashboard ile değiştirilecek).
///
/// Faz 0 amacı: tema + lokalizasyon altyapısının çalıştığını göstermek.
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(child: Text(l10n.greeting('Kemal'))),
    );
  }
}
