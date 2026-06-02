# Gilanlı Köy Meyhanesi — PROGRESS

**Son güncelleme:** 2026-06-02
**Aktif faz:** Faz 0 — Temel & Çekirdek
**Branch:** (kurulacak)
**Plan:** [docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md](docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md)

> Bu dosya her adım sonrası güncellenir.

---

## Faz Durumu

- [ ] **Faz 0 — Temel & Çekirdek** ⏳ devam ediyor
- [ ] Faz 1 — Firebase Kurulumu
- [ ] Faz 2 — Auth (Login)
- [ ] Faz 3 — Personel
- [ ] Faz 4 — Günlük Kayıt
- [ ] Faz 5 — Veresiye Defteri
- [ ] Faz 6 — Ödemeler
- [ ] Faz 7 — Dashboard
- [ ] Faz 8 — Haftalık Özet
- [ ] Faz 9 — Aylık Özet
- [ ] Faz 10 — Ayarlar / Bildirim / i18n
- [ ] Faz 11 — Sağlamlaştırma & Cila

---

## Faz 0 — Adımlar

- [ ] flutter create iskelet (project-name `gilanli_meyhane`, android) + örnek kod temizliği
- [ ] pubspec.yaml bağımlılıkları + `flutter pub get`
- [ ] analysis_options.yaml + .gitignore + `git init` + ilk commit + çalışma dalı
- [ ] l10n bootstrap (l10n.yaml, app_tr.arb/app_en.arb, gen-l10n, flutter_localizations)
- [ ] app_constants.dart + app_theme.dart (M3, erişilebilir)
- [ ] TDD: money.dart (liraToKurus/kurusToLira)
- [ ] TDD: currency_formatter.dart + currency_extension.dart
- [ ] TDD: date_utils.dart (week/month range)
- [ ] TDD: daily_record_calculator.dart (§3.1 — patron masrafı hariç)
- [ ] repo arayüzleri + firebase_providers iskeleti
- [ ] app.dart + router.dart + ProviderScope (placeholder home)
- [ ] Kabul: `flutter test` yeşil + `flutter analyze` temiz

---

## Kayıt / Notlar (kronolojik)

- **2026-06-02** — Plan onaylandı (formül düzeltmeleriyle). Master plan güncellendi, PROGRESS.md oluşturuldu. Faz 0 başlıyor.
