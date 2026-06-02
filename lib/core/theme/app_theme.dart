import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Uygulama teması (Material 3, erişilebilir).
class AppTheme {
  const AppTheme._();

  /// Meyhane temasına uygun sıcak kahve tonu.
  static const Color _seed = Color(0xFF6D4C41);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      // Dokunma hedefi min 48dp (erişilebilirlik).
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );

    return base.copyWith(textTheme: _accessibleTextTheme(base.textTheme));
  }

  /// Gövde metinlerini min 14sp – max 18sp aralığına çeker.
  static TextTheme _accessibleTextTheme(TextTheme base) {
    return base.copyWith(
      bodySmall: base.bodySmall?.copyWith(fontSize: AppSizes.minFontSize),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 16),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: AppSizes.maxFontSize),
    );
  }
}
