# Gilanlı Köy Meyhanesi — Master Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **Bu bir yol haritası (master plan) belgesidir.** Her faz (Phase) yürütülmeye başlanırken, `superpowers:writing-plans` ile o faza ait **tam kodlu, placeholder içermeyen ayrıntılı TDD planı** ayrıca yazılır. Bu belge mimariyi, dosya yapısını, kesişen kararları, faz sırasını ve her fazın kabul kriterlerini sabitler.
>
> **Onay güncellemesi (2026-06-02):** Günlük kasa formülü düzeltildi (patron masrafı günlük kasayı etkilemez), aylık Kâr/Zarar formülü netleşti (§3.5), bahşiş dağıtım mekanizması eklendi (§3.6, Faz 8). Ayrıntılar §1, §3, Faz 4/8/9'da.

**Goal:** Kemal için tek kullanıcılı, Türkçe/İngilizce, Firebase tabanlı bir Flutter mobil muhasebe uygulaması (Gilanlı Köy Meyhanesi) MVP v1.0 inşa etmek.

**Architecture:** Feature-first katmanlı mimari (`domain` / `data` / `application` / `presentation`). Riverpod ile state; Firestore'a yalnızca repository katmanı erişir (UI doğrudan erişmez). Tüm para işlemleri saf, unit-test edilebilir hesaplama servislerinde (`DailyRecordCalculator`, `WageResolver`, `PayrollCalculator`, `MonthlyReportCalculator`) toplanır. Tek kullanıcılı kurulur, mimari ileride çoklu kullanıcıya genişleyebilir.

**Tech Stack:** Flutter 3.38 / Dart 3.10 · Riverpod · Firebase (firebase_core, firebase_auth, cloud_firestore) · go_router · intl + flutter gen-l10n (TR/EN) · fl_chart · flutter_local_notifications + timezone · shared_preferences · equatable. Test: flutter_test, mocktail, fake_cloud_firestore.

---

## 0. Kapsam ve Karar Özeti (brainstorming + onay çıktısı)

| Konu | Karar |
|---|---|
| Backend | Firebase **sıfırdan** kurulur (proje + Auth e-posta/şifre + Firestore + Kemal hesabı). |
| Repository pattern | Her özellikte zorunlu. Her repo'nun `Firestore` impl'i + `mock` impl'i olur. |
| Para gösterimi | `1.000 ₺` — Türkçe biçim, yerel ayraç, tam lira. Dahili saklama `int`/kuruş. |
| Plan kurgusu | Temel önce + dikey dilimler, fazlar arası onay noktaları. |
| **Günlük kasa formülü** | `Ciro − Kredi Kartı + Bahşiş − Kasa Masrafı − Veresiye`. **Patron masrafı günlük kasayı etkilemez.** Toplam masraf gösteriminde kasa ve patron masrafı **ayrı** gösterilir. |
| **Bahşiş** | O gün dağıtıldıysa günlük kayıtta `0`; aksi halde kasada birikir. Haftalık **"Dağıtıldı, kapat"** ile kasadan düşülür ve sıfırlanır (§3.6). |
| **Aylık Kâr/Zarar** | `Ciro − Kredi Kartı − (Kasa+Patron Masrafı) − Personel Ücretleri − Tahsil Edilemeyen Veresiye` (**bahşiş hariç**) (§3.5). |

---

## 1. Onay Gerektiren Tasarım Kararları / Varsayımlar

Aşağıdakiler 2026-06-02'de onaylandı. Madde 7 onayla **güncellendi**.

1. **Platform hedefi = Android (öncelikli).** Geliştirme makinesi Windows 10. **iOS derlemesi macOS gerektirir → bu makinede kapsam dışı** (Mac/CI varsa eklenebilir). MVP Android üzerinde "done" sayılır. ✅
2. **Personel ücret tahakkuku türetilir.** "Çalışılan gün" ve "toplam ücret" tek kaynaktan — `dailyRecords.workingStaffIds` + `staff.wageHistory` — `PayrollCalculator` ile **hesaplanır**. `payments` (type=staff) yalnızca *yapılan ödemeleri* tutar; `kalan = tahakkuk − ödenen`. ✅
3. **Veresiye mutabakatı.** Günlük kayıttaki veresiye düzenlenince bağlı `creditSales` dokümanı güncellenir: `totalAmount` yenilenir, `remainingAmount = max(0, totalAmount − Σpayments)`, `status` yeniden hesaplanır. Veresiye sıfırlanırsa bağlı kayıt `paid`/0 olur (silme yok). ✅
4. **Ayarlar ekranı eklenir.** `features/settings` (dil, bildirim saati, bildirim aç/kapa, çıkış). ✅
5. **Bildirim (MVP).** `flutter_local_notifications` ile kullanıcı saatinde **günlük tekrarlı yerel hatırlatma**. "Kayıt zaten girildiyse gösterme" tam koşullu sürüm v2. ✅
6. **Auth.** Yalnızca login (e-posta/şifre); Kemal hesabı Faz 1'de Firebase konsolundan oluşturulur; uygulama içi kayıt ekranı yok. Oturum kalıcı. Çıkışta onay dialog'u. ✅
7. **Günlük kasa formülü (onay ile güncellendi).** `dailyCash = Ciro − Kredi Kartı + Bahşiş − Kasa Masrafı − Veresiye`. **Patron masrafı (`ownerExpenses`) günlük kasayı ETKİLEMEZ.** Toplam masraf gösteriminde kasa ve patron masrafı ayrı gösterilir. Aylık Kâr/Zarar ayrı formülle (§3.5) hesaplanır. ✅
8. *(Bilgi)* Modeller: düz immutable Dart sınıfları + `equatable` + `fromMap/toMap/copyWith`; `freezed`/`build_runner` kullanılmaz.
9. *(Bilgi)* Firestore güvenlik kuralları: tüm koleksiyonlar `request.auth != null` ile kilitli (tek kullanıcı). Per-uid kapsama v2.
10. *(Bilgi)* Firestore offline persistence mobilde varsayılan açık.

---

## 2. Dosya / Klasör Yapısı

Spec §2 genişletildi (feature-first + katmanlar). Her dosyanın tek sorumluluğu var.

```
lib/
├── main.dart                       # bootstrap: binding, Firebase.initializeApp, tz init, ProviderScope
├── firebase_options.dart           # flutterfire configure çıktısı (Faz 1)
├── app/
│   ├── app.dart                    # MaterialApp.router; theme; l10n delegates; locale provider'dan
│   └── router.dart                 # GoRouter + auth redirect guard
├── core/
│   ├── constants/app_constants.dart        # spacing, sizes, font 14–18sp, min touch 48dp, durations
│   ├── theme/app_theme.dart                # Material 3 ThemeData (erişilebilir text theme)
│   ├── money/
│   │   ├── money.dart                      # liraToKurus / kurusToLira yardımcıları (int kuruş)
│   │   └── currency_formatter.dart         # formatCurrency(int kurus, Locale) -> "1.000 ₺"
│   ├── extensions/currency_extension.dart  # int.toCurrency(locale) (spec adı korunur)
│   ├── utils/date_utils.dart               # weekRange / monthRange / isSameDay / dayKey
│   └── l10n/                               # ARB kaynakları
│       ├── app_tr.arb                      # template + varsayılan (TR)
│       └── app_en.arb
├── features/
│   ├── auth/         {data/, application/, presentation/login_screen.dart}
│   ├── staff/        {domain/(staff.dart, wage_resolver.dart), data/, application/, presentation/}
│   ├── daily_record/ {domain/(daily_record.dart, daily_record_calculator.dart), data/, application/, presentation/}
│   ├── credit_book/  {domain/credit_sale.dart, data/, application/, presentation/}
│   ├── payments/     {domain/(payment.dart, payroll_calculator.dart), data/, application/, presentation/}
│   ├── dashboard/    {application/, presentation/dashboard_screen.dart}
│   ├── weekly_summary/  {domain/(tip_distribution.dart), application/, presentation/}
│   ├── monthly_summary/ {domain/monthly_report_calculator.dart, application/, presentation/}
│   └── settings/     {application/settings_providers.dart, presentation/settings_screen.dart}
├── shared/
│   ├── widgets/      # confirm_dialog.dart, money_input_field.dart, app_scaffold.dart, async_value_widget.dart
│   └── providers/    # firebase_providers.dart (Firestore/Auth instance), repo wiring/overrides
test/
├── core/money/currency_formatter_test.dart
├── core/utils/date_utils_test.dart
├── features/daily_record/daily_record_calculator_test.dart
├── features/staff/wage_resolver_test.dart
├── features/payments/payroll_calculator_test.dart
├── features/monthly_summary/monthly_report_calculator_test.dart
├── features/credit_book/credit_reconcile_test.dart
└── features/**/widget tests (login, daily record live totals, confirm dialog, ...)
# kök: pubspec.yaml · l10n.yaml · analysis_options.yaml · firestore.rules · .gitignore
```

**Her repo katmanı** şu üçlüyü içerir: `xyz_repository.dart` (abstract arayüz), `firestore_xyz_repository.dart` (canlı impl), `mock_xyz_repository.dart` (bellek-içi; dev/test). UI ve provider'lar yalnızca abstract arayüze bağımlıdır.

---

## 3. Çekirdek Hesaplama Sözleşmeleri (TDD ile yazılır)

Tüm tutarlar **`int` kuruş** (1 ₺ = 100 kuruş). Saf fonksiyonlar; Firebase/Flutter bağımlılığı yok.

### 3.1 `DailyRecordCalculator` (Faz 0)
```
// Günlük kasayı YALNIZCA kasa masrafı etkiler; patron masrafı dahil DEĞİL.
int dailyCash({
  required int revenue,      // ciro (+)
  required int creditCard,   // kredi kartı (−)
  required int tips,         // bahşiş (+) — dağıtılana dek kasada birikir
  required int cashExpenses, // kasa masrafı (−)
  required int creditSales,  // veresiye (−)
}) => revenue - creditCard + tips - cashExpenses - creditSales;

int totalCash(int previousDayCash, int dailyCash)
    => previousDayCash + dailyCash;

// Gösterim amaçlı toplam masraf — dailyCash'i ETKİLEMEZ; iki kalem ayrı gösterilir:
int totalExpensesDisplay(int ownerExpenses, int cashExpenses)
    => ownerExpenses + cashExpenses;
```
> Bahşiş günlük kasaya eklenir ve **dağıtılana dek kasada birikir**. O gün dağıtıldıysa günlük kayıtta bahşiş `0` girilir. Haftalık dağıtım Faz 8'deki "Dağıtıldı, kapat" ile yapılır (§3.6).

Örnek test vakaları (kuruş) — `owner` günlük kasayı **etkilemez**:

| revenue | creditCard | tips | owner | cash | credit | prevDay | → dailyCash | → totalCash |
|---|---|---|---|---|---|---|---|---|
| 1.000.000 | 300.000 | 50.000 | 20.000 | 30.000 | 100.000 | 200.000 | 620.000 | 820.000 |
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 500.000 | 600.000 | 0 | 99.999 | 0 | 0 | 0 | −100.000 | −100.000 |

### 3.2 `WageResolver` (Faz 3)
```
int wageEffectiveOn(Staff staff, DateTime day)
```
`wageHistory` içinde `effectiveDate <= day` olan **en güncel** kaydın `dailyWage`'ını döndürür; yoksa `staff.dailyWage`. Test: zam öncesi gün eski ücreti, zam günü/sonrası yeni ücreti verir.

### 3.3 `PayrollCalculator` (Faz 6)
```
PayrollSummary accrue(Staff staff, List<DailyRecord> records, DateRange range)
// workedDays = range içindeki, workingStaffIds içeren kayıt sayısı
// accruedWage = Σ wageEffectiveOn(staff, record.date)
```
Test: ücret zammı aralığın ortasındaysa toplam, eski+yeni ücretlerin doğru toplamı olur.

### 3.4 Veresiye mutabakat yardımcısı (Faz 5)
```
CreditSale reconcile(CreditSale sale, {required int newTotal})
// remaining = max(0, newTotal - Σ payments); status yeniden hesaplanır
// status: payments boş & remaining==total -> pending; 0<remaining<total -> partial; remaining==0 -> paid
```

### 3.5 `MonthlyReportCalculator` (Faz 9)
```
// Aylık Kâr/Zarar — BAHŞİŞ HARİÇ.
int monthlyProfit({
  required int revenue,             // Σ ciro
  required int creditCard,          // Σ kredi kartı
  required int cashExpenses,        // Σ kasa masrafı
  required int ownerExpenses,       // Σ patron masrafı
  required int staffWages,          // Σ PayrollCalculator (tüm personel, ay)
  required int uncollectibleCredit, // tahsil edilemeyen veresiye
}) => revenue - creditCard - (cashExpenses + ownerExpenses) - staffWages - uncollectibleCredit;
```
> **Açık nokta (Faz 9'da netleştir):** "Tahsil edilemeyen veresiye" tanımı — varsayılan yorum: ilgili ay içindeki veresiyelerin `remainingAmount` (tahsil edilmemiş kalan) toplamı. Kemal "yalnızca batık/yazılan" derse ayrı bir `writtenOff` durumu eklenir.

### 3.6 Bahşiş dağıtımı (Faz 8)
- Bahşiş günlük kasada birikir. "Açık bahşiş" = son dağıtımdan bu yana girilen `tips` toplamı.
- Haftalık özet ekranındaki **"Dağıtıldı, kapat"** butonu: açık bahşiş toplamını kasadan düşen bir **dağıtım olayı** kaydeder ve açık bahşişi sıfırlar.
- Model eklemesi: `tipDistributions/{id}` (`date`, `amount`, `periodStart`, `periodEnd`) — kesin mekanik Faz 8 ayrıntılı planında.

---

## 4. Test Stratejisi

- **Saf domain (öncelik):** `money`, `date_utils`, `DailyRecordCalculator`, `WageResolver`, `PayrollCalculator`, `MonthlyReportCalculator`, veresiye `reconcile` → kapsamlı unit test, **TDD (red→green→refactor)**. CLAUDE.md'nin birincil test hedefi.
- **Repository:** Mock repo'lar dev/test için; Firestore impl'leri `fake_cloud_firestore` ile hafif testlenir.
- **Provider/controller:** `ProviderContainer` + mock repo override ile unit test.
- **Widget:** Kritik akışlar (login, günlük kayıt canlı toplamlar, onay dialog'u) için `ProviderScope` override'lı widget testleri.
- **Komutlar:** `flutter test`, `flutter analyze` (her faz sonunda yeşil olmalı).

---

## 5. Faz Planı (bağımlılık sırasına göre)

Her faz: tek başına derlenip test edilebilir bir artımdır. Faz sonunda `flutter analyze` temiz ve ilgili testler yeşil olmadan sonraki faza geçilmez (onay noktası).

### Faz 0 — Temel & Çekirdek
**Bağımlılık:** yok. **Çıktı:** çalışan, temalı uygulama iskeleti + yeşil çekirdek testler.
- [ ] `flutter create` ile iskelet (project-name `gilanli_meyhane`, android), gereksiz örnek kod temizliği
- [ ] `pubspec.yaml`: tüm bağımlılıklar; `flutter pub get`
- [ ] `analysis_options.yaml` (flutter_lints), `.gitignore`; `git init` + ilk commit (+ çalışma dalı)
- [ ] `l10n.yaml` + `app_tr.arb`/`app_en.arb` (tohum string'ler) + `flutter gen-l10n`; `flutter_localizations`
- [ ] `app_constants.dart`, `app_theme.dart` (M3, erişilebilir)
- [ ] **TDD:** `money.dart` (liraToKurus/kurusToLira) → test
- [ ] **TDD:** `currency_formatter.dart` + `currency_extension.dart` (`1.000 ₺`, TR/EN) → test
- [ ] **TDD:** `date_utils.dart` (week/month range) → test
- [ ] **TDD:** `daily_record_calculator.dart` (§3.1 vakaları, patron masrafı hariç) → test
- [ ] Tüm feature'lar için abstract repo arayüzleri (boş gövde) + `shared/providers/firebase_providers.dart` iskeleti
- [ ] `app.dart` + `router.dart` (placeholder rotalar) + `ProviderScope`; temalı placeholder ana ekran
- **Kabul:** `flutter test` yeşil (money, date, calculator); `flutter analyze` temiz; TR/EN altyapısı kurulu.

### Faz 1 — Firebase Kurulumu & Bağlama
**Bağımlılık:** Faz 0. **Çıktı:** uygulama canlı Firebase'e bağlı.
- [ ] `firebase login` *(KULLANICI)*
- [ ] Firebase projesi oluştur (CLI/konsol) *(KULLANICI kararı: bölge örn. eur3)*
- [ ] Auth → Email/Password etkinleştir *(KULLANICI, konsol)*
- [ ] Firestore veritabanı oluştur *(KULLANICI/ben)*
- [ ] `dart pub global activate flutterfire_cli`; `flutterfire configure` → `firebase_options.dart`
- [ ] `main.dart` içinde `Firebase.initializeApp`
- [ ] `firestore.rules` (auth-gated) yaz + `firebase deploy --only firestore:rules`
- [ ] Kemal'in kullanıcısını oluştur *(KULLANICI, konsol → Authentication → Add user)*
- [ ] `shared/providers/firebase_providers.dart`: FirebaseFirestore/FirebaseAuth instance provider'ları
- **Kabul:** Kimlikli okuma/yazma smoke testi çalışıyor; kurallar kimliksiz erişimi reddediyor.

### Faz 2 — Auth (Login)
**Bağımlılık:** Faz 1.
- [ ] `AuthRepository` (abstract) + `FirebaseAuthRepository` + `MockAuthRepository`
- [ ] `auth_providers.dart`: authState stream, repo provider, login/logout controller
- [ ] `login_screen.dart` (e-posta/şifre, hata gösterimi, yükleniyor durumu)
- [ ] `router.dart`: oturum yoksa `/login`'e yönlendiren guard
- [ ] Çıkış akışı + "Çıkış yapmak istediğinizden emin misiniz?" onay dialog'u
- [ ] Widget testi: hatalı giriş hata gösterir; başarılı giriş yönlendirir (mock repo)
- **Kabul:** Kemal giriş yapıp çıkabiliyor; oturum kalıcı; guard çalışıyor.

### Faz 3 — Personel (Staff)
**Bağımlılık:** Faz 2. (Günlük kayıt buna bağımlı.)
- [ ] `staff.dart` (model + `Role` enum + `WageHistoryEntry`, equatable, map dönüşümleri)
- [ ] **TDD:** `wage_resolver.dart` (§3.2)
- [ ] `StaffRepository` + Firestore + Mock impl
- [ ] `staff_providers.dart` (aktif personel listesi, ekle/düzenle/pasifle)
- [ ] `staff_list_screen.dart` + `staff_form.dart` (ad, rol dropdown, günlük ücret, aktif toggle)
- [ ] Ücret değişiminde `wageHistory`'ye `effectiveDate` ile ekleme
- [ ] Pasife alma (gizle, silme yok); silme yalnızca hiç kayıtta geçmeyen personelde
- [ ] Kaydet öncesi onay dialog'u
- **Kabul:** Personel CRUD (silme kısıtlı) çalışıyor; ücret geçmişi birikiyor; pasif personel günlük kayıtta görünmüyor.

### Faz 4 — Günlük Kayıt (Daily Record) — çekirdek özellik
**Bağımlılık:** Faz 3 + `DailyRecordCalculator`.
- [ ] `daily_record.dart` modeli
- [ ] `DailyRecordRepository` + Firestore + Mock impl
- [ ] `daily_record_providers.dart`: kaydetme orkestrasyonu (creditSales yazımı + personel tahakkuku tetikleme)
- [ ] `daily_record_screen.dart`: tüm girdi alanları (spec §4.3 tablosu), **iki ayrı masraf alanı** (kasa / patron)
- [ ] `live_totals_card.dart`: `DailyRecordCalculator` ile **canlı** toplam gösterimi (patron masrafı kasaya yansımaz, ayrı gösterilir)
- [ ] Bahşiş alanı: o gün dağıtıldıysa `0` girilir (Faz 8 haftalık dağıtımıyla ilişkili)
- [ ] `staff_multiselect.dart`: aktif personel çoklu seçim → `workingStaffIds`
- [ ] Veresiye girilince `creditSales`'e yazım + `linkedDailyRecordId`
- [ ] Düzenleme akışı + veresiye **mutabakatı** (§1.3) + kaydet onay dialog'u (silme yok)
- [ ] Widget testi: alanlar değişince canlı toplam doğru güncelleniyor
- **Kabul:** Günlük kayıt eklenip düzenlenebiliyor; toplamlar doğru (patron masrafı kasayı etkilemiyor); veresiye ve personel tahakkuku ilgili koleksiyonlara yansıyor.

### Faz 5 — Veresiye Defteri (Credit Book)
**Bağımlılık:** Faz 4.
- [ ] `credit_sale.dart` modeli + status enum + **TDD** `reconcile` (§3.4)
- [ ] `CreditSaleRepository` + Firestore + Mock
- [ ] `credit_list_screen.dart` (müşteri, toplam, kalan, durum) + düzenleme
- [ ] Manuel veresiye ekleme (`credit_form.dart`)
- [ ] `payment_dialog.dart`: kısmi ödeme (remaining güncelle, payments[]'e ekle, status=partial)
- [ ] Tam ödeme ("Ödendi", status=paid) + **geri alma** butonu
- **Kabul:** Liste/ekleme/kısmi-tam ödeme/geri alma/düzenleme çalışıyor; durum geçişleri doğru.

### Faz 6 — Ödemeler (Payments)
**Bağımlılık:** Faz 4 (tahakkuk dailyRecords'tan türetilir).
- [ ] `payment.dart` modeli + **TDD** `payroll_calculator.dart` (§3.3)
- [ ] `PaymentRepository` + Firestore + Mock
- [ ] `payments_screen.dart` iki sekme
- [ ] `staff_payments_tab.dart`: `[Ad|Çalışılan Gün|Toplam Ücret|Ödenen|Kalan]` (türetilmiş) + kısmi ödeme
- [ ] `pending_expenses_tab.dart`: manuel gider ekleme (type=expense) + kısmi ödeme
- **Kabul:** Personel tahakkuku doğru hesaplanıyor (wageHistory dahil); kısmi ödemeler her iki sekmede çalışıyor.

### Faz 7 — Dashboard
**Bağımlılık:** Faz 4.
- [ ] `dashboard_providers.dart` (bugünün özeti)
- [ ] `dashboard_screen.dart`: tarih + "Merhabalar Kemal Bey", hızlı erişim kartları (Günlük/Haftalık/Aylık), bugünün kısa özeti (günlük kasa, çalışan sayısı)
- **Kabul:** Kartlar doğru rotalara gidiyor; bugünün özeti (varsa) görünüyor.

### Faz 8 — Haftalık Özet
**Bağımlılık:** Faz 4.
- [ ] `weekly_providers.dart` (hafta aralığı verisi)
- [ ] `weekly_bar_chart.dart` (fl_chart günlük ciro), günlük özet listesi, `staff_days_table.dart`
- [ ] Hafta gezinme `<` `>`; güne tıklayınca detay
- [ ] **"Dağıtıldı, kapat"** butonu: açık bahşişi kasadan düş + sıfırla (`tipDistributions` kaydı) — §3.6
- **Kabul:** Grafik+liste+personel tablosu doğru; gezinme ve detay-geçiş çalışıyor; bahşiş dağıtımı kasayı doğru günceller.

### Faz 9 — Aylık Özet
**Bağımlılık:** Faz 4–6.
- [ ] `monthly_providers.dart`
- [ ] **TDD** `monthly_report_calculator.dart` (§3.5)
- [ ] `summary_cards.dart`: Toplam Ciro, Kredi Kartı, **Kasa Masrafı** ve **Patron Masrafı** (ayrı), Personel Ücretleri, Veresiye (toplam + tahsil edilemeyen), **Kâr/Zarar** (§3.5, bahşiş hariç)
- [ ] Günlük + haftalık ciro bar grafikleri; veresiye tablosu; ay gezinme
- **Kabul:** Kartlar ve grafikler doğru toplamları gösteriyor; Kâr/Zarar §3.5 ile birebir.

### Faz 10 — Ayarlar, Bildirim, i18n tamamlama
**Bağımlılık:** Faz 2+.
- [ ] `settings_providers.dart`: `localeProvider`, `notificationTimeProvider`, enable toggle (shared_preferences kalıcı)
- [ ] `settings_screen.dart`: dil seçimi (**yeniden başlatmadan** uygulanır), bildirim saati picker, aç/kapa, çıkış
- [ ] `flutter_local_notifications` + `timezone`: kullanıcı saatinde günlük tekrarlı hatırlatma
- [ ] **ARB taraması:** hiçbir TR/EN string hardcode kalmasın; EN paritesi
- **Kabul:** Dil anında değişiyor; bildirim kullanıcı saatinde geliyor; hardcoded string yok.

### Faz 11 — Sağlamlaştırma & Cila
**Bağımlılık:** tüm fazlar.
- [ ] Hardcoded string denetimi (otomatik tarama)
- [ ] **Erişilebilirlik denetimi** (`ui-ux-pro-max`): font 14–18sp, dokunma 48×48dp, kontrast
- [ ] Güvenlik kuralları gözden geçirme
- [ ] Manuel QA turu (uçtan uca senaryolar) + `README` / çalıştırma notları
- **Kabul:** MVP "Definition of Done" karşılanıyor.

---

## 6. MVP "Definition of Done"

- Spec §7'deki tüm dahil özellikler Android'de çalışıyor: Login, Dashboard, Günlük Kayıt, Haftalık/Aylık Özet, Personel, Veresiye, Ödemeler, Ayarlar.
- TR + EN tam; yerel bildirim çalışıyor; hiçbir hardcoded string yok.
- `flutter test` ve `flutter analyze` temiz; çekirdek hesaplama servisleri TDD ile kapsanmış.
- Erişilebilirlik hedefleri (font/dokunma/kontrast) karşılanmış.
- Onay/geri-alma kuralları uygulanmış (kaydet onayı, silme yok, "Ödendi" geri alınabilir, çıkış onayı).

---

## 7. Riskler / Açık Noktalar

- **iOS:** Windows'ta derlenemez → Android-öncelikli (onay #1).
- **Bildirim arka-plan koşulu:** "kayıt girildiyse gösterme" tam sürümü v2 (onay #5).
- **"Tahsil edilemeyen veresiye" tanımı:** Faz 9'da netleştirilecek (§3.5 notu).
- **Firebase ücretsiz katman:** tek kullanıcı için Spark planı yeterli; faturalama gerekmez.
```