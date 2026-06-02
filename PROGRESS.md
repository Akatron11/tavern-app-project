# Gilanlı Köy Meyhanesi — PROGRESS

**Son güncelleme:** 2026-06-02
**Aktif faz:** Faz 1 — Firebase Kurulumu (kullanıcı aksiyonu bekliyor)
**Branch:** phase-0-foundation
**Plan:** [docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md](docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md)

> Bu dosya her adım sonrası güncellenir.

---

## Faz Durumu

- [x] **Faz 0 — Temel & Çekirdek** ✅ tamam (28 test, analyze temiz)
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

- [x] flutter create iskelet (project-name `gilanli_meyhane`, android)
- [x] pubspec.yaml bağımlılıkları + `flutter pub get` (riverpod 3.3, firebase 4/6, go_router 17, fl_chart 1.2, intl 0.20, fln 21, timezone 0.11; dev: mocktail, fake_cloud_firestore)
- [x] `git init` (main) + .gitignore (.claude/) + baseline commit + branch `phase-0-foundation` (baseline test yeşil)
- [x] l10n bootstrap (l10n.yaml, app_tr.arb/app_en.arb, gen-l10n, flutter_localizations) — TR/EN, generate:true
- [x] app_constants.dart + app_theme.dart (M3, erişilebilir)
- [x] TDD: money.dart (liraToKurus/kurusToLira) — 5 test yeşil
- [x] TDD: currency_formatter.dart + currency_extension.dart — 5 test yeşil (TR/EN)
- [x] TDD: date_utils.dart (week/month range) — 8 test yeşil
- [x] TDD: daily_record_calculator.dart (§3.1 — patron masrafı hariç) — 9 test yeşil
- [~] repo arayüzleri + firebase_providers → **Faz 1'e ertelendi** (model + Firebase init gerekiyor; YAGNI)
- [x] app.dart + router.dart + ProviderScope (placeholder home, counter kaldırıldı, smoke test)
- [x] Kabul: `flutter test` yeşil (28) + `flutter analyze` temiz

---

## Kayıt / Notlar (kronolojik)

- **2026-06-02** — Plan onaylandı (formül düzeltmeleriyle). Master plan güncellendi, PROGRESS.md oluşturuldu. Faz 0 başlıyor.
- **2026-06-02** — Faz 0: scaffold (android) + `git init` (main) + baseline test yeşil + `phase-0-foundation` dalı. Sıradaki: pubspec bağımlılıkları.
- **2026-06-02** — pubspec bağımlılıkları eklendi + commit. Sıradaki: TDD çekirdek (money → currency → date → calculator).
- **2026-06-02** — money.dart TDD (5 test yeşil) + commit. Sıradaki: currency_formatter + currency_extension.
- **2026-06-02** — currency_formatter + extension TDD (5 test yeşil) + commit. Sıradaki: date_utils.
- **2026-06-02** — date_utils TDD (8 test yeşil) + commit. Sıradaki: daily_record_calculator (§3.1, patron masrafı hariç).
- **2026-06-02** — DailyRecordCalculator TDD (9 test yeşil, düzeltilmiş formül) + commit. Çekirdek TDD tamam (27 test). Sıradaki: l10n + theme + repo arayüzleri + app shell.
- **2026-06-02** — l10n (TR/EN) + tema + sabitler + app shell (GilanliApp, GoRouter, placeholder home) tamam; counter kaldırıldı, smoke test eklendi. **Faz 0 KABUL: 28 test yeşil, analyze temiz.** repo arayüzleri Faz 1'e ertelendi. Sıradaki: Faz 0 dalını kapat, sonra Faz 1 (Firebase — kullanıcı aksiyonu gerekiyor).
