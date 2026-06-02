// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Gilanlı Köy Meyhanesi';

  @override
  String greeting(String name) {
    return 'Merhabalar $name Bey';
  }

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get confirm => 'Onayla';

  @override
  String get saveConfirmTitle => 'Kaydetmek istediğinizden emin misiniz?';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get login => 'Giriş Yap';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get emailRequired => 'E-posta zorunludur';

  @override
  String get passwordRequired => 'Şifre zorunludur';

  @override
  String get loginError => 'Giriş başarısız. E-posta veya şifre hatalı.';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get logoutConfirmTitle => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get staff => 'Personel';

  @override
  String get staffList => 'Personel Listesi';

  @override
  String get addStaff => 'Personel Ekle';

  @override
  String get editStaff => 'Personel Düzenle';

  @override
  String get staffName => 'Ad Soyad';

  @override
  String get staffNameRequired => 'Ad Soyad zorunludur';

  @override
  String get staffRole => 'Rol';

  @override
  String get dailyWage => 'Günlük Ücret (₺)';

  @override
  String get dailyWageRequired => 'Günlük ücret zorunludur';

  @override
  String get dailyWageInvalid => 'Geçerli bir ücret giriniz';

  @override
  String get isActive => 'Aktif';

  @override
  String get deactivate => 'Pasife Al';

  @override
  String get deactivateConfirmTitle =>
      'Bu personeli pasife almak istediğinizden emin misiniz?';

  @override
  String get deactivateConfirmBody =>
      'Pasif personel yeni kayıtlarda görünmez. Geçmiş kayıtlar etkilenmez.';

  @override
  String get deleteStaff => 'Personeli Sil';

  @override
  String get deleteStaffConfirmTitle =>
      'Bu personeli silmek istediğinizden emin misiniz?';

  @override
  String get deleteStaffConfirmBody => 'Bu işlem geri alınamaz.';

  @override
  String get wageHistory => 'Ücret Geçmişi';

  @override
  String get noStaff => 'Henüz personel eklenmemiş.';

  @override
  String wageUpdated(String date) {
    return 'Ücret güncellendi — $date tarihinden itibaren geçerli.';
  }

  @override
  String get roleGarson => 'Garson';

  @override
  String get roleAsci => 'Aşçı';

  @override
  String get roleBarmen => 'Barmen';

  @override
  String get roleKasiyer => 'Kasiyer';

  @override
  String get roleDiger => 'Diğer';

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Pasif';

  @override
  String get dailyRecord => 'Günlük Kayıt';

  @override
  String get recordDate => 'İş Günü Tarihi';

  @override
  String get revenue => 'Toplam Ciro';

  @override
  String get creditCardTotal => 'Kredi Kartı Toplamı';

  @override
  String get totalTips => 'Toplam Bahşiş';

  @override
  String get ownerExpense => 'Masraf (Patron Karşılar)';

  @override
  String get cashExpense => 'Masraf (Kasadan Çıkar)';

  @override
  String get creditSale => 'Veresiye Satış';

  @override
  String get creditCustomer => 'Müşteri Adı';

  @override
  String get previousDayCash => 'Dünden Kalan Kasa';

  @override
  String get workingStaff => 'Çalışan Personeller';

  @override
  String get notes => 'Notlar';

  @override
  String get liveTotals => 'Canlı Toplamlar';

  @override
  String get totalExpense => 'Toplam Masraf';

  @override
  String get dailyCash => 'Günlük Kasa';

  @override
  String get totalCash => 'Toplam Kasa';

  @override
  String get noActiveStaff => 'Aktif personel bulunmuyor.';

  @override
  String get creditCustomerRequired => 'Veresiye için müşteri adı zorunludur';

  @override
  String get dailyRecordSaved => 'Günlük kayıt kaydedildi.';

  @override
  String get openStaff => 'Personel';

  @override
  String get openDailyRecord => 'Günlük Kayıt';

  @override
  String get creditBook => 'Veresiye Defteri';

  @override
  String get addCreditSale => 'Veresiye Ekle';

  @override
  String get editCreditSale => 'Veresiyeyi Düzenle';

  @override
  String get creditTotalAmount => 'Toplam Tutar (₺)';

  @override
  String get creditTotalAmountRequired => 'Toplam tutar zorunludur';

  @override
  String get creditTotalAmountInvalid => 'Geçerli bir tutar giriniz';

  @override
  String get creditRemainingAmount => 'Kalan';

  @override
  String get creditStatusPending => 'Bekliyor';

  @override
  String get creditStatusPartial => 'Kısmi Ödendi';

  @override
  String get creditStatusPaid => 'Ödendi';

  @override
  String get addPayment => 'Ödeme Ekle';

  @override
  String get paymentAmount => 'Ödeme Tutarı (₺)';

  @override
  String get paymentAmountRequired => 'Ödeme tutarı zorunludur';

  @override
  String get paymentAmountInvalid => 'Geçerli bir tutar giriniz';

  @override
  String get paymentAmountExceedsRemaining =>
      'Ödeme tutarı kalandan fazla olamaz';

  @override
  String get markAsPaid => 'Ödendi';

  @override
  String get undoPaid => 'Geri Al';

  @override
  String get undoPaidConfirmTitle =>
      'Bu ödemeyi geri almak istediğinizden emin misiniz?';

  @override
  String get markAsPaidConfirmTitle =>
      'Tüm bakiyeyi ödenmiş olarak işaretlemek istiyor musunuz?';

  @override
  String get creditSaleAdded => 'Veresiye kaydedildi.';

  @override
  String get creditSaleUpdated => 'Veresiye güncellendi.';

  @override
  String get paymentAdded => 'Ödeme kaydedildi.';

  @override
  String get noCreditSales => 'Henüz veresiye kaydı yok.';

  @override
  String get openCreditBook => 'Veresiye Defteri';
}
