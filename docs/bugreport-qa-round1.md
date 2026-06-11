# QA Tur 1 — Bug & İyileştirme Raporu
> Tarih: 2026-06-04  
> Test eden: Kemal  
> Durum: ✅ **TÜMÜ ÇÖZÜLDÜ — Faz 12 (2026-06-04)**. 16 bug + 2 yeni özellik + 2 iyileştirme uygulandı (147 test yeşil). BUG-14 ("bu günün" yazımı) kodda mevcut değildi — `todaySummary` zaten "Bugünün Özeti"; doğrulandı, değişiklik yok. Ayrıntı: [PROGRESS.md](../PROGRESS.md) + commit geçmişi.

---

## Öncelik Tanımları
- 🔴 **KRİTİK** — Veri bütünlüğünü bozar veya yanlış kayıt oluşturur
- 🟠 **YÜKSEK** — Temel akışı kırar, kullanılamaz hale getirir
- 🟡 **ORTA** — Çalışıyor ama hatalı/eksik davranış
- 🟢 **DÜŞÜK** — UI/UX iyileştirme, kozmetik

---

## 1. Günlük Kayıt

### BUG-01 🔴 Veresiye mutabakat hatası — yanlış "ödendi" işaretleme
**Senaryo:**
1. Günlük kayıt oluştururken veresiye satışa X müşterisi eklendi.
2. Tutar yanlış girildiği fark edildi, aynı kayıt düzenlendi (veresiye tutarı değiştirildi).
3. Sonuç: Veresiye defterinde X müşterisi sistem tarafından otomatik olarak "ödendi" olarak işaretlendi.

**Beklenen davranış:** Düzenleme sırasında tutar değiştiğinde `CreditReconciler.reconcile` doğru çalışmalı; müşteri "ödendi" olarak işaretlenmemeli.

**Kök neden tahmini:** `saveRecord` düzenleme akışında reconcile mantığı, delta yerine sıfırdan hesaplama yapıyor olabilir.

---

### BUG-02 🟠 Zorunlu alan validasyonu eksik
**Etkilenen alanlar:** Toplam ciro, Kredi kartı toplamı, Masraf (patron karşılar), Masraf (kasadan çıkar), Dünden kalan kasa.

**Mevcut davranış:** Bu alanlar boş bırakılsa bile kayıt sisteme yazılıyor.

**Beklenen davranış:** Bu 5 alan boş bırakılamaz; kaydet butonuna basıldığında (veya onay dialog'u açılmadan önce) validasyon hatası gösterilmeli.

> Not: Toplam ciro 0 girilebilmeli (sıfır cirolu gün olabilir), ama boş/null geçilemez.

---

### BUG-03 🟡 Kayıt sonrası dashboard güncellenmemesi
**Mevcut davranış:** Günlük kayıt kaydedildikten sonra dashboard'a dönüldüğünde bugünün özeti görünmüyor. Uygulama yeniden başlatılınca görünüyor.

**Beklenen davranış:** Kayıt başarıyla kaydedildikten sonra dashboard provider'ı invalidate edilmeli; uygulama yeniden başlatılmadan özet güncellenmeli.

**Kök neden tahmini:** Dashboard provider cache'i, `saveRecord` sonrası `ref.invalidate` veya `ref.refresh` çağrılmıyor.

---

## 2. Veresiye Defteri

### BUG-04 🟠 Ödeme ekle — onay sonrası hata ekranı
**Mevcut davranış:** Ödeme tutarı girilip "Onayla" butonuna basıldıktan sonra hata ekranı açılıyor. Telefon geri tuşuyla dashboard'a dönülünce ödeme başarılı görünüyor (snackbar geliyor, kısmi ödeme işleniyor). Ayrıca işlemden vazgeçildiğinde de (dialog kapatılınca) aynı hata ekranıyla karşılaşılıyor.

**Beklenen davranış:** Ödeme başarılıysa veresiye defteri listesine döner, hata ekranı açılmaz. Dialog kapatılınca herhangi bir hata olmadan liste görünümüne döner.

**Ek bilgi:** Ekran görüntüsü mevcut (kullanıcıdan alınacak).

---

### BUG-05 🟡 Günlük kayıttan gelen veresiye satışlarında tarih görünmüyor
**Mevcut davranış:** Günlük kayıt sırasında eklenen veresiye satışları, Veresiye Defteri listesinde tarihleri görünmüyor.

**Beklenen davranış:** `creditSales.date` alanı her kayıtta dolu olmalı; liste görünümünde tarih sütunu gösterilmeli.

---

### BUG-06 🟡 Manuel veresiye eklemede tarih alanı yok
**Mevcut davranış:** Manuel veresiye eklerken tarih seçilemiyor.

**Beklenen davranış:** Veresiye ekleme formuna tarih seçici (DatePicker) eklenmeli; varsayılan bugünün tarihi olmalı.

---

### BUG-07 🟡 Fazla ödeme uyarısı ekrana sığmıyor
**Mevcut davranış:** Kalan tutardan fazla ödeme girildiğinde gelen hata mesajı ekrana sığmıyor, kısmen okunabiliyor.

**Beklenen davranış:** Hata mesajı tam okunabilir şekilde gösterilmeli (metin taşması olmamalı, gerekirse birden fazla satıra bölünmeli).

**Ek bilgi:** Ekran görüntüsü mevcut (kullanıcıdan alınacak).

---

### YENİ-01 🟡 Ödendi müşterileri için silme özelliği
**Gerekçe:** "Ödendi" olarak işaretlenen müşteri sayısı arttıkça liste kalabalıklaşıyor.

**Beklenen davranış:** Durumu "ödendi" olan kayıtlar silinebilmeli. Silme öncesi onay dialog'u gösterilmeli. (Durumu "bekliyor" veya "kısmi" olan kayıtlar silinemez.)

---

## 3. Ödemeler Paneli

### BUG-08 🟡 Gider düzenleme sonrası "kalan" güncellenmemesi
**Senaryo:**
1. Giderler sekmesine yeni gider eklendi, toplam tutar yanlış girildi.
2. Gider düzenlendi, toplam tutar doğru değere güncellendi.
3. Sonuç: "Kalan" sütunu eski (yanlış) değerde kalıyor. Kısmi ödeme yapıldığında ancak o zaman doğru değere güncelleniyor.

**Beklenen davranış:** Toplam tutar düzenlendiğinde `remainingAmount = totalAmount - paidAmount` yeniden hesaplanmalı ve anında güncellenmeli.

---

### YENİ-02 🟡 Ödendi giderler için silme özelliği
**Gerekçe:** Veresiye defterindeki ile aynı gerekçe — ödendi kayıtlar birikerek listeyi kalabalıklaştırıyor.

**Beklenen davranış:** Durumu "ödendi" olan gider kayıtları silinebilmeli. Silme öncesi onay dialog'u.

---

## 4. Aylık Özet

### BUG-09 🔴 Kâr/Zarar formülü hatalı
**Mevcut formül (yanlış):**
```
Kâr/Zarar = Ciro − Kredi Kartı − Masraflar − Personel Ücretleri − Tahsil Edilemeyen Veresiye
```

**Doğru formül:**
```
Kâr/Zarar = Ciro − Masraflar − Personel Ücretleri − Tahsil Edilemeyen Veresiye
```

**Gerekçe:** Kredi kartı ödemesi de ciroya dahildir; müşteri hesabını zaten ödemiştir. Kredi kartı tutarını ayrıca düşmek çifte kesinti yaratır.

---

### BUG-10 🟡 Reaktivite sorunu — veresiye değişiklikleri anında yansımıyor
**Etkilenen alanlar:**
- "Tahsil Edilemeyen" özet kartı
- Aylık veresiye tablosu

**Mevcut davranış:** Veresiye defterinde yapılan değişiklikler (ödeme, durum güncelleme) aylık özet ekranına yansımıyor. Uygulama yeniden başlatılınca görünüyor.

**Beklenen davranış:** İlgili Riverpod provider'ları veresiye koleksiyonunu dinlemeli; değişiklik anında güncellenmeli.

---

### BUG-11 🟡 Toplam veresiye kartı ödendi sonrası güncellenmemesi
**Mevcut davranış:** Veresiye defterindeki tüm müşteriler "ödendi" olarak işaretlense bile "Toplam Veresiye" kartı hâlâ toplam (ödenmemiş gibi) tutarı gösteriyor.

**Beklenen davranış:** "Toplam Veresiye" kartı yalnızca durumu `pending` veya `partial` olan kayıtların toplamını göstermeli. (Alternatif: kart adı "Tahsil Bekleyen Veresiye" olarak değiştirilebilir; bu daha net olur.)

> Spec'te bu kartın tam tanımı belirsiz — implementasyonla birlikte netleştirilmeli.

---

## 5. Haftalık Özet

### BUG-12 🟢 Günlük kayıt listesinde tarih formatı kısa
**Mevcut davranış:** `1 Haz, Pazartesi` şeklinde gösteriliyor.

**Beklenen davranış:** `1 Haziran, Pazartesi` şeklinde tam ay adıyla gösterilmeli.

---

### BUG-13 🟢 Personel günleri tablosunda taşma sorunu
**Mevcut davranış:** Personelin çalıştığı günler alt alta yazılıyor, tablo düzensiz görünüyor.

**Beklenen davranış:** Çalışılan günler tek satırda virgülle ayrılarak veya daha kompakt bir chip/badge yapısıyla gösterilmeli. Taşma durumunda yatay scroll veya "+N daha" etiketi kullanılabilir.

**Ek bilgi:** Ekran görüntüsü mevcut (kullanıcıdan alınacak).

---

## 6. Dashboard

### BUG-14 🟢 Yazım hatası — "Bu günün özeti"
**Mevcut:** `bu günün özeti` (yanlış, iki kelime)
**Doğru:** `bugünün özeti` (tek kelime)

> ARB dosyasında düzeltilmeli.

---

### İYİ-01 🟢 Dashboard bugün özet kartı içeriği değişikliği
**Mevcut davranış:** Özet kartında çalışan personel sayısı gösteriliyor.

**İstenen davranış:** Personel sayısı yerine **o günün cirosunu** göstersin. Günlük kasa bilgisi en üstte, ciro bilgisi onun altında yer alsın.

---

## 7. Login

### İYİ-02 🟢 Şifre göster/gizle butonu eksik
**Mevcut davranış:** Şifre alanında göz ikonu yok, girilen şifre her zaman gizli.

**Beklenen davranış:** Şifre alanına "göster/gizle" toggle ikonu eklenmeli (standart Flutter `obscureText` toggle).

---

## 8. Para Formatı (Sistem Geneli)

### BUG-15 🟠 Para girişlerinde binlik ayırıcı çalışmıyor
**Mevcut davranış:** Kullanıcı `6000` girdiğinde alanda `6000` görünüyor.

**Beklenen davranış:** Kullanıcı yazarken (veya focus kaybolunca) `6,000` şeklinde formatlanmalı. Bu sistem genelinde tutarlı olmalı — tüm `MoneyInputField` kullanan alanlar etkilenir.

**Not:** Bu gereksinim proje başında belirtilmişti. `MoneyInputField` widget'ında `TextInputFormatter` veya `onChanged` ile canlı formatlama yapılmalı.

---

## 9. Bildirimler

### BUG-16 🟡 Günlük kayıt yapılmasına rağmen bildirim geliyor
**Mevcut davranış:** O gün için günlük kayıt zaten girilmiş olsa bile günlük hatırlatma bildirimi geliyor.

**Beklenen davranış:** Bildirim tetiklenmeden önce bugüne ait `dailyRecords` kaydı olup olmadığı kontrol edilmeli. Kayıt varsa bildirim iptal edilmeli/gösterilmemeli.

---

## Özet Tablosu

| ID | Panel | Öncelik | Tür |
|---|---|---|---|
| BUG-01 | Günlük Kayıt | 🔴 KRİTİK | Bug |
| BUG-09 | Aylık Özet | 🔴 KRİTİK | Bug |
| BUG-02 | Günlük Kayıt | 🟠 YÜKSEK | Bug |
| BUG-04 | Veresiye Defteri | 🟠 YÜKSEK | Bug |
| BUG-15 | Sistem Geneli | 🟠 YÜKSEK | Bug |
| BUG-03 | Dashboard | 🟡 ORTA | Bug |
| BUG-05 | Veresiye Defteri | 🟡 ORTA | Bug |
| BUG-06 | Veresiye Defteri | 🟡 ORTA | Bug |
| BUG-07 | Veresiye Defteri | 🟡 ORTA | Bug |
| BUG-08 | Ödemeler | 🟡 ORTA | Bug |
| BUG-10 | Aylık Özet | 🟡 ORTA | Bug |
| BUG-11 | Aylık Özet | 🟡 ORTA | Bug |
| BUG-16 | Bildirimler | 🟡 ORTA | Bug |
| YENİ-01 | Veresiye Defteri | 🟡 ORTA | Yeni özellik |
| YENİ-02 | Ödemeler | 🟡 ORTA | Yeni özellik |
| BUG-12 | Haftalık Özet | 🟢 DÜŞÜK | Bug |
| BUG-13 | Haftalık Özet | 🟢 DÜŞÜK | Bug |
| BUG-14 | Dashboard | 🟢 DÜŞÜK | Bug |
| İYİ-01 | Dashboard | 🟢 DÜŞÜK | İyileştirme |
| İYİ-02 | Login | 🟢 DÜŞÜK | İyileştirme |
