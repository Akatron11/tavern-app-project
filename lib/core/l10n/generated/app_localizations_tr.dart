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
}
