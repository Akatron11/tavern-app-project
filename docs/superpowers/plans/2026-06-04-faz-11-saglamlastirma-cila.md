# Faz 11 — Sağlamlaştırma & Cila Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** MVP v1.0'ı "Definition of Done"a getirmek — hardcoded string yok, erişilebilirlik hedefleri karşılanmış, güvenlik kuralları gözden geçirilmiş/doğrulanmış, gerçek README + uçtan uca QA senaryoları yazılmış, tüm otomatik doğrulama yeşil.

**Architecture:** Bu bir cila fazıdır; yeni özellik yok. Üç tür iş: (1) kod-düzeyi denetim + küçük UX cilası (ham hata gösterimini lokalize et), (2) erişilebilirlik denetimi (`ui-ux-pro-max`) + düzeltmeler, (3) belge (README, QA listesi) + güvenlik kuralı doğrulama. Mevcut feature-first mimari ve l10n altyapısı korunur.

**Tech Stack:** Flutter / Dart · flutter gen-l10n (TR/EN ARB) · Firebase Firestore rules · ui-ux-pro-max skill · flutter test / analyze / build apk.

**Keşif bulguları (2026-06-04, plan öncesi):**
- 27 presentation dosyasının tümü `AppLocalizations.of(context)` / `l10n.xxx` kullanıyor.
- String literali içinde TR özel karakteri **yok**; `Text('...')` literalleri yalnızca dinamik (`'$e'`, sayı) veya sembol (`'—'`, `'₺'`).
- **Tek UX açığı:** 9 noktada ham hata gösterimi (`Text('$e')` / `error.toString()`) — Kemal'e çiğ Dart istisnası gösteriyor. Lokalize genel hata mesajıyla değiştirilecek.
- `firestore.rules`: auth-gated catch-all (`allow read, write: if request.auth != null`) — master plan §1.9 kararıyla uyumlu (tek kullanıcı; per-uid v2).
- `README.md`: varsayılan Flutter şablonu — gerçek README ile değiştirilecek.
- Erişilebilirlik sabitleri (`AppSizes`: minFont 14, maxFont 18, minTouch 48) + tema (`MaterialTapTargetSize.padded`, erişilebilir textTheme) mevcut — gerçek kullanım denetlenecek.

---

## File Structure

| Dosya | Sorumluluk | İşlem |
|---|---|---|
| `lib/core/l10n/app_tr.arb` / `app_en.arb` | `genericError` anahtarı | Modify |
| 7 presentation dosyası (aşağıda) | Ham hata yerine `l10n.genericError` | Modify |
| `lib/**` presentation | Erişilebilirlik düzeltmeleri (bulgulara göre) | Modify (gerekirse) |
| `firestore.rules` | Tek-kullanıcı kapsamını açıklayan yorum | Modify |
| `README.md` | Gerçek proje README'si | Rewrite |
| `docs/QA-checklist.md` | Uçtan uca manuel QA senaryoları (TR) | Create |
| `PROGRESS.md` | Faz 11 kapanışı | Modify |

---

## Task 0: Dal + temel doğrulama

**Files:** yok (git + doğrulama)

- [ ] **Step 1: `phase-11-hardening` dalını aç**

Run: `git checkout -b phase-11-hardening`
Expected: `Switched to a new branch 'phase-11-hardening'`

- [ ] **Step 2: Temel testleri çalıştır (başlangıç yeşil mi?)**

Run: `flutter test`
Expected: `All tests passed!` (129 test)

- [ ] **Step 3: Temel analiz**

Run: `flutter analyze`
Expected: `No issues found!`

> Temel yeşil değilse DUR ve bildir — cilaya başlamadan önce taban temiz olmalı.

---

## Task 1: Hardcoded string denetimi + ham hata gösterimini lokalize et

**Files:**
- Modify: `lib/core/l10n/app_tr.arb`, `lib/core/l10n/app_en.arb`
- Modify: `lib/features/dashboard/presentation/widgets/today_summary_card.dart:22`
- Modify: `lib/features/weekly_summary/presentation/weekly_summary_screen.dart` (64, 80, 97, 111)
- Modify: `lib/features/monthly_summary/presentation/monthly_summary_screen.dart` (60, 74, 96)
- Modify: `lib/features/daily_record/presentation/daily_record_screen.dart:130`
- Modify: `lib/features/staff/presentation/staff_form_screen.dart:91`

- [ ] **Step 1: Hardcoded string son taraması (kanıt)**

Run: `rg -n "(['\"])[^'\"]*[şğıçöüŞĞİÇÖÜ][^'\"]*\1" lib --glob '!**/generated/**'`
Expected: eşleşme yok (hiçbir TR string literali yok).

Run: `rg -n "Text\(\s*['\"]" lib --glob '!**/generated/**'`
Expected: yalnızca dinamik/sembol literalleri (`'$e'`, `'$d'`, `'—'`, sayı interpolasyonu). Yeni gerçek-metin literali çıkarsa ARB'ye taşı.

- [ ] **Step 2: ARB'ye `genericError` anahtarını ekle**

`app_tr.arb` (mevcut anahtarların yanına, son `}` öncesi):
```json
  "genericError": "Bir hata oluştu",
  "@genericError": {
    "description": "Beklenmeyen bir hata olduğunda gösterilen genel mesaj"
  }
```
`app_en.arb`:
```json
  "genericError": "An error occurred",
  "@genericError": {
    "description": "Generic message shown when an unexpected error occurs"
  }
```

- [ ] **Step 3: gen-l10n çalıştır**

Run: `flutter gen-l10n`
Expected: hatasız; `app_localizations*.dart` yeniden üretilir, `genericError` getter'ı eklenir.

- [ ] **Step 4: AsyncValue error builder'larını değiştir**

`today_summary_card.dart`, `weekly_summary_screen.dart`, `monthly_summary_screen.dart` içinde her `error: (e, _) => Text('$e')` →
```dart
error: (e, _) => Text(l10n.genericError),
```
(İlgili build metodunda `l10n` zaten tanımlı; değilse `AppLocalizations.of(context)` ile al.)

`daily_record_screen.dart:130` ve `staff_form_screen.dart:91` içindeki
`SnackBar(content: Text(next.error.toString()))` →
```dart
SnackBar(content: Text(l10n.genericError)),
```

- [ ] **Step 5: Doğrula**

Run: `rg -n "error.toString\(\)|Text\('\\\$e'\)" lib --glob '!**/generated/**'`
Expected: eşleşme yok (tüm ham hata gösterimleri lokalize edildi).

Run: `flutter analyze`
Expected: `No issues found!`

Run: `flutter test`
Expected: `All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/core/l10n/ lib/features/
git commit -m "polish(i18n): ham hata gösterimini l10n.genericError ile lokalize et"
```

---

## Task 2: Erişilebilirlik denetimi (ui-ux-pro-max)

**Files:** Bulgulara göre presentation dosyaları (önceden bilinmiyor — denetim çıktısı belirler).

- [ ] **Step 1: ui-ux-pro-max skill'ini çağır**

`Skill` tool ile `ui-ux-pro-max:ui-ux-pro-max` (action: review/check, stack: flutter). Hedef: font 14–18sp, dokunma 48×48dp, kontrast.

- [ ] **Step 2: Denetim kontrol listesi (her presentation ekranı için)**

Şunları ara:
- **Dokunma hedefi < 48dp:** `IconButton` özel küçük `constraints`/`padding`; `InkWell`/`GestureDetector` ile sarılı küçük widget'lar; `visualDensity: VisualDensity.compact` ile küçülen aksiyonlar. Düzeltme: `IconButton`'da varsayılan 48dp'yi koru veya `SizedBox(width/height: AppSizes.minTouchTarget)` ile sar.
- **Font < 14sp:** Açık `fontSize:` < 14 veya `bodySmall` altı stiller. Düzeltme: en az `AppSizes.minFontSize`.
- **İkon-only buton erişilebilirlik etiketi yok:** Etiketsiz `IconButton`/`InkWell`. Düzeltme: `tooltip:` (lokalize) veya `Semantics(label: ...)`.
- **Kontrast:** Renkli chip/kart üstündeki metin (örn. durum chip'leri, `Colors.green/red` üstü beyaz). Düzeltme: M3 `colorScheme` rolleri (`onPrimaryContainer` vb.) kullan.

Run (ön tarama): `rg -n "fontSize:\s*([0-9]|1[0-3])\b" lib --glob '!**/generated/**'`
Expected: 14 altı açık fontSize yok (varsa düzelt).

Run (ön tarama): `rg -n "IconButton|VisualDensity|constraints:" lib --glob '!**/generated/**'`
İncele: özel küçültme var mı.

- [ ] **Step 3: Bulunan sorunları düzelt**

Her bulgu için minimal, hedefli düzeltme uygula (yukarıdaki kalıplar). Sorun bulunmazsa bunu kanıtla ve geç (YAGNI — yapay değişiklik ekleme).

- [ ] **Step 4: Doğrula**

Run: `flutter analyze`
Expected: `No issues found!`

Run: `flutter test`
Expected: `All tests passed!`

- [ ] **Step 5: Commit (değişiklik varsa)**

```bash
git add lib/
git commit -m "polish(a11y): dokunma hedefi/font/kontrast düzeltmeleri (ui-ux-pro-max)"
```
> Değişiklik yoksa commit atma; bulguları doğrulama notu olarak PROGRESS'e yaz.

---

## Task 3: Güvenlik kuralları gözden geçirme + doğrulama

**Files:**
- Modify: `firestore.rules` (açıklayıcı yorum)

- [ ] **Step 1: Yerel kuralları gözden geçir**

`firestore.rules` auth-gated catch-all. Master plan §1.9 ile uyumlu (tek kullanıcı). Karar: per-uid kapsam v2. Kuralın başına açıklayıcı yorum ekle:
```
rules_version = '2';
// Tek kullanıcılı MVP (Kemal). Tüm koleksiyonlar kimlik doğrulaması ile kilitli.
// Per-uid kapsam ve şema doğrulaması v2'ye ertelendi (master plan §1.9).
service cloud.firestore {
```

- [ ] **Step 2: Deploy edilmiş kuralların yerelle eşleştiğini doğrula (Firebase MCP)**

`mcp__plugin_firebase_firebase__firebase_get_security_rules` (service: firestore) ile canlı kuralı çek; yereldeki `allow read, write: if request.auth != null` ile birebir aynı olduğunu doğrula. Farklıysa `firebase deploy --only firestore:rules`.

- [ ] **Step 3: Kimliksiz erişimin reddedildiğini teyit et**

Kural mantığı: `request.auth != null` → kimliksiz `read/write` reddedilir. (PROGRESS Faz 1 notunda canlı deploy + kimliksiz ret zaten doğrulanmış; burada kuralın değişmediğini teyit et.)

- [ ] **Step 4: Commit (yorum eklendiyse)**

```bash
git add firestore.rules
git commit -m "docs(security): firestore.rules tek-kullanıcı kapsamını belgele"
```

---

## Task 4: README + uçtan uca QA senaryoları

**Files:**
- Rewrite: `README.md`
- Create: `docs/QA-checklist.md`

- [ ] **Step 1: `README.md`'yi gerçek proje belgesiyle değiştir**

İçerik: proje özeti (Gilanlı Köy Meyhanesi, tek kullanıcı Kemal), tech stack, ön koşullar (Flutter SDK, Android, Firebase), Firebase kurulum notu (`firebase_options.dart`, Kemal hesabı konsoldan), çalıştırma komutları (`flutter pub get`, `flutter gen-l10n`, `flutter run`, `flutter build apk`), test komutları (`flutter test`, `flutter analyze`), mimari özeti (feature-first; domain/data/application/presentation; repository pattern; saf hesaplama servisleri TDD), i18n (TR/EN, ARB), erişilebilirlik notu, bilinen kısıtlar (iOS Windows'ta kapsam dışı — master plan onay #1; bildirim "kayıt girildiyse gösterme" v2). Başlık altyapısı İngilizce şablon metni tamamen kaldırılır.

- [ ] **Step 2: `docs/QA-checklist.md` oluştur (TR, Kemal cihazda koşacak)**

Uçtan uca senaryolar (her biri Adım → Beklenen):
- **Login:** doğru/yanlış kimlik; oturum kalıcılığı (uygulamayı kapat-aç); çıkış + onay dialog'u.
- **Personel:** ekle (ad/rol/ücret); düzenle; ücret değiştir → `wageHistory`; pasife al → günlük kayıtta görünmez; silme kısıtı.
- **Günlük Kayıt:** tüm alanlar; canlı toplam (patron masrafı kasaya yansımaz); bahşiş; çoklu personel seçimi; veresiye → veresiye defterine yansır; kaydet onayı; tarih ile yükleme/düzenleme.
- **Veresiye:** liste/durum chip; ekle; kısmi ödeme; "Ödendi" + geri al; düzenleme → mutabakat.
- **Ödemeler:** personel tahakkuku (çalışılan gün × ücret, wageHistory dahil); kısmi ödeme; bekleyen gider ekle + kısmi ödeme.
- **Dashboard:** tarih + selamlama; bugünün özeti (kayıt var/yok); 6 navigasyon kartı doğru rotaya gider.
- **Haftalık:** bar grafik + günlük liste + personel-gün tablosu; hafta gezinme; "Dağıtıldı, kapat" → bahşiş kasadan düşer/sıfırlanır.
- **Aylık:** 8 özet kartı (Kâr/Zarar §3.5, bahşiş hariç); grafikler; veresiye tablosu; ay gezinme.
- **Ayarlar:** dil TR↔EN **anında** değişir; bildirim saati + aç/kapa; ayarlanan saatte yerel bildirim gelir; çıkış.
- **i18n/Erişilebilirlik:** EN'de hiçbir TR sızıntısı yok; metinler okunur (14–18sp); butonlar rahat tıklanır (≥48dp).

- [ ] **Step 3: Commit**

```bash
git add README.md docs/QA-checklist.md
git commit -m "docs: gerçek README + uçtan uca manuel QA kontrol listesi"
```

---

## Task 5: Final doğrulama + PROGRESS + merge

**Files:**
- Modify: `PROGRESS.md`

- [ ] **Step 1: Tam test**

Run: `flutter test`
Expected: `All tests passed!`

- [ ] **Step 2: Tam analiz**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Debug APK derle (derlenebilirlik kanıtı)**

Run: `flutter build apk --debug`
Expected: `√ Built build\app\outputs\flutter-apk\app-debug.apk`

- [ ] **Step 4: `superpowers:verification-before-completion` çağır**

Tüm komut çıktıları kanıtla birlikte; iddia etmeden önce doğrula.

- [ ] **Step 5: `PROGRESS.md`'yi güncelle**

- Faz Durumu: `- [x] Faz 11 — Sağlamlaştırma & Cila ✅ tamam`; aktif faz "MVP tamam (DoD karşılandı)".
- Kronolojik not (2026-06-04) ekle: Faz 11 bulguları (string temiz, error lokalize, a11y denetim sonucu, rules doğrulandı, README+QA) + test/analyze/APK kanıtı.
- Faz 11 — Adımlar bölümü ekle (T0–T5).

- [ ] **Step 6: Commit + merge**

```bash
git add PROGRESS.md
git commit -m "docs: Faz 11 tamamlandı — MVP DoD karşılandı"
```
Sonra `superpowers:finishing-a-development-branch` ile `phase-11-hardening` → `main` (FF merge) seçeneğini sun/uygula.

- [ ] **Step 7: MVP Definition of Done teyidi (master plan §6)**

Her DoD maddesini işaretle: dahil özellikler çalışıyor, TR+EN tam + bildirim, test+analyze temiz + çekirdek TDD, erişilebilirlik hedefleri, onay/geri-alma kuralları.

---

## Self-Review

**Spec coverage (master plan Faz 11):**
- Hardcoded string denetimi → Task 1 ✅
- Erişilebilirlik denetimi (ui-ux-pro-max) → Task 2 ✅
- Güvenlik kuralları gözden geçirme → Task 3 ✅
- Manuel QA turu + README → Task 4 (README + QA listesi) + Task 5 (otomatik doğrulama) ✅
- DoD teyidi → Task 5 Step 7 ✅

**Not (kapsam dürüstlüğü):** "Manuel QA turu" cihazda insan (Kemal) tarafından koşulur; bu plan QA senaryolarını + otomatik doğrulamayı (test/analyze/build) üretir, fiziksel tıklama turunu değil.

**Placeholder taraması:** ARB ekleri ve hata-sitesi düzenlemeleri tam; a11y düzeltmeleri doğası gereği keşif-tabanlı (denetim → bulgu → düzelt), bu plan denetim yöntemini + kabul ölçütünü sabitler.
