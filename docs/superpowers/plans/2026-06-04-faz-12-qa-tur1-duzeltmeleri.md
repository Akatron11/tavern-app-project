# Faz 12 — QA Tur 1 Düzeltmeleri Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans + superpowers:systematic-debugging (her bug için: kök neden → reprodüksiyon testi → düzeltme → doğrulama). Saf mantık değişikliklerinde superpowers:test-driven-development. Checkbox (`- [ ]`) ile takip.
>
> **DURUM (2026-06-04):** Tier 1, 2, 3.1 ✅ TAMAM (BUG-09/01/04/07/15/02/03/10/11 — 9 madde, `phase-12-qa-fixes` dalında commit'li, 139 test yeşil). **Kalan:** Tier 3.2 → Tier 5. Güncel durum + sıradaki adımlar: **PROGRESS.md → "KALDIĞIMIZ YER" bölümü.**

**Goal:** QA Tur 1 raporundaki ([docs/bugreport-qa-round1.md](../../bugreport-qa-round1.md)) 16 bug + 2 yeni özellik + 2 iyileştirmeyi öncelik sırasıyla çözmek; her biri test + analyze yeşil bırakarak.

**Architecture:** Mevcut feature-first + repository + saf hesaplama + Riverpod mimarisi korunur. Bug'lar kümelere ayrılır; paylaşılan kök nedenler birlikte düzeltilir. Saf fonksiyon değişiklikleri (BUG-09) TDD ile; UI/lifecycle bug'ları (BUG-04) reprodüksiyon widget testiyle.

**Tech Stack:** Flutter · Riverpod · Firestore (repo) · intl/ARB · flutter_local_notifications. Test: flutter_test, mocktail, fake_cloud_firestore.

**Onaylanan kapsam kararları (2026-06-04):**
- **BUG-09:** Kâr/Zarar formülünden `creditCard` çıkarılır (kredi kartı ciroya dahil; çifte kesinti). Master plan §3.5/§0 güncellenir.
- **YENİ-01/02:** `status==paid` veresiye **ve** gider kayıtları onay dialog'uyla **silinebilir** ("silme yok" ilkesi yalnızca bu durumda gevşetilir).
- **BUG-11:** "Toplam Veresiye" kartı → **"Tahsil Bekleyen Veresiye"** (yalnızca pending+partial `remainingAmount` toplamı) + reaktivite.
- **BUG-16:** Pragmatik — günlük kayıt kaydedilince bugünkü hatırlatma iptal + ertesi güne yeniden planlanır.

**Yürütme kuralı:** Her kademe (Tier) sonunda `flutter test` + `flutter analyze` yeşil; mantıklı commit'ler; kademe başına doğrulama checkpoint'i. Her bug'da **önce başarısız test** (reprodüksiyon/TDD), sonra düzeltme.

---

## Tier 1 — 🔴 Kritik (veri bütünlüğü)

### T1.1 — BUG-09: Kâr/Zarar formülü (kredi kartı çıkar) — TDD
**Files:** `lib/features/monthly_summary/domain/monthly_report_calculator.dart` · `test/features/monthly_summary/monthly_report_calculator_test.dart` · `lib/features/monthly_summary/application/monthly_providers.dart` (çağrı) · `docs/superpowers/plans/2026-06-02-gilanli-meyhane-master-plan.md` (§3.5/§0)
- [ ] Testleri güncelle: `monthlyProfit` artık `revenue - (cashExpenses + ownerExpenses) - staffWages - uncollectibleCredit`. `creditCard` parametresi kaldırılır. Mevcut 5 test beklenen değerleri yeni formüle göre düzelt (kırmızı).
- [ ] `monthlyProfit` imzasından `creditCard`'ı çıkar; gövdeden `- creditCard` sil. (Kredi kartı **özet kartı olarak gösterilmeye** devam eder — yalnızca kârdan düşülmez.)
- [ ] `monthly_providers` çağrısını güncelle (creditCard argümanı kaldır).
- [ ] Master plan §3.5 + §0 tablosunu yeni formülle güncelle (not: "2026-06-04 QA düzeltmesi" ibaresi).
- **Kabul:** Güncellenen testler yeşil; Aylık Özet'te Kredi Kartı kartı görünür ama Kâr/Zarar'a etki etmez.

### T1.2 — BUG-01: Veresiye düzenlemede yanlış "ödendi" — kök neden + test
**Files:** `lib/features/daily_record/application/daily_record_providers.dart` (saveRecord) · `lib/features/credit_book/domain/credit_reconciler.dart` · `lib/features/credit_book/data/*credit_sale_repository*` · `test/features/daily_record/*` veya yeni `test/features/credit_book/*`
- [ ] **Reprodüksiyon testi:** Günlük kayıt veresiye ile oluştur → aynı kaydı **tutarı değiştirerek** düzenle → bağlı `CreditSale` `status` yanlış `paid` oluyor mu? (kırmızı beklenir).
- [ ] Kök neden: `saveRecord` düzenleme akışında reconcile, `Σpayments` yerine sıfırdan/yanlış hesaplıyor olabilir — `CreditReconciler.reconcile(sale, newTotal:)` `remaining = max(0, newTotal − Σpayments)` doğru mu, çağrı doğru sale ile mi yapılıyor doğrula.
- [ ] Düzeltme: reconcile çağrısını doğru ödemeler/tutar ile yap; ödeme yokken `newTotal` değişince `status=pending` (paid değil).
- **Kabul:** Düzenlemede tutar değişince status doğru (pending/partial), yanlış "ödendi" yok; test yeşil.

**Checkpoint:** `flutter test` + `flutter analyze` yeşil → commit `fix(monthly,daily): BUG-09 kâr formülü + BUG-01 veresiye mutabakatı`.

---

## Tier 2 — 🟠 Yüksek (temel akış)

### T2.1 — BUG-04 + BUG-07: Veresiye ödeme dialog'u (çökme + taşma)
**Files:** `lib/features/credit_book/presentation/widgets/payment_dialog.dart` · yeni `test/features/credit_book/payment_dialog_test.dart`
- [ ] **Reprodüksiyon testi:** dialog aç → onayla/iptal et → `tester.takeException()` null olmalı (şu an `_dependents.isEmpty` assertion ile kırmızı).
- [ ] Kök neden (hipotez doğrulanır): `await showDialog` sonrası `ctrl.dispose()` route teardown sırasında çalışıyor. Düzeltme: dialog içeriğini controller'ı `initState`/`dispose`'ta yöneten küçük bir `StatefulWidget`'e taşı (veya `MoneyInputField` + StatefulWidget) — dispose route tam unmount olunca.
- [ ] BUG-07: validator hata metni (`paymentAmountExceedsRemaining`) taşmasın — `AlertDialog` içeriği yeterli genişlik/`isDense`/wrap.
- **Kabul:** Onay ve iptalde hata ekranı yok; fazla ödeme mesajı tam okunur; test yeşil. (Sızıntıyı önlemek için personel/gider dialog'larına da aynı StatefulWidget deseni uygulanabilir — DRY.)

### T2.2 — BUG-02: Günlük kayıt zorunlu alan validasyonu
**Files:** `lib/features/daily_record/presentation/daily_record_screen.dart` · `lib/shared/widgets/money_input_field.dart` (validator desteği) · `test/features/daily_record/daily_record_screen_test.dart`
- [ ] **Test:** 5 alan (ciro, kredi kartı, patron masrafı, kasa masrafı, dünden kalan kasa) boşken kaydet → onay dialog'u açılmamalı/validasyon hatası (kırmızı). Ciro `0` girilebilir ama boş geçilemez.
- [ ] Düzeltme: bu alanlara `validator` ekle (boş → hata); `_save` öncesi `_formKey.currentState!.validate()` kontrolü. "0 geçerli ama boş değil" mantığı.
- **Kabul:** Boş zorunlu alanla kayıt engellenir; `0` kabul edilir; test yeşil.

### T2.3 — BUG-15: MoneyInputField binlik ayraç (canlı format)
**Files:** `lib/shared/widgets/money_input_field.dart` · yeni `test/shared/money_input_field_test.dart`
- [ ] **Test:** `6000` yazılınca alanda `6.000` (TR) görünür; `kurusOf` doğru kuruş döner (600000).
- [ ] Düzeltme: `TextInputFormatter` ile canlı binlik gruplama (TR ayraç). `kurusOf` ayraçları temizleyip parse etmeli. Tüm `MoneyInputField` kullananları etkiler (tutarlı).
- **Kabul:** Giriş binlik ayraçla formatlanır; kuruş değeri doğru; mevcut testler yeşil.

**Checkpoint:** test + analyze yeşil → commit `fix(payments,daily,shared): BUG-04/07 dialog + BUG-02 validasyon + BUG-15 para formatı`.

---

## Tier 3 — 🟡 Orta (reaktivite, tarih, bildirim, silme)

### T3.1 — BUG-03 + BUG-10 + BUG-11: Reaktivite & "Tahsil Bekleyen Veresiye"
**Files:** `lib/features/dashboard/application/dashboard_providers.dart` · `lib/features/monthly_summary/application/monthly_providers.dart` · `lib/features/daily_record/application/daily_record_providers.dart` (save sonrası invalidate) · `lib/features/credit_book/application/credit_book_providers.dart` · `lib/features/monthly_summary/presentation/widgets/summary_cards_section.dart` · ARB (kart adı)
- [ ] **BUG-03:** Günlük kayıt save sonrası `ref.invalidate(todayRecordProvider)` (ve ilgili). Test: save sonrası dashboard provider yeniden okunur.
- [ ] **BUG-10:** Aylık özet provider'ları veresiye değişiminde güncellensin — `creditBookController` yazımları sonrası ilgili provider invalidate / `watch` zinciri kurulu.
- [ ] **BUG-11:** Yeni provider/hesap: pending+partial `remainingAmount` toplamı; kart etiketi `monthlyOutstandingCredit` ("Tahsil Bekleyen Veresiye" / "Outstanding Credit"). ARB TR/EN + gen-l10n.
- **Kabul:** Kayıt/ödeme sonrası dashboard ve aylık özet **yeniden başlatmadan** güncellenir; kart yalnızca tahsil bekleyeni gösterir.

### T3.2 — BUG-08: Gider düzenlemede "kalan" yeniden hesap
**Files:** `lib/features/payments/application/payments_providers.dart` (gider güncelle) · `lib/features/payments/domain/pending_expense.dart` · test
- [ ] **Test:** gider toplamı düzenlenince `remainingAmount = totalAmount − paidAmount` anında güncellenir (kırmızı).
- [ ] Düzeltme: gider update akışında remaining/status yeniden hesapla (BUG-01 ile aynı sınıf).
- **Kabul:** Tutar düzenlemede kalan anında doğru; test yeşil.

### T3.3 — BUG-05 + BUG-06: Veresiye tarihleri
**Files:** `lib/features/credit_book/presentation/credit_form.dart` (DatePicker) · `lib/features/credit_book/presentation/widgets/credit_sale_tile.dart` (tarih göster) · `daily_record_providers` (creditSales.date dolu) · test
- [ ] **BUG-05:** Günlük kayıttan oluşan `CreditSale.date` dolu olmalı (kayıt tarihi) + listede tarih görünür.
- [ ] **BUG-06:** Manuel veresiye formuna DatePicker (varsayılan bugün).
- **Kabul:** Tüm veresiyelerde tarih var ve listede görünür; manuel eklemede tarih seçilebilir.

### T3.4 — BUG-16: Kayıt varsa bildirimi bastır (pragmatik)
**Files:** `lib/features/settings/...notification_service*` · `lib/features/daily_record/application/daily_record_providers.dart` (save sonrası) · `lib/features/settings/application/settings_providers.dart` · test (mock notification)
- [ ] Günlük kayıt kaydedilince: bugünkü planlı hatırlatmayı iptal et + ertesi gün için yeniden planla.
- **Kabul:** Bugün kayıt girildiyse o gün bildirim gelmez; ertesi gün normal planlı; test (mock) yeşil.

### T3.5 — YENİ-01 + YENİ-02: "Ödendi" kayıt silme
**Files:** credit: `credit_book_providers.dart` (+repo delete) · `credit_list_screen.dart` (BottomSheet'e Sil) · expense: `payments_providers.dart` (+repo delete) · `pending_expenses_tab.dart` · `confirm_dialog` · test
- [ ] Repo'lara `delete(id)` (abstract/Firestore/Mock). Yalnızca `status==paid` için UI'da "Sil" + onay dialog'u.
- [ ] **Test:** paid kayıt silinir; pending/partial'da silme seçeneği görünmez.
- **Kabul:** Ödendi veresiye/gider onayla silinir; diğer durumlar korunur; test yeşil.

**Checkpoint:** test + analyze yeşil → commit(ler) küme bazında.

---

## Tier 4 — 🟢 Düşük (kozmetik / UX)

### T4.1 — BUG-12: Haftalık liste tam ay adı
**Files:** `lib/features/weekly_summary/presentation/widgets/daily_summary_list.dart`
- [ ] `DateFormat` desenini `MMM` → `MMMM` ("1 Haziran, Pazartesi"). **Kabul:** tam ay adı görünür.

### T4.2 — BUG-13: Personel günleri tablo taşması
**Files:** `lib/features/weekly_summary/presentation/widgets/staff_days_table.dart`
- [ ] Günleri tek satırda virgülle / kompakt chip; taşmada `Wrap`/`Expanded`/"+N". **Kabul:** taşma yok, düzenli.

### T4.3 — BUG-14: "Bu günün" yazım hatası
**Files:** ARB (`app_tr.arb`) — önce `rg "[Bb]u günün"` ile gerçek konumu bul.
- [ ] Bulunursa "bugünün" yap + gen-l10n. (Mevcut `todaySummary`="Bugünün Özeti" zaten doğru görünüyor; gerçek string bulunamazsa kullanıcıya doğrula.) **Kabul:** yanlış yazım yok.

### T4.4 — İYİ-01: Dashboard kartı → günün cirosu
**Files:** `lib/features/dashboard/presentation/widgets/today_summary_card.dart` · ARB
- [ ] Çalışan personel sayısı yerine **günün cirosu**; Günlük Kasa üstte, Ciro altında. **Kabul:** kart ciro gösterir.

### T4.5 — İYİ-02: Şifre göster/gizle
**Files:** `lib/features/auth/presentation/login_screen.dart`
- [ ] Şifre alanına `obscureText` toggle (göz ikonu, suffixIcon). **Kabul:** şifre görünürlüğü değiştirilebilir.

**Checkpoint:** test + analyze yeşil → commit `fix(ui): BUG-12/13/14 + İYİ-01/02`.

---

## Tier 5 — Kapanış

### T5.1 — Final doğrulama + PROGRESS + merge
- [ ] `flutter test` + `flutter analyze` + `flutter build apk --debug`.
- [ ] `superpowers:verification-before-completion`.
- [ ] `PROGRESS.md` Faz 12 notu + bug rapor durumları (çözüldü işaretleri); `bugreport-qa-round1.md` özet tablosuna durum sütunu.
- [ ] `superpowers:finishing-a-development-branch` → `phase-12-qa-fixes` → `main`.

---

## Self-Review

**Kapsam (rapordaki 20 madde):** BUG-01→T1.2 · BUG-02→T2.2 · BUG-03→T3.1 · BUG-04→T2.1 · BUG-05→T3.3 · BUG-06→T3.3 · BUG-07→T2.1 · BUG-08→T3.2 · BUG-09→T1.1 · BUG-10→T3.1 · BUG-11→T3.1 · BUG-12→T4.1 · BUG-13→T4.2 · BUG-14→T4.3 · BUG-15→T2.3 · BUG-16→T3.4 · YENİ-01→T3.5 · YENİ-02→T3.5 · İYİ-01→T4.4 · İYİ-02→T4.5. **Tümü kapsanıyor ✅.**

**Yöntem dürüstlüğü:** Her bug, kesin düzeltme kodu yerine **systematic-debugging** (reprodüksiyon/TDD → kök neden → minimal düzeltme → doğrulama) ile yürütülür; bu plan sıralama, dosya hedefleri ve kabul ölçütlerini sabitler. BUG-09 (saf formül) net; BUG-14 konumu yürütmede doğrulanır.
