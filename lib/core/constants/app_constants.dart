/// Uygulama genelinde boyut, boşluk ve erişilebilirlik sabitleri.
library;

/// Boşluk ve boyut sabitleri.
class AppSizes {
  const AppSizes._();

  // Boşluklar
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // Erişilebilirlik (CLAUDE.md): font 14–18sp, dokunma alanı min 48dp
  static const double minFontSize = 14;
  static const double maxFontSize = 18;
  static const double minTouchTarget = 48;

  // Köşe yarıçapı
  static const double radiusMd = 12;
}

/// Animasyon süreleri.
class AppDurations {
  const AppDurations._();

  static const Duration short = Duration(milliseconds: 200);
}
