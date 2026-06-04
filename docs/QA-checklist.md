# Manuel QA Kontrol Listesi — Gilanlı Köy Meyhanesi (MVP v1.0)

> Cihazda (veya emülatörde) uçtan uca elle koşulur. Her madde **Adım → Beklenen**
> biçimindedir. Otomatik kapsam (`flutter test`, `flutter analyze`) ayrıca yeşildir;
> bu liste insan gözüyle akışları doğrular.
>
> **Hazırlık:** APK kurulu, internet açık, Firebase'de Kemal hesabı tanımlı.
> Önerilen ilk veri: en az 2 personel + 1 günlük kayıt + 1 veresiye.

---

## 1. Giriş / Oturum (Auth)

- [ +] **Yanlış kimlik** → E-posta/şifre hatalı girilir, "Giriş Yap" → hata snackbar'ı görünür, ekranda kalır.
- [+ ] **Doğru kimlik** → Kemal'in bilgileriyle giriş → Dashboard açılır.
- [+ ] **Oturum kalıcılığı** → Uygulama kapatılıp yeniden açılır → tekrar giriş istemeden Dashboard gelir.
- [+ ] **Çıkış** → Ayarlar > Çıkış → onay dialog'u → onayla → Login ekranına döner.
- [+ ] **Guard** → Çıkış sonrası geri tuşu/derin bağlantı korumalı ekranı açmaz (Login'e yönlendirir).

## 2. Dashboard

- [+ ] Üstte güncel tarih + "Merhabalar Kemal Bey" karşılaması görünür.
- [+ ] **Kayıt yokken** bugünün özeti "Bugün kayıt girilmemiş." der.
- [+ ] **Kayıt varken** günlük kasa ve çalışan personel sayısı doğru görünür.
- [+ ] 6 hızlı erişim kartı (Günlük, Personel, Veresiye, Ödemeler, Haftalık, Aylık) doğru ekrana gider.
- [+ ] Sağ üst dişli ikonu Ayarlar'ı açar.

## 3. Personel

- [+ ] **Ekle** → ad, rol (dropdown), günlük ücret → kaydet onayı → listede görünür.
- [+ ] **Zorunlu alan** → ad/ücret boşken kaydedilemez (validasyon mesajı).
- [+ ] **Düzenle → ücret değiştir** → yeni ücret girilir → "Ücret güncellendi, {tarih} itibarıyla" → eski kayıtlar eski ücreti korur (ücret geçmişi).
- [+ ] **Pasife al** → onay → personel yeni Günlük Kayıt çalışan listesinde **görünmez**; geçmiş kayıtlar etkilenmez.
- [+ ] **Silme kısıtı** → hiçbir kayıtta geçmeyen personel silinebilir; kayıtta geçen silinemez (yalnızca pasife alınır).

## 4. Günlük Kayıt

- [+ ] **Canlı kasa** → ciro/kredi kartı/bahşiş/kasa masrafı/veresiye değiştikçe Günlük Kasa anında güncellenir.
- [+ ] **Patron masrafı** → "Masraf (Patron Karşılar)" girilince Günlük Kasa **değişmez** (yalnızca toplam masraf gösteriminde görünür).
- [+ ] **Çoklu personel** → çalışanlar seçilir → `workingStaffIds` kaydedilir.
- [+ ] **Veresiye** → tutar + müşteri adı girilir → kaydet → Veresiye Defteri'nde ilgili kayıt oluşur.
- [+ ] **Kaydet onayı** → "Kaydetmek istediğinizden emin misiniz?" → onay sonrası snackbar.
- [+ ] **Tarih ile düzenleme** → geçmiş bir iş günü seçilir → mevcut kayıt alanlara yüklenir → değiştir → veresiye **mutabakatı** doğru güncellenir.
- [+ ] **Önceki gün kasası** alanı toplam kasaya doğru yansır.

## 5. Veresiye Defteri

- [+ ] Liste müşteri, kalan/toplam ve **durum chip'i** (Bekliyor/Kısmi/Ödendi) gösterir; chip metni okunur (≥14sp).
- [+ ] **Manuel ekleme** → müşteri + tutar → listede "Bekliyor".
- [+ ] **Kısmi ödeme** → kalandan az tutar → durum "Kısmi Ödendi", kalan azalır; **kalandan fazla ödeme engellenir**.
- [+ ] **Ödendi** → tam ödeme → durum "Ödendi", kalan 0.
- [+ ] **Geri al** → "Ödendi" geri alınır → önceki duruma döner.
- [+ ] **Düzenleme** → toplam değişince kalan/durum yeniden hesaplanır.

## 6. Ödemeler

- [+ ] **Personel sekmesi** → her personel için Çalışılan Gün, Tahakkuk (gün × ücret, **ücret geçmişi dahil**), Ödenen, Kalan doğru.
- [+ ] **Kısmi ödeme (personel)** → kalan azalır; tahakkuk kaydı korunur.
- [+ ] **Giderler sekmesi** → gider ekle (açıklama + tutar) → listede "Bekliyor".
- [+ ] **Gider kısmi/tam ödeme** → durum doğru güncellenir; gider chip metni okunur.

## 7. Haftalık Özet

- [ +] Bar grafiği 7 günün cirosunu gösterir; günlük özet listesi ve personel-gün tablosu doğru.
- [ +] **Hafta gezinme** `<` `>` çalışır; gelecek haftaya geçiş engellidir.
- [ +] **Dağıtılmamış bahşiş** kartı açık bahşiş toplamını gösterir.
- [ +] **"Dağıtıldı, Kapat"** → onay → açık bahşiş kasadan düşülür ve sıfırlanır; snackbar.
- [ +] Açık bahşiş yokken "Dağıtılacak bahşiş yok." görünür.

## 8. Aylık Özet

- [- ] 8 özet kartı doğru toplamları gösterir: Ciro, Kredi Kartı, Kasa Masrafı, Patron Masrafı (ayrı), Personel Ücretleri, Veresiye (toplam + tahsil edilemeyen), **Kâr/Zarar**.
- [- ] **Kâr/Zarar** = Ciro − Kredi Kartı − (Kasa+Patron Masrafı) − Personel Ücretleri − Tahsil Edilemeyen Veresiye (**bahşiş hariç**).
- [ +] Günlük ciro grafiği + veresiye tablosu doğru; tablo metni okunur (≥14sp).
- [ +] **Ay gezinme** çalışır; gelecek aya geçiş engellidir.

## 9. Ayarlar / Bildirim

- [+ ] **Dil TR → EN** → seçim anında uygulanır (yeniden başlatma yok); tüm ekranlar İngilizce.
- [+ ] **Dil EN → TR** → geri döner.
- [- ] **Bildirim aç + saat seç** → seçilen saatte günlük hatırlatma bildirimi gelir ("Bugünün kasa kaydını girmeyi unutmayın.").
- [+ ] **Bildirim kapat** → planlı bildirim iptal edilir (gelmez).
- [+ ] **İzin** → Android 13+ ilk açılışta bildirim izni istenir.

## 10. i18n & Erişilebilirlik (çapraz)

- [ +] EN dilinde hiçbir Türkçe metin sızıntısı yok; tersi de geçerli.
- [ ?] Hata durumlarında ham Dart istisnası değil, lokalize "Bir hata oluştu / An error occurred" görünür.
- [ +] Metinler rahat okunur (gövde 14–18sp); butonlar/ikonlar rahat tıklanır (≥48dp).
- [ -] Para her yerde `1.000 ₺` biçiminde, yerel ayraçla.

---

## Onay / Geri-Alma Kuralları (master plan §6 DoD)

- [+ ] Her "Kaydet" öncesi onay dialog'u var.
- [+ ] Silme yok (hatalı kayıt düzenlemeyle düzeltilir); yalnızca personel silme kısıtlı senaryoda.
- [ +] "Ödendi" işareti geri alınabilir.
- [ +] Çıkışta onay dialog'u var.

> Tüm maddeler işaretlendiğinde MVP "Definition of Done" insan-doğrulaması tamamlanır.
