# Gilanlı Köy Meyhanesi — PROGRESS

**Son güncelleme:** 2026-06-03
**Aktif faz:** Faz 8 — Haftalık Özet
**Branch:** main
**Plan:** [docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md](docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md)

> Bu dosya her adım sonrası güncellenir.

---

## Faz Durumu

- [x] **Faz 0 — Temel & Çekirdek** ✅ tamam (28 test, analyze temiz)
- [x] **Faz 1 — Firebase Kurulumu** ✅ kod tam; kimlikli smoke testi Faz 2 başında (Kemal hesabı + login)
- [x] **Faz 2 — Auth (Login)** ✅ tamam (31 test, analyze temiz)
- [x] **Faz 3 — Personel** ✅ tamam (37 test, analyze temiz)
- [x] **Faz 4 — Günlük Kayıt** ✅ tamam (63 test, analyze temiz)
- [x] **Faz 5 — Veresiye Defteri** ✅ tamam (69 test, analyze temiz)
- [x] **Faz 6 — Ödemeler** ✅ tamam (89 test, analyze temiz)
- [x] **Faz 7 — Dashboard** ✅ tamam (92 test, analyze temiz)
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
- **2026-06-02** — ✅ **Faz 0 KAPANDI**: `phase-0-foundation` → `main` (FF merge), dal silindi. 8 commit, 28 test yeşil. Faz 1 (Firebase) kullanıcı aksiyonu bekliyor.
- **2026-06-02** — Faz 1: Firebase projesi `gilanli-meyhane` oluşturuldu. Android uygulaması + Firestore + Auth (email/password) init. `flutterfire configure` → `firebase_options.dart` üretildi. `main.dart` Firebase+tz init ile güncellendi. `firebase_providers.dart` oluşturuldu. Güvenlik kuralları (`request.auth != null`) deploy edildi. **Kalan:** Firebase Console'dan Kemal hesabı oluşturulacak.
- **2026-06-02** — ✅ **Faz 1 VERIFICATION**: `flutter test` 28/28 yeşil, `flutter analyze` 0 issue, `firestore.rules` canlı deploy doğrulandı (MCP). Kimliksiz erişim kurallarla reddediliyor ✅. Kimlikli smoke testi Faz 2 başında yapılacak (Kemal hesabı + login ekranı gerekiyor). Faz 1 KOD KABUL.
- **2026-06-02** — ✅ **Faz 2 KABUL**: AuthRepository + FirebaseAuthRepository + MockAuthRepository + auth_providers (LoginController, LogoutController) + login_screen.dart + router auth guard + çıkış onay dialog'u + 3 widget testi. `flutter test` 31/31 yeşil, `flutter analyze` 0 issue.
- **2026-06-02** — ✅ **Faz 3 KABUL**: Staff model (Role enum + WageHistoryEntry + equatable) + TDD WageResolver (6 test, §3.2) + StaffRepository/Firestore/Mock + staff_providers (ekle/güncelle/pasifle/sil) + StaffListScreen + StaffFormScreen + confirm_dialog.dart (shared) + router /staff rotası + ARB TR/EN string'leri. `flutter test` 37/37 yeşil, `flutter analyze` 0 issue.
- **2026-06-03** — Faz 4 başladı: `superpowers:writing-plans` ile ayrıntılı TDD planı yazıldı ([docs/superpowers/plans/2026-06-03-faz-4-gunluk-kayit.md](docs/superpowers/plans/2026-06-03-faz-4-gunluk-kayit.md)), `phase-4-daily-record` dalı açıldı. **Kapsam kararı:** §1.3 mutabakatı ve "veresiye creditSales'e yansıma" kabul kriteri gereği minimal `CreditSale` modeli + `CreditReconciler.reconcile` (§3.4 TDD) + `CreditSaleRepository` Faz 4'e çekildi; Faz 5 yalnızca Veresiye Defteri UI'ını ekleyecek. Personel tahakkuku §1.2 gereği yazılmadı (yalnızca `workingStaffIds` saklanır).
- **2026-06-03** — ✅ **Faz 4 KABUL**: DailyRecord modeli + repo üçlüsü; CreditSale modeli + reconcile + repo üçlüsü; `DailyRecordController.saveRecord` orkestrasyonu (veresiye oluştur/mutabık/sıfırla, dailyCash patron masrafı hariç); MoneyInputField, LiveTotalsCard (canlı kasa, iki masraf ayrı), StaffMultiSelect; DailyRecordScreen (tüm alanlar + kaydet onayı + tarih ile yükleme); /daily rotası + ana ekran hızlı erişim kartları; ARB TR/EN. TDD: model roundtrip (4+3), reconcile (5), controller (5), repo (3+3), LiveTotalsCard (2), ekran canlı toplam (1). `flutter test` **63/63 yeşil**, `flutter analyze` **0 issue**. Sıradaki: dalı `main`'e FF merge, sonra Faz 5.
- **2026-06-03** — ✅ **Faz 6 KABUL**: PayrollCalculator (TDD, §3.3) + StaffPayment + PendingExpense modelleri + PaymentRepository (abstract/Firestore/Mock) + DailyRecordRepository.getAll() + payments_providers (PaymentsController) + StaffPaymentsTab (tahakkuk/ödeme/kalan) + PendingExpensesTab (gider CRUD + kısmi ödeme) + PaymentsScreen (2 sekme) + router + ana ekran kartı + l10n TR/EN. `flutter test` **89/89 yeşil**, `flutter analyze` **0 issue**.
- **2026-06-03** — Faz 6 başladı: `superpowers:writing-plans` ile ayrıntılı TDD planı yazıldı ([docs/superpowers/plans/2026-06-03-faz-6-odemeler.md](docs/superpowers/plans/2026-06-03-faz-6-odemeler.md)), `phase-6-payments` dalı açıldı.
- **2026-06-03** — ✅ **Faz 5 KABUL**: `credit_book_providers.dart` (CreditBookController: addSale/addPayment/markPaid/undoPaid) + `watchAll()` repo genişletmesi + `CreditListScreen` (liste, durum chip'i, BottomSheet aksiyonlar) + `CreditSaleTile` + `CreditForm` (ekleme/düzenleme) + `PaymentDialog` (kısmi ödeme, validasyon) + `/credit` router rotaları + ana ekran kartı + ARB TR/EN. `creditSaleRepositoryProvider` `credit_book_providers.dart`'a taşındı. TDD: 5 controller testi + 1 widget testi. `flutter test` **69/69 yeşil**, `flutter analyze` **0 issue**. Sıradaki: `phase-5-credit-book` → `main` (FF merge), sonra Faz 6.
- **2026-06-03** — ✅ **Faz 7 KABUL**: `todayRecordProvider` (FutureProvider) + `TodaySummaryCard` (kayıt var/yok senaryoları) + `DashboardScreen` (tarih, selamlama, özet kart, 6 navigasyon kartı) + router `/` → DashboardScreen + `/weekly` `/monthly` placeholder rotalar + l10n TR/EN (5 yeni string) + `initializeDateFormatting` eklendi. `PlaceholderHomeScreen` silindi, `login_screen_test.dart` DashboardScreen'e güncellendi. `flutter test` **92/92 yeşil**, `flutter analyze` **0 issue**.

---

## Faz 4 — Adımlar

- [x] T1: DailyRecord modeli (TDD roundtrip, 4 test)
- [x] T2: DailyRecordRepository üçlüsü (abstract/Firestore/Mock) + fake_cloud_firestore testi (3)
- [x] T3: CreditSale modeli + CreditStatus + CreditPayment (TDD roundtrip, 3)
- [x] T4: CreditReconciler.reconcile (TDD §3.4, 5 test)
- [x] T5: CreditSaleRepository üçlüsü + fake_cloud_firestore testi (3)
- [x] T6: daily_record_providers + DailyRecordController.saveRecord orkestrasyonu (TDD, 5 test)
- [x] T7: l10n TR/EN string'leri + gen-l10n
- [x] T8: MoneyInputField (shared, lira→kuruş)
- [x] T9: LiveTotalsCard + widget testleri (2)
- [x] T10: StaffMultiSelect (aktif personel çoklu seçim)
- [x] T11: DailyRecordScreen (tüm alanlar, canlı toplam, kaydet onayı, tarih ile yükleme)
- [x] T12: /daily rotası + ana ekran hızlı erişim kartları
- [x] T13: DailyRecordScreen widget testi (alan değişince canlı toplam güncellenir, 1)
- [x] T14: Tam doğrulama (63 test yeşil, analyze temiz) + PROGRESS güncelleme

---

## Faz 5 — Adımlar

- [x] T1: CreditSaleRepository abstract + Firestore + Mock'a `watchAll()` eklendi
- [x] T2: `credit_book_providers.dart` oluşturuldu (creditSaleRepositoryProvider taşıma + CreditBookController) + 5 unit test
- [x] T3: ARB TR/EN string'leri (veresiye defteri) + gen-l10n
- [x] T4: `CreditForm` (ekleme + düzenleme modu) + MoneyInputField validator desteği
- [x] T5: `PaymentDialog` (kısmi ödeme, validasyon)
- [x] T6: `CreditSaleTile` + `CreditListScreen` (liste, durum chip, BottomSheet aksiyonlar)
- [x] T7: Router `/credit`, `/credit/add`, `/credit/edit` + ana ekran kartı
- [x] T8: Widget testi (CreditListScreen), tam doğrulama (69 test yeşil, analyze temiz)

---

## Faz 7 — Adımlar

- [x] T1: `phase-7-dashboard` branch + l10n TR/EN (todaySummary, noRecordToday, workingStaffCountLabel, openWeeklySummary, openMonthlySummary)
- [x] T2: `dashboard_providers.dart` (todayRecordProvider)
- [x] T3: `TodaySummaryCard` widget + 2 widget testi (kayıt yok / kayıt var)
- [x] T4: `DashboardScreen` (tarih+selamlama+özet+6 kart) + router `/` → Dashboard + `/weekly` `/monthly` placeholder + `initializeDateFormatting` + PlaceholderHomeScreen silindi
- [x] T5: DashboardScreen navigasyon widget testi (selamlama + 6 kart)
- [x] T6: Tam doğrulama (92 test yeşil, analyze temiz) + PROGRESS güncelleme + merge
