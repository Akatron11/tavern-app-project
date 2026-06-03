# Gilanlı Köy Meyhanesi — Muhasebe Uygulaması

Tek kullanıcılı (Kemal) Flutter mobil muhasebe uygulaması. Günlük kasa kaydı,
personel ücret takibi, veresiye defteri, ödemeler ve haftalık/aylık özet
raporları sunar. Türkçe/İngilizce dil desteği ve günlük yerel hatırlatma
bildirimi içerir.

> **Platform:** Android (öncelikli). iOS derlemesi macOS gerektirdiğinden bu
> sürümün kapsamı dışındadır (master plan onay #1).

---

## Özellikler (MVP v1.0)

- **Giriş (Auth):** E-posta/şifre ile Firebase Authentication; kalıcı oturum; çıkış onayı.
- **Dashboard:** Tarih + karşılama, bugünün özeti (günlük kasa, çalışan sayısı), hızlı erişim kartları.
- **Günlük Kayıt:** Ciro, kredi kartı, bahşiş, kasa/patron masrafı (ayrı), veresiye, çalışan personel; canlı kasa hesabı; tarih ile düzenleme.
- **Personel:** CRUD (silme kısıtlı), rol, günlük ücret ve **ücret geçmişi** (zam geçmişe yansımaz).
- **Veresiye Defteri:** Liste/durum, ekleme, kısmi/tam ödeme, geri alma, düzenleme + mutabakat.
- **Ödemeler:** Personel tahakkuku (çalışılan gün × ücret) + kısmi ödeme; bekleyen giderler.
- **Haftalık Özet:** Günlük ciro bar grafiği, günlük liste, personel-gün tablosu, bahşiş dağıtımı ("Dağıtıldı, kapat").
- **Aylık Özet:** 8 özet kartı (Kâr/Zarar dahil), ciro grafiği, veresiye tablosu, ay gezinme.
- **Ayarlar:** Dil (anında değişir), bildirim saati + aç/kapa, çıkış.
- **i18n:** Türkçe (varsayılan) + İngilizce, tam ARB tabanlı.
- **Bildirim:** Kullanıcı saatinde günlük tekrarlı yerel hatırlatma.

---

## Tech Stack

| Katman | Teknoloji |
|---|---|
| UI | Flutter (Material 3) |
| State | Riverpod (`flutter_riverpod` ^3.3) |
| Yönlendirme | `go_router` ^17.2 |
| Backend / DB | Firebase Firestore + Auth (`firebase_core` ^4, `cloud_firestore` ^6, `firebase_auth` ^6) |
| Grafikler | `fl_chart` ^1.2 |
| Bildirim | `flutter_local_notifications` ^21 + `timezone` / `flutter_timezone` |
| Lokalizasyon | `flutter_localizations` + `intl` ^0.20 + gen-l10n (ARB) |
| Kalıcı ayar | `shared_preferences` ^2.5 |
| Model eşitliği | `equatable` ^2 |
| Test | `flutter_test`, `mocktail`, `fake_cloud_firestore` |

**SDK:** Dart `^3.10.4` (Flutter 3.38+).

---

## Mimari

Feature-first katmanlı mimari. Her özellik `domain` / `data` / `application` /
`presentation` katmanlarına ayrılır.

- **Repository pattern (zorunlu):** UI doğrudan Firestore'a erişmez. Her repo'nun
  `xyz_repository.dart` (abstract) + `firestore_xyz_repository.dart` (canlı) +
  `mock_xyz_repository.dart` (bellek-içi; dev/test) üçlüsü vardır.
- **Saf hesaplama servisleri (TDD):** Tüm para mantığı Firebase/Flutter
  bağımsız, unit-test edilebilir saf fonksiyonlarda toplanır:
  `DailyRecordCalculator`, `WageResolver`, `PayrollCalculator`,
  `MonthlyReportCalculator`, veresiye `CreditReconciler`.
- **Para:** Dahili saklama `int` **kuruş** (1 ₺ = 100 kuruş); gösterimde
  `formatCurrency()` / `int.toCurrency(locale)` (`1.000 ₺`).
- **State:** Riverpod provider'ları feature bazlı; paylaşılan state `shared/`.

```
lib/
├── main.dart                # bootstrap: Firebase + tz init, prefs, ProviderScope
├── firebase_options.dart    # flutterfire configure çıktısı
├── app/                     # app.dart (MaterialApp.router) + router.dart (auth guard)
├── core/                    # constants, theme, money, utils, l10n
├── features/                # auth, staff, daily_record, credit_book, payments,
│                            #   dashboard, weekly_summary, monthly_summary, settings
└── shared/                  # widgets/ + providers/ (firebase, prefs)
```

Ayrıntılı mimari ve kararlar: [docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md](docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md).

---

## Ön Koşullar

- **Flutter SDK** (Dart `^3.10.4` ile uyumlu, 3.38+).
- **Android toolchain:** Android Studio / SDK, bir emülatör veya USB hata
  ayıklama açık fiziksel cihaz. (Bildirim için Android 13+ POST_NOTIFICATIONS izni.)
- **Firebase CLI** (`firebase-tools`) ve `flutterfire_cli` — Firebase yeniden
  yapılandırması gerekirse.

---

## Kurulum

```bash
# 1) Bağımlılıklar
flutter pub get

# 2) Lokalizasyon kodunu üret (pubspec'te generate:true ile derlemede de üretilir)
flutter gen-l10n

# 3) Firebase yapılandırması
#    - firebase_options.dart depoda mevcut (proje: gilanli-meyhane).
#    - Yeniden yapılandırma gerekirse:
#        dart pub global activate flutterfire_cli
#        flutterfire configure
#    - Firestore güvenlik kuralları (auth-gated):
#        firebase deploy --only firestore:rules
#    - Kemal'in kullanıcısı Firebase Console > Authentication > Add user
#      ile oluşturulur (uygulama içi kayıt ekranı yoktur).
```

---

## Çalıştırma

```bash
flutter run                       # bağlı cihaz/emülatörde çalıştır
flutter build apk --debug         # hata ayıklama APK'sı
flutter build apk --release       # yayın APK'sı (android/ imza yapılandırması gerekir)
```

Çıktı APK: `build/app/outputs/flutter-apk/`.

---

## Test & Analiz

```bash
flutter test       # tüm unit + widget testleri (129 test)
flutter analyze    # statik analiz (flutter_lints) — temiz olmalı
```

Çekirdek hesaplama servisleri TDD (red→green→refactor) ile yazılmıştır;
manuel uçtan uca senaryolar için [docs/QA-checklist.md](docs/QA-checklist.md).

---

## Lokalizasyon

- Kaynaklar: `lib/core/l10n/app_tr.arb` (şablon/varsayılan) + `app_en.arb`.
- Üretilen sınıf: `AppLocalizations` (`lib/core/l10n/generated/`).
- Kural: Türkçe veya İngilizce **hiçbir string hardcode edilmez**; tümü ARB'de.
- Dil, Ayarlar ekranından **yeniden başlatmadan** değişir.

---

## Erişilebilirlik

- Gövde metni 14–18sp (`AppSizes.minFontSize`/`maxFontSize`; tema text theme).
- Dokunma hedefi ≥ 48dp (`MaterialTapTargetSize.padded`; IconButton'lar tooltip'li).
- Durum bilgisi renk + metinle birlikte verilir (renk tek gösterge değildir).
- İstisna: grafik eksen tick etiketleri veri-görselleştirme gereği < 14sp olabilir.

---

## Bilinen Kısıtlar (v2'ye ertelendi)

- **iOS:** Windows'ta derlenemez → Android-öncelikli.
- **Bildirim:** "Kayıt zaten girildiyse gösterme" tam koşullu sürüm v2.
- **Güvenlik kuralları:** Tek kullanıcı için auth-gated; per-uid kapsam + alan
  doğrulaması v2 (master plan §1.9).
- **Çok kullanıcı, CSV/PDF export, gelişmiş raporlama:** kapsam dışı.

---

## Belgeler

- Proje talimatları: [CLAUDE.md](CLAUDE.md)
- Master plan: [docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md](docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md)
- İlerleme: [PROGRESS.md](PROGRESS.md)
- Manuel QA: [docs/QA-checklist.md](docs/QA-checklist.md)
