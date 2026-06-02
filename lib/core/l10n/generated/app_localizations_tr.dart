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
}
