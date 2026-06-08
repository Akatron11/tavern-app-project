# Gilanlı Köy Meyhanesi — PROGRESS

**Son güncelleme:** 2026-06-04
**Aktif faz:** Faz 12 — QA Tur 1 düzeltmeleri (🔄 DEVAM — 9/20 madde tamam)
**Branch:** `phase-12-qa-fixes` (main'e henüz MERGE EDİLMEDİ)
**Plan:** [docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md](docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md)

> Bu dosya her adım sonrası güncellenir.

---

## ▶️ KALDIĞIMIZ YER — Faz 12 (yeni sohbette BURADAN devam et)

**İlk iş:** `git checkout phase-12-qa-fixes` (çalışma bu dalda; main'e merge edilmedi).
**Plan:** [docs/superpowers/plans/2026-06-04-faz-12-qa-tur1-duzeltmeleri.md](docs/superpowers/plans/2026-06-04-faz-12-qa-tur1-duzeltmeleri.md)
**Bug raporu:** [docs/bugreport-qa-round1.md](docs/bugreport-qa-round1.md)
**Durum:** 9/20 madde tamam · **139 test yeşil** · analyze temiz · her madde ayrı commit.

### ✅ Tamamlanan (commit'li)
BUG-09 (kâr formülü: kredi kartı çıkarıldı) · BUG-01 (veresiye 0'a inince ödemesizse silinir) ·
BUG-04/07 (ödeme dialog çökmesi + taşma) · BUG-15 (para canlı binlik ayraç) ·
BUG-02 (günlük kayıt zorunlu alan) · BUG-03 (kayıt sonrası dashboard tazeleme) ·
BUG-10 (aylık veresiye reaktivitesi) · BUG-11 ("Tahsil Bekleyen Veresiye").

### ⏳ Kalan (plandaki Tier sırasıyla)
- **Tier 3.2 — BUG-08:** Gider düzenlemede `remaining = totalAmount − paidAmount` anında yeniden hesaplansın (`payments_providers.dart` + `pending_expense.dart`).
- **Tier 3.3 — BUG-05/06:** Günlük kayıttan gelen veresiyede tarih dolu+listede görünür (`credit_sale_tile.dart`); manuel veresiye formuna DatePicker (`credit_form.dart`).
- **Tier 3.4 — BUG-16:** Günlük kayıt kaydedilince bugünkü bildirimi iptal + ertesi güne planla (pragmatik; `daily_record_providers` + `notification_service`).
- **Tier 3.5 — YENİ-01/02:** `status==paid` veresiye **ve** gider onay dialog'uyla silinebilsin. NOT: `CreditSaleRepository.delete` ZATEN eklendi (BUG-01'de); `PaymentRepository`'ye `delete` + UI ("Sil" + onay) eklenecek.
- **Tier 4 — kozmetik/UX:** BUG-12 (haftalık liste tam ay adı `MMM`→`MMMM`, `daily_summary_list.dart`) · BUG-13 (personel günleri tablo taşması, `staff_days_table.dart`) · BUG-14 ("bu günün" yazım — önce `rg "[Bb]u günün" lib` ile yeri bul; `todaySummary` zaten doğru görünüyor) · İYİ-01 (dashboard kartı: çalışan sayısı yerine günün cirosu, `today_summary_card.dart`) · İYİ-02 (login şifre göster/gizle toggle).
- **Tier 5 — Kapanış:** `flutter test`+`analyze`+`build apk --debug`; `verification-before-completion`; PROGRESS + bug rapor durumları; `finishing-a-development-branch` ile `phase-12-qa-fixes` → `main` merge.

### Onaylı kararlar (yeni sohbette TEKRAR SORMA)
- YENİ-01/02 → **EVET, ikisi de** silinebilir (onay dialog'lu, yalnızca `paid`).
- BUG-16 → **şimdi uygula** (pragmatik: kayıt sonrası bugünkü bildirimi iptal et).
- BUG-09 (kredi kartı çıkar) ve BUG-11 ("Tahsil Bekleyen") → onaylandı ve YAPILDI.

### Süreç (CLAUDE.md)
Önce 3 dosya (CLAUDE.md + master plan + bu dosya) → `superpowers:executing-plans` ile Faz 12 planından devam →
her bug'da `superpowers:systematic-debugging` (reprodüksiyon/TDD → kök neden → düzeltme → doğrulama) →
her adım bitmeden `superpowers:verification-before-completion`. Her düzeltmeyi ayrı commit'le.

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
- [x] **Faz 8 — Haftalık Özet** ✅ tamam (102 test, analyze temiz)
- [x] **Faz 9 — Aylık Özet** ✅ tamam (116 test, analyze temiz)
- [x] **Faz 10 — Ayarlar / Bildirim / i18n** ✅ tamam (129 test, analyze temiz, debug APK derlendi)
- [x] **Faz 11 — Sağlamlaştırma & Cila** ✅ tamam (129 test, analyze temiz, debug APK derlendi) — **MVP DoD ✅**
- [~] **Faz 12 — QA Tur 1 düzeltmeleri** 🔄 DEVAM (9/20 madde tamam, 139 test yeşil, analyze temiz) — bkz. "KALDIĞIMIZ YER" bölümü

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
- **2026-06-03** — ✅ **Faz 8 KABUL**: Plan yazıldı (`2026-06-03-faz-8-haftalik-ozet.md`), `phase-8-weekly-summary` dalı. ARB TR/EN (12 string) + `TipDistribution` model (TDD, 3 test) + `TipDistributionRepository` üçlüsü + `DailyRecordRepository.getByDateRange()` (TDD, 3 test) + `weekly_providers` (weekOffset/Notifier, currentWeekRange, weeklyRecords, openTips, staffDays, TipDistributionController) + `WeeklyBarChart` (fl_chart) + `DailySummaryList` + `StaffDaysTable` + `WeeklySummaryScreen` + router `/weekly` güncellendi. `flutter test` **102/102 yeşil**, `flutter analyze` **0 issue**.
- **2026-06-03** — ✅ **Faz 9 KABUL**: Plan yazıldı (`2026-06-03-faz-9-aylik-ozet.md`), `phase-9-monthly-summary` dalı. ARB TR/EN (12 string) + `MonthlyReport` data class + TDD `MonthlyReportCalculator` (5 test, §3.5) + `CreditSaleRepository.getByDateRange` (abstract + Firestore + Mock) + `monthly_providers` (offset/range/records/credits/wages/report, 5 test) + `MonthlyBarChart` (fl_chart) + `MonthlyCreditTable` + `SummaryCardsSection` (8 kart) + `MonthlySummaryScreen` + router `/monthly` güncellendi + `_PlaceholderScreen` silindi. `flutter test` **116/116 yeşil**, `flutter analyze` **0 issue**.
- **2026-06-04** — ✅ **Faz 10 KABUL**: Plan yazıldı (`2026-06-03-faz-10-ayarlar-bildirim-i18n.md`), `phase-10-settings` dalı. ARB TR/EN (8 string) + `sharedPreferencesProvider` + `AppSettings` modeli (TDD 3) + `nextInstanceOfTime` (TDD 3) + `NotificationService` üçlüsü (abstract/Local/Mock; flutter_local_notifications 21 **named-parametre** API'sine uyarlandı: `initialize(settings:)`, `zonedSchedule(id:/scheduledDate:/notificationDetails:)`) + `SettingsNotifier`/`localeProvider` orkestrasyonu (TDD 5) + Android **desugaring** (desugar_jdk_libs 2.1.4) & manifest izinleri/boot receiver + main/app kablolaması (prefs override, notif init, dil **anında** uygulanır, açılışta `bootstrapNotifications`) + `SettingsScreen` (dil/bildirim/çıkış, `RadioGroup`) + `/settings` + dashboard dişli ikonu (çıkış Ana ekrandan **Ayarlar'a taşındı**) + ölü `Role.displayName` (hardcoded TR) kaldırıldı + `widget_test.dart` override'ları güncellendi. `flutter test` **129/129 yeşil**, `flutter analyze` **0 issue**, `flutter build apk --debug` **başarılı**. Sıradaki: `phase-10-settings` → `main` (FF merge), sonra Faz 11.
- **2026-06-04** — ✅ **Faz 11 KABUL (MVP DoD)**: Plan yazıldı (`2026-06-04-faz-11-saglamlastirma-cila.md`), `phase-11-hardening` dalı. **(1) Hardcoded string denetimi:** 27 ekran l10n kullanıyor, literal'lerde TR yok; tek açık → 10 ham hata sitesi (`error.toString()`/`Text('$e')`) `l10n.genericError` (TR/EN) ile lokalize edildi. **(2) Erişilebilirlik (ui-ux-pro-max):** dokunma hedefleri 48dp + ikon-buton tooltip'leri zaten uyumlu (`compact`/`zero-padding` yalnızca etkileşimsiz Chip'lerde); 4 içerik metni (durum chip + veresiye tablosu) 14sp tabana çekildi; grafik eksen tick'leri (10-11sp) veri-görselleştirme istisnası olarak bırakıldı. **(3) Güvenlik kuralları:** `firestore.rules` auth-gated; canlı ruleset (Firebase MCP) yerel mantıkla birebir aynı, kimliksiz reddediliyor; tek-kullanıcı kapsamı yorumla belgelendi (§1.9, per-uid v2). **(4) README** gerçek proje belgesiyle değiştirildi + `docs/QA-checklist.md` (10 bölüm uçtan uca TR senaryo). `flutter test` **129/129 yeşil**, `flutter analyze` **0 issue**, `flutter build apk --debug` **başarılı**. **MVP v1.0 Definition of Done karşılandı.** Sıradaki: `phase-11-hardening` → `main` (FF merge).

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

---

## Faz 8 — Adımlar

- [x] T1: ARB TR/EN string'leri (12 yeni) + gen-l10n
- [x] T2: TipDistribution modeli (TDD, 3 test)
- [x] T3: TipDistributionRepository üçlüsü (abstract/Firestore/Mock)
- [x] T4: DailyRecordRepository.getByDateRange() + 3 Mock testi
- [x] T5: weekly_providers.dart (weekOffset/Notifier, currentWeekRange, weeklyRecords, openTips, staffDays, TipDistributionController)
- [x] T6: WeeklyBarChart widget (fl_chart, 7 bar)
- [x] T7: DailySummaryList widget (haftalık günlük liste)
- [x] T8: StaffDaysTable widget (ad, rol, gün)
- [x] T9: WeeklySummaryScreen + router /weekly güncelleme
- [x] T10: Widget testleri (4) + tam doğrulama (102 test, analyze temiz) + PROGRESS güncelleme

---

## Faz 9 — Adımlar

- [x] T1: ARB TR/EN string'leri (12 yeni) + gen-l10n
- [x] T2: MonthlyReport data class
- [x] T3: TDD MonthlyReportCalculator (5 test, §3.5)
- [x] T4: CreditSaleRepository.getByDateRange (abstract + Firestore + Mock)
- [x] T5: monthly_providers (offset/range/records/credits/wages/report) + 5 provider testi
- [x] T6: MonthlyBarChart widget (fl_chart, günlük ciro)
- [x] T7: MonthlyCreditTable widget
- [x] T8: SummaryCardsSection widget (8 kart)
- [x] T9: MonthlySummaryScreen + router /monthly
- [x] T10: Widget testleri (4) + tam doğrulama (116 test, analyze temiz) + PROGRESS güncelleme

---

## Faz 10 — Adımlar

- [x] T1: ARB TR/EN string'leri (8 yeni) + gen-l10n
- [x] T2: sharedPreferencesProvider (main override)
- [x] T3: AppSettings modeli + fromPrefs/copyWith (TDD, 3 test)
- [x] T4: nextInstanceOfTime saf yardımcı (TDD, 3 test)
- [x] T5: NotificationService üçlüsü (abstract/Local/Mock) — fln 21 named-param API
- [x] T6: SettingsNotifier + localeProvider orkestrasyon (TDD, 5 test)
- [x] T7: Android desugaring (desugar_jdk_libs 2.1.4) + manifest izinleri/boot receiver
- [x] T8: main.dart + app.dart kablolaması (prefs override, notif init, locale izleme, açılış bootstrap) + widget_test override güncellemesi
- [x] T9: SettingsScreen (dil/bildirim/çıkış, RadioGroup) + /settings rotası + dashboard dişli ikonu (2 widget test)
- [x] T10: Hardcoded string taraması — ölü Role.displayName kaldırıldı
- [x] T11: Tam doğrulama (129 test yeşil, analyze temiz, debug APK derlendi) + PROGRESS + merge

---

## Faz 11 — Adımlar

- [x] T0: `phase-11-hardening` dalı + temel doğrulama (129 test yeşil, analyze temiz)
- [x] T1: Hardcoded string denetimi (kanıt) + ARB `genericError` (TR/EN) + 10 ham hata sitesi `l10n.genericError` ile lokalize
- [x] T2: Erişilebilirlik denetimi (ui-ux-pro-max) — dokunma/tooltip uyumlu; 4 içerik metni 14sp tabana çekildi
- [x] T3: Güvenlik kuralları gözden geçirme + canlı ruleset doğrulama (Firebase MCP) + tek-kullanıcı yorumu
- [x] T4: Gerçek README + `docs/QA-checklist.md` (uçtan uca QA senaryoları)
- [x] T5: Final doğrulama (129 test, analyze temiz, debug APK) + PROGRESS + merge

---

## MVP v1.0 — Definition of Done (master plan §6)

- [x] Dahil özellikler Android'de çalışıyor: Login, Dashboard, Günlük Kayıt, Haftalık/Aylık Özet, Personel, Veresiye, Ödemeler, Ayarlar
- [x] TR + EN tam; yerel bildirim; hiçbir hardcoded string yok
- [x] `flutter test` (129) + `flutter analyze` temiz; çekirdek hesaplama servisleri TDD ile kapsanmış
- [x] Erişilebilirlik (font 14–18sp, dokunma 48dp, renk tek gösterge değil)
- [x] Onay/geri-alma kuralları (kaydet onayı, silme yok, "Ödendi" geri alınabilir, çıkış onayı)
- [ ] Manuel uçtan uca QA turu — `docs/QA-checklist.md` ile **Kemal cihazda** koşacak (insan doğrulaması)
