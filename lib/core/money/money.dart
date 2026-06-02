/// Para birimi yardımcıları.
///
/// Tüm tutarlar uygulama içinde **int kuruş** olarak tutulur (1 ₺ = 100 kuruş).
/// Girdi/gösterim tam lira üzerinden yapılır; bu dosya iki birim arasında çevirir.

/// Tam lirayı kuruşa çevirir. Örn. `12500` → `1250000`.
int liraToKurus(int lira) => lira * 100;

/// Kuruşu tam liraya çevirir (kuruş artığı atılır). Örn. `1250000` → `12500`.
int kurusToLira(int kurus) => kurus ~/ 100;
