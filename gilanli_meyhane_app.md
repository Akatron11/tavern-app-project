# Gilanlı Köy Meyhanesi — Muhasebe Uygulaması
> Tek kullanıcılı, Türkçe/İngilizce destekli Flutter mobil uygulaması.  
> Patron: **Kemal** | Mekan: **Gilanlı Köy Meyhanesi**

---

## 1. Tech Stack

| Katman | Teknoloji |
|---|---|
| UI Framework | Flutter (Dart) |
| State Management | Riverpod |
| Backend / DB | Google Firebase (Firestore + Auth) |
| Local Notifications | flutter_local_notifications |
| Lokalizasyon | Flutter Intl / ARB dosyaları (TR / EN) |

---

## 2. Mimari & Klasör Yapısı

```
lib/
├── main.dart
├── app/
│   ├── app.dart                  # MaterialApp, router, theme
│   └── router.dart               # GoRouter tanımları
├── core/
│   ├── constants/
│   │   └── app_constants.dart    # Renk, boyut, font sabitleri
│   ├── extensions/
│   │   └── currency_extension.dart  # formatCurrency() → "1,000 ₺"
│   ├── l10n/                     # ARB lokalizasyon dosyaları
│   │   ├── app_tr.arb
│   │   └── app_en.arb
│   └── utils/
│       └── date_utils.dart
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── daily_record/
│   ├── weekly_summary/
│   ├── monthly_summary/
│   ├── staff/
│   ├── credit_book/              # Veresiye defteri
│   └── payments/                 # Ödemeler paneli
├── shared/
│   ├── widgets/                  # Ortak widget'lar
│   └── providers/                # Global Riverpod provider'ları
└── firebase_options.dart
```

---

## 3. Firebase Firestore Veri Modeli

### `dailyRecords/{recordId}`
```
{
  date: Timestamp,
  totalRevenue: number,          // Toplam ciro
  creditCardTotal: number,       // Kredi kartı toplamı (eksi)
  totalTips: number,             // Bahşiş (artı)
  ownerExpenses: number,         // Patron karşılar (eksi)
  cashExpenses: number,          // Kasadan çıkan masraf (eksi)
  totalExpenses: number,         // Toplam masraf = ownerExpenses + cashExpenses
  creditSales: number,           // Veresiye (eksi)
  previousDayCash: number,       // Dünden kalan kasa (kullanıcı girer)
  dailyCash: number,             // Günlük kasa = ciro - kartlar + tips - totalExpenses - veresiye
  totalCash: number,             // Toplam kasa = dünden kalan + günlük kasa
  workingStaffIds: [staffId],    // O gün çalışan personel listesi
  notes: string
}
```

### `staff/{staffId}`
```
{
  name: string,
  role: enum [garson, asci, bulasikci, ekstraci],
  dailyWage: number,
  isActive: boolean,             // false → günlük kayıtta seçilemez, listede gizlenir
  wageHistory: [                 // Zam/değişiklik geçmişi
    { dailyWage: number, effectiveDate: Timestamp }
  ]
}
```

### `creditSales/{saleId}`
```
{
  customerName: string,
  totalAmount: number,
  remainingAmount: number,
  date: Timestamp,
  status: enum [pending, partial, paid],
  payments: [
    { amount: number, date: Timestamp }
  ],
  linkedDailyRecordId: string    // Günlük kayıttan eklendiyse referans
}
```

### `payments/{paymentId}`
```
{
  type: enum [staff, expense],
  staffId: string | null,
  description: string,
  totalAmount: number,
  paidAmount: number,
  remainingAmount: number,
  status: enum [pending, partial, paid],
  dueDate: Timestamp,
  payments: [
    { amount: number, date: Timestamp }
  ]
}
```

---

## 4. Ekranlar & Özellikler

### 4.1 Auth — Login Ekranı
- Firebase Authentication (email + şifre)
- "Çıkış yapmak istediğinizden emin misiniz?" onay dialog'u
- Sistem tek kullanıcı için tasarlanmış; ilerleyen sürümde çoklu kullanıcı desteği eklenebilir

---

### 4.2 Dashboard (Ana Sayfa)
- Üstte tarih ve "Merhabalar Kemal Bey" karşılama
- Hızlı erişim kartları:
  - 📋 Günlük Kayıt
  - 📊 Haftalık Özet
  - 📅 Aylık Özet
- Bugünün kısa özeti (varsa): günlük kasa, çalışan personel sayısı

---

### 4.3 Günlük Kayıt Paneli

**Kullanıcının gireceği alanlar:**
| Alan | Tür | İşlem |
|---|---|---|
| İş günü tarihi | DatePicker | — |
| Toplam ciro | NumberInput | + |
| Kredi kartı toplamı | NumberInput | − |
| Toplam bahşiş | NumberInput | + |
| Masraf (patron karşılar) | NumberInput | − |
| Masraf (kasadan çıkar) | NumberInput | − |
| Veresiye satış | NumberInput + müşteri adı | − |
| Dünden kalan kasa | NumberInput | + |
| Çalışan personeller | MultiSelect (aktif personeller) | — |

**Otomatik hesaplama (UI'da canlı gösterilir):**
```
ToplamMasraf = PatronMasrafı + KasaMasrafı
Günlük Kasa = Ciro - KrediKartı + Bahşiş - ToplamMasraf - Veresiye
Toplam Kasa = DündenKalan + GünlükKasa
```

> Kullanıcı iki ayrı alan girer: **Masraf** (patron karşılar) ve **Kasadan Çıkan Masraf**. Sistem ikisini toplayıp tek **Masraf** kalemi olarak işler ve gösterir.

**İşlem kuralları:**
- Veresiye eklendiğinde otomatik olarak `creditSales` koleksiyonuna yazılır
- Çalışan personeller `dailyRecords.workingStaffIds`'e kaydedilir; personel ödemesi `payments` koleksiyonuna düşer
- Kaydet'e basılmadan önce "Kaydetmek istediğinizden emin misiniz?" onay dialog'u gösterilir
- Kaydedilmiş günlük kayıt düzenlenebilir (silme yok, sadece düzenleme)

---

### 4.4 Haftalık Özet

- Seçili haftanın her günü için ciro bar grafiği (fl_chart)
- Haftanın günlük özet listesi (tarih, ciro, günlük kasa)
- O haftada çalışan personel tablosu: `[Ad] | [Çalıştığı günler] | [Toplam gün]`
- Herhangi bir güne tıklanınca o günün detay sayfası açılır
- Haftalar arası gezinme: `<` `>` butonları

---

### 4.5 Aylık Özet

**Özet kartları:**
- Toplam Ciro
- Toplam Gider (personel ödemeleri + veresiye satışlar + masraflar)
- Toplam Veresiye Satış Tutarı
- Patrona Kalan = `Ciro − (Giderler + Veresiye)`

**Grafikler:**
- Günlük ciro bar grafiği (o ay)
- Haftalık ciro bar grafiği (o ay)

**Veresiye tablosu:**
- Müşteri adı | Tarih | Tutar | Durum

---

### 4.6 Personel Paneli

**Yeni personel ekleme formu:**
- Ad (TextInput)
- Rol (Dropdown: Garson / Aşçı / Bulaşıkçı / Ekstraci)
- Günlük Ücret (NumberInput)
- Günlük kayıtta seçilebilir (Toggle — varsayılan: aktif)

**Personel listesi — her kart için:**
- Düzenle (isim, rol, ücret)
- Pasife al (günlük kayıtta görünmez, kayıtlarda silinmez)
- Sil (yalnızca hiç günlük kayıtta yer almayan personel silinebilir; aksi hâlde pasife alınması önerilir)

**Maaş değişikliği davranışı:**
- Ücret güncellendiğinde yeni değer `wageHistory` dizisine `effectiveDate` ile eklenir
- Geçmiş günlük kayıtlar eski ücret üzerinden hesaplanmaya devam eder
- Gelecek günlük kayıtlar yeni ücret üzerinden hesaplanır

---

### 4.7 Veresiye Defteri Paneli

**Liste görünümü:**
- Müşteri adı | Toplam borç | Kalan borç | Durum (Bekliyor / Kısmi / Ödendi)
- Düzenleme butonu (yanlış giriş düzeltmek için)

**Yeni veresiye ekleme (manuel):**
- Müşteri adı, tutar, tarih seçimi

**Ödeme işlemleri:**
- **Kısmi Ödeme:** Ödenen tutar girilir → `remainingAmount` güncellenir, `payments[]` dizisine eklenir, durum `partial` olur
- **Tam Ödeme:** "Ödendi" butonu → durum `paid` olur; **geri alma butonu** mevcut (yanlışlıkla basıldığında)

---

### 4.8 Ödemeler Paneli

İki sekme: **Personel Ödemeleri** | **Bekleyen Giderler**

**Personel Ödemeleri sekmesi:**
- Günlük kayıtta işaretlenen personeller buraya düşer
- Tablo: `[Ad] | [Çalışılan Gün] | [Toplam Ücret] | [Ödenen] | [Kalan]`
- Kısmi ödeme desteği (veresiye defterindeki ile aynı mantık)

**Bekleyen Giderler sekmesi:**
- Kullanıcının manuel eklediği borçlar/giderler
- Kısmi ödeme desteği

---

## 5. Genel Sistem Kuralları

### Para Formatı
- Tüm para değerleri `1,000` formatında gösterilir (binlik ayırıcı virgül)
- `currency_extension.dart` içinde `formatCurrency()` metodu tüm UI'da kullanılır

### Geri Alma / Onay Mekanizmaları
- Her "Kaydet" işlemi öncesi onay dialog'u
- Yanlış kayıt için düzenleme akışı (silme yerine düzenleme tercih edilir)
- "Ödendi" işaretleme geri alınabilir
- Uygulama kapatılırken / çıkış yapılırken onay dialog'u

### Bildirimler
- Kullanıcı günlük kayıt yapmayı unutursa yerel bildirim gönderilir
- Bildirim saati: kullanıcı tarafından ayarlar menüsünden belirlenir (mekanın kapanış saati değişken)

### Erişilebilirlik
- Font boyutu: minimum 14sp, maksimum 18sp (gözlük kullanan kullanıcı)
- Yeterli kontrast oranı
- Tıklanabilir alanlar minimum 48x48 dp

### Lokalizasyon
- Varsayılan dil: Türkçe
- İkinci dil: İngilizce
- Dil değiştirme ayarlar menüsünden yapılır; uygulama yeniden başlatılmadan uygulanır

---

## 6. Kararlar

| # | Konu | Karar |
|---|---|---|
| 1 | Maaş değişikliğinde geçmiş kayıtlar | Geçmiş sabit kalır — yeni ücret yalnızca sonraki kayıtlara uygulanır ✅ |
| 2 | Çoklu kullanıcı desteği (gelecek) | Şimdilik tek kullanıcı; mimari ileride genişleyebilecek şekilde kurulsun ✅ |
| 3 | Veri yedekleme | Firestore otomatik yedekleme yeterli, CSV/Excel export gerekmez ✅ |
| 4 | Günlük bildirim saati | Kullanıcı tarafından ayarlanabilir — mekanın kapanış saati değişken olduğu için sabit saat uygun değil ✅ |

---

## 7. MVP Kapsam Sınırı (v1.0)

**Dahil:**
- Login, Dashboard, Günlük Kayıt, Haftalık/Aylık Özet, Personel, Veresiye Defteri, Ödemeler
- Türkçe + İngilizce dil desteği
- Yerel bildirim

**Dahil Değil (v2+):**
- Çoklu kullanıcı / rol yönetimi
- Veri export (CSV/PDF)
- Grafik temalı raporlama

---

## 8. Geliştirme Notları (Claude Code için)

- Riverpod provider'ları `features/` altında feature bazlı organize et; global state `shared/providers/` altında
- Firestore işlemleri için repository pattern kullan (UI Firestore'u doğrudan çağırmasın)
- Tüm para hesaplamalarını `double` yerine `int` (kuruş bazlı) ile yap, gösterimde formatla
- Günlük kayıt hesaplamaları için ayrı bir `DailyRecordCalculator` service sınıfı yaz, unit test yazılabilsin
- `wageHistory` sayesinde geçmiş ödeme hesaplamaları her zaman doğru ücret üzerinden yapılabilir
- Lokalizasyon için tüm string'leri ARB dosyasına al; hiçbir Türkçe/İngilizce string hardcode olmasın
