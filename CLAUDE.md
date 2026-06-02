# Gilanlı Köy Meyhanesi — Muhasebe Uygulaması

## Proje Özeti

Tek kullanıcılı Flutter mobil muhasebe uygulaması. Kullanıcı: **Kemal**. Mekan: **Gilanlı Köy Meyhanesi**.  
Ayrıntılı gereksinimler için: [gilanli_meyhane_app.md](gilanli_meyhane_app.md)

---

## Tech Stack

| Katman | Teknoloji |
|---|---|
| UI Framework | Flutter (Dart) |
| State Management | Riverpod |
| Backend / DB | Firebase Firestore + Auth |
| Bildirimler | flutter_local_notifications |
| Lokalizasyon | Flutter Intl / ARB (TR / EN) |
| Grafikler | fl_chart |

---

## Aktif Skills

### superpowers (zorunlu)
Her konuşmada aktif. Tüm geliştirme görevlerinde ilgili skill'i `Skill` tool ile çağır.

**Sık kullanılacaklar:**
- `superpowers:brainstorming` — Yeni özellik veya yaklaşım kararları öncesi
- `superpowers:writing-plans` — Büyük implementasyon öncesi plan yaz
- `superpowers:executing-plans` — Plan varsa bu skill ile takip et
- `superpowers:test-driven-development` — Unit test gerektiren iş mantığı (özellikle `DailyRecordCalculator`)
- `superpowers:systematic-debugging` — Hata ayıklama
- `superpowers:verification-before-completion` — Her görev bitmeden önce

### ui-ux-pro-max
UI bileşeni yazarken, ekran tasarımı yaparken veya erişilebilirlik kontrolü yaparken `ui-ux-pro-max:ui-ux-pro-max` skill'ini çağır. Flutter stack verisi bu plugin içinde mevcut (`stacks/flutter.csv`).

### Firebase MCP Plugin
Firestore sorguları, Auth yönetimi, koleksiyon/döküman işlemleri için Firebase MCP araçlarını kullan. `firebase-tools` üzerinden çalışır; kullanmadan önce `firebase login` ile authenticate olunmuş olmalı.

---

## Kodlama Kuralları

### Genel
- Para hesaplamaları: `double` değil `int` (kuruş bazlı); gösterimde `formatCurrency()` kullan
- Günlük kayıt hesaplamalarını `DailyRecordCalculator` service sınıfına al — unit test yazılabilmeli
- Firestore'a UI doğrudan erişmesin: repository pattern kullan
- Riverpod provider'ları feature bazlı organize et; global state `shared/providers/` altında

### Lokalizasyon
- Türkçe veya İngilizce hiçbir string hardcode olmasın — tümü ARB dosyasına taşı
- Varsayılan dil: Türkçe

### Erişilebilirlik
- Font: min 14sp, max 18sp
- Tıklanabilir alan: min 48×48 dp
- Yeterli kontrast oranı

### Onay & Geri Alma Kuralları
- Her "Kaydet" işlemi öncesi onay dialog'u
- Silme yok; hatalı kayıt düzenleme ile düzeltilir
- "Ödendi" işareti geri alınabilir

---

## Firestore Koleksiyonları (Özet)

| Koleksiyon | Amaç |
|---|---|
| `dailyRecords` | Günlük kasa kaydı |
| `staff` | Personel ve ücret geçmişi |
| `creditSales` | Veresiye defteri |
| `payments` | Personel ödemeleri + bekleyen giderler |

---

## MVP Kapsam (v1.0)

**Dahil:** Login, Dashboard, Günlük Kayıt, Haftalık/Aylık Özet, Personel Paneli, Veresiye Defteri, Ödemeler Paneli, TR+EN dil desteği, yerel bildirim.

**Kapsam dışı (v2+):** Çoklu kullanıcı, CSV/PDF export, gelişmiş raporlama.

---

## Önemli Kararlar

1. Ücret değişikliği geçmişe uygulanmaz — `wageHistory` ile yeni ücret yalnızca sonraki kayıtlara yansır.
2. Mimari tek kullanıcı için kurulur ama ilerleyen sürümde genişleyebilecek şekilde tasarlanır.
3. Veri yedekleme: Firestore otomatik yedekleme yeterli, export gerekmez.
4. Günlük bildirim saati: kullanıcı tarafından ayarlanabilir.
