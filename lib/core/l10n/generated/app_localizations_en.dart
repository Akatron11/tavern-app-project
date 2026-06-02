// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gilanli Village Tavern';

  @override
  String greeting(String name) {
    return 'Hello Mr. $name';
  }

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get saveConfirmTitle => 'Are you sure you want to save?';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get loginError =>
      'Login failed. Please check your email and password.';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Are you sure you want to logout?';
}
