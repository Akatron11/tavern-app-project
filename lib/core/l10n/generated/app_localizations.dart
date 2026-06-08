import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Uygulama adı
  ///
  /// In tr, this message translates to:
  /// **'Gilanlı Köy Meyhanesi'**
  String get appTitle;

  /// Ana ekran karşılama metni
  ///
  /// In tr, this message translates to:
  /// **'Merhabalar {name} Bey'**
  String greeting(String name);

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get confirm;

  /// No description provided for @saveConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydetmek istediğinizden emin misiniz?'**
  String get saveConfirmTitle;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// Login butonu ve ekran başlığı
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// E-posta alanı etiketi
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// Şifre alanı etiketi
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// E-posta boş bırakıldığında hata
  ///
  /// In tr, this message translates to:
  /// **'E-posta zorunludur'**
  String get emailRequired;

  /// Şifre boş bırakıldığında hata
  ///
  /// In tr, this message translates to:
  /// **'Şifre zorunludur'**
  String get passwordRequired;

  /// Hatalı kimlik bilgisi snackbar mesajı
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız. E-posta veya şifre hatalı.'**
  String get loginError;

  /// Çıkış butonu
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// Çıkış onay dialog başlığı
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapmak istediğinizden emin misiniz?'**
  String get logoutConfirmTitle;

  /// Personel menü başlığı
  ///
  /// In tr, this message translates to:
  /// **'Personel'**
  String get staff;

  /// No description provided for @staffList.
  ///
  /// In tr, this message translates to:
  /// **'Personel Listesi'**
  String get staffList;

  /// No description provided for @addStaff.
  ///
  /// In tr, this message translates to:
  /// **'Personel Ekle'**
  String get addStaff;

  /// No description provided for @editStaff.
  ///
  /// In tr, this message translates to:
  /// **'Personel Düzenle'**
  String get editStaff;

  /// No description provided for @staffName.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get staffName;

  /// No description provided for @staffNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad zorunludur'**
  String get staffNameRequired;

  /// No description provided for @staffRole.
  ///
  /// In tr, this message translates to:
  /// **'Rol'**
  String get staffRole;

  /// No description provided for @dailyWage.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Ücret (₺)'**
  String get dailyWage;

  /// No description provided for @dailyWageRequired.
  ///
  /// In tr, this message translates to:
  /// **'Günlük ücret zorunludur'**
  String get dailyWageRequired;

  /// No description provided for @dailyWageInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir ücret giriniz'**
  String get dailyWageInvalid;

  /// No description provided for @isActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get isActive;

  /// No description provided for @deactivate.
  ///
  /// In tr, this message translates to:
  /// **'Pasife Al'**
  String get deactivate;

  /// No description provided for @deactivateConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu personeli pasife almak istediğinizden emin misiniz?'**
  String get deactivateConfirmTitle;

  /// No description provided for @deactivateConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Pasif personel yeni kayıtlarda görünmez. Geçmiş kayıtlar etkilenmez.'**
  String get deactivateConfirmBody;

  /// No description provided for @deleteStaff.
  ///
  /// In tr, this message translates to:
  /// **'Personeli Sil'**
  String get deleteStaff;

  /// No description provided for @deleteStaffConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu personeli silmek istediğinizden emin misiniz?'**
  String get deleteStaffConfirmTitle;

  /// No description provided for @deleteStaffConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz.'**
  String get deleteStaffConfirmBody;

  /// No description provided for @wageHistory.
  ///
  /// In tr, this message translates to:
  /// **'Ücret Geçmişi'**
  String get wageHistory;

  /// No description provided for @noStaff.
  ///
  /// In tr, this message translates to:
  /// **'Henüz personel eklenmemiş.'**
  String get noStaff;

  /// No description provided for @wageUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Ücret güncellendi — {date} tarihinden itibaren geçerli.'**
  String wageUpdated(String date);

  /// No description provided for @roleGarson.
  ///
  /// In tr, this message translates to:
  /// **'Garson'**
  String get roleGarson;

  /// No description provided for @roleAsci.
  ///
  /// In tr, this message translates to:
  /// **'Aşçı'**
  String get roleAsci;

  /// No description provided for @roleBarmen.
  ///
  /// In tr, this message translates to:
  /// **'Barmen'**
  String get roleBarmen;

  /// No description provided for @roleKasiyer.
  ///
  /// In tr, this message translates to:
  /// **'Kasiyer'**
  String get roleKasiyer;

  /// No description provided for @roleDiger.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get roleDiger;

  /// No description provided for @active.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In tr, this message translates to:
  /// **'Pasif'**
  String get inactive;

  /// Günlük kayıt ekranı başlığı ve menü
  ///
  /// In tr, this message translates to:
  /// **'Günlük Kayıt'**
  String get dailyRecord;

  /// No description provided for @recordDate.
  ///
  /// In tr, this message translates to:
  /// **'İş Günü Tarihi'**
  String get recordDate;

  /// No description provided for @revenue.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Ciro'**
  String get revenue;

  /// No description provided for @creditCardTotal.
  ///
  /// In tr, this message translates to:
  /// **'Kredi Kartı Toplamı'**
  String get creditCardTotal;

  /// No description provided for @totalTips.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Bahşiş'**
  String get totalTips;

  /// No description provided for @ownerExpense.
  ///
  /// In tr, this message translates to:
  /// **'Masraf (Patron Karşılar)'**
  String get ownerExpense;

  /// No description provided for @cashExpense.
  ///
  /// In tr, this message translates to:
  /// **'Masraf (Kasadan Çıkar)'**
  String get cashExpense;

  /// No description provided for @creditSale.
  ///
  /// In tr, this message translates to:
  /// **'Veresiye Satış'**
  String get creditSale;

  /// No description provided for @creditCustomer.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri Adı'**
  String get creditCustomer;

  /// No description provided for @previousDayCash.
  ///
  /// In tr, this message translates to:
  /// **'Dünden Kalan Kasa'**
  String get previousDayCash;

  /// No description provided for @workingStaff.
  ///
  /// In tr, this message translates to:
  /// **'Çalışan Personeller'**
  String get workingStaff;

  /// No description provided for @notes.
  ///
  /// In tr, this message translates to:
  /// **'Notlar'**
  String get notes;

  /// No description provided for @liveTotals.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Toplamlar'**
  String get liveTotals;

  /// No description provided for @totalExpense.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Masraf'**
  String get totalExpense;

  /// No description provided for @dailyCash.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Kasa'**
  String get dailyCash;

  /// No description provided for @totalCash.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Kasa'**
  String get totalCash;

  /// No description provided for @noActiveStaff.
  ///
  /// In tr, this message translates to:
  /// **'Aktif personel bulunmuyor.'**
  String get noActiveStaff;

  /// No description provided for @creditCustomerRequired.
  ///
  /// In tr, this message translates to:
  /// **'Veresiye için müşteri adı zorunludur'**
  String get creditCustomerRequired;

  /// No description provided for @dailyRecordSaved.
  ///
  /// In tr, this message translates to:
  /// **'Günlük kayıt kaydedildi.'**
  String get dailyRecordSaved;

  /// No description provided for @openStaff.
  ///
  /// In tr, this message translates to:
  /// **'Personel'**
  String get openStaff;

  /// No description provided for @openDailyRecord.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Kayıt'**
  String get openDailyRecord;

  /// Veresiye defteri ekranı başlığı ve menü
  ///
  /// In tr, this message translates to:
  /// **'Veresiye Defteri'**
  String get creditBook;

  /// No description provided for @addCreditSale.
  ///
  /// In tr, this message translates to:
  /// **'Veresiye Ekle'**
  String get addCreditSale;

  /// No description provided for @editCreditSale.
  ///
  /// In tr, this message translates to:
  /// **'Veresiyeyi Düzenle'**
  String get editCreditSale;

  /// No description provided for @creditTotalAmount.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Tutar (₺)'**
  String get creditTotalAmount;

  /// No description provided for @creditTotalAmountRequired.
  ///
  /// In tr, this message translates to:
  /// **'Toplam tutar zorunludur'**
  String get creditTotalAmountRequired;

  /// No description provided for @creditTotalAmountInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar giriniz'**
  String get creditTotalAmountInvalid;

  /// No description provided for @creditRemainingAmount.
  ///
  /// In tr, this message translates to:
  /// **'Kalan'**
  String get creditRemainingAmount;

  /// No description provided for @creditStatusPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekliyor'**
  String get creditStatusPending;

  /// No description provided for @creditStatusPartial.
  ///
  /// In tr, this message translates to:
  /// **'Kısmi Ödendi'**
  String get creditStatusPartial;

  /// No description provided for @creditStatusPaid.
  ///
  /// In tr, this message translates to:
  /// **'Ödendi'**
  String get creditStatusPaid;

  /// No description provided for @addPayment.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Ekle'**
  String get addPayment;

  /// No description provided for @paymentAmount.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Tutarı (₺)'**
  String get paymentAmount;

  /// No description provided for @paymentAmountRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme tutarı zorunludur'**
  String get paymentAmountRequired;

  /// No description provided for @paymentAmountInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar giriniz'**
  String get paymentAmountInvalid;

  /// No description provided for @paymentAmountExceedsRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme tutarı kalandan fazla olamaz'**
  String get paymentAmountExceedsRemaining;

  /// No description provided for @markAsPaid.
  ///
  /// In tr, this message translates to:
  /// **'Ödendi'**
  String get markAsPaid;

  /// No description provided for @undoPaid.
  ///
  /// In tr, this message translates to:
  /// **'Geri Al'**
  String get undoPaid;

  /// No description provided for @undoPaidConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu ödemeyi geri almak istediğinizden emin misiniz?'**
  String get undoPaidConfirmTitle;

  /// No description provided for @markAsPaidConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm bakiyeyi ödenmiş olarak işaretlemek istiyor musunuz?'**
  String get markAsPaidConfirmTitle;

  /// No description provided for @creditSaleAdded.
  ///
  /// In tr, this message translates to:
  /// **'Veresiye kaydedildi.'**
  String get creditSaleAdded;

  /// No description provided for @creditSaleUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Veresiye güncellendi.'**
  String get creditSaleUpdated;

  /// No description provided for @paymentAdded.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme kaydedildi.'**
  String get paymentAdded;

  /// No description provided for @noCreditSales.
  ///
  /// In tr, this message translates to:
  /// **'Henüz veresiye kaydı yok.'**
  String get noCreditSales;

  /// No description provided for @openCreditBook.
  ///
  /// In tr, this message translates to:
  /// **'Veresiye Defteri'**
  String get openCreditBook;

  /// Ödemeler ekranı başlığı ve menü
  ///
  /// In tr, this message translates to:
  /// **'Ödemeler'**
  String get payments;

  /// No description provided for @openPayments.
  ///
  /// In tr, this message translates to:
  /// **'Ödemeler'**
  String get openPayments;

  /// No description provided for @staffPaymentsTab.
  ///
  /// In tr, this message translates to:
  /// **'Personel'**
  String get staffPaymentsTab;

  /// No description provided for @expensesTab.
  ///
  /// In tr, this message translates to:
  /// **'Giderler'**
  String get expensesTab;

  /// No description provided for @workedDays.
  ///
  /// In tr, this message translates to:
  /// **'Çalışılan Gün'**
  String get workedDays;

  /// No description provided for @accruedWage.
  ///
  /// In tr, this message translates to:
  /// **'Tahakkuk'**
  String get accruedWage;

  /// No description provided for @totalPaid.
  ///
  /// In tr, this message translates to:
  /// **'Ödenen'**
  String get totalPaid;

  /// No description provided for @remainingBalance.
  ///
  /// In tr, this message translates to:
  /// **'Kalan'**
  String get remainingBalance;

  /// No description provided for @addPaymentToStaff.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Kaydet'**
  String get addPaymentToStaff;

  /// No description provided for @paymentToStaffConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu ödemeyi kaydetmek istediğinizden emin misiniz?'**
  String get paymentToStaffConfirmTitle;

  /// No description provided for @staffPaymentAdded.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme kaydedildi.'**
  String get staffPaymentAdded;

  /// No description provided for @noStaffForPayments.
  ///
  /// In tr, this message translates to:
  /// **'Aktif personel bulunamadı.'**
  String get noStaffForPayments;

  /// No description provided for @addExpense.
  ///
  /// In tr, this message translates to:
  /// **'Gider Ekle'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In tr, this message translates to:
  /// **'Gider Düzenle'**
  String get editExpense;

  /// No description provided for @expenseDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get expenseDescription;

  /// No description provided for @expenseDescriptionRequired.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama zorunludur'**
  String get expenseDescriptionRequired;

  /// No description provided for @expenseTotalAmount.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Tutar (₺)'**
  String get expenseTotalAmount;

  /// No description provided for @expenseTotalAmountRequired.
  ///
  /// In tr, this message translates to:
  /// **'Toplam tutar zorunludur'**
  String get expenseTotalAmountRequired;

  /// No description provided for @expenseTotalAmountInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar giriniz'**
  String get expenseTotalAmountInvalid;

  /// No description provided for @expenseAdded.
  ///
  /// In tr, this message translates to:
  /// **'Gider kaydedildi.'**
  String get expenseAdded;

  /// No description provided for @expenseUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Gider güncellendi.'**
  String get expenseUpdated;

  /// No description provided for @expensePaymentAdded.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme kaydedildi.'**
  String get expensePaymentAdded;

  /// No description provided for @expenseMarkAsPaid.
  ///
  /// In tr, this message translates to:
  /// **'Ödendi'**
  String get expenseMarkAsPaid;

  /// No description provided for @expenseMarkAsPaidConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu gideri ödenmiş olarak işaretlemek istiyor musunuz?'**
  String get expenseMarkAsPaidConfirmTitle;

  /// No description provided for @expenseUndoPaid.
  ///
  /// In tr, this message translates to:
  /// **'Geri Al'**
  String get expenseUndoPaid;

  /// No description provided for @expenseUndoPaidConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu ödemeyi geri almak istediğinizden emin misiniz?'**
  String get expenseUndoPaidConfirmTitle;

  /// No description provided for @noExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Henüz gider kaydı yok.'**
  String get noExpenses;

  /// No description provided for @expenseStatusPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekliyor'**
  String get expenseStatusPending;

  /// No description provided for @expenseStatusPartial.
  ///
  /// In tr, this message translates to:
  /// **'Kısmi Ödendi'**
  String get expenseStatusPartial;

  /// No description provided for @expenseStatusPaid.
  ///
  /// In tr, this message translates to:
  /// **'Ödendi'**
  String get expenseStatusPaid;

  /// Bugünün özet kart başlığı
  ///
  /// In tr, this message translates to:
  /// **'Bugünün Özeti'**
  String get todaySummary;

  /// Bugün kayıt yoksa gösterilen metin
  ///
  /// In tr, this message translates to:
  /// **'Bugün kayıt girilmemiş.'**
  String get noRecordToday;

  /// Dashboard özet — çalışan personel sayısı etiketi
  ///
  /// In tr, this message translates to:
  /// **'Çalışan Personel'**
  String get workingStaffCountLabel;

  /// Dashboard hızlı erişim — haftalık özet kartı
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Özet'**
  String get openWeeklySummary;

  /// Dashboard hızlı erişim — aylık özet kartı
  ///
  /// In tr, this message translates to:
  /// **'Aylık Özet'**
  String get openMonthlySummary;

  /// Haftalık özet — önceki hafta butonu tooltip
  ///
  /// In tr, this message translates to:
  /// **'Önceki Hafta'**
  String get prevWeek;

  /// Haftalık özet — sonraki hafta butonu tooltip
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Hafta'**
  String get nextWeek;

  /// No description provided for @weeklyRevenue.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Ciro'**
  String get weeklyRevenue;

  /// No description provided for @weeklyTips.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Bahşiş'**
  String get weeklyTips;

  /// Haftalık özet — dağıtılmamış bahşiş etiket
  ///
  /// In tr, this message translates to:
  /// **'Dağıtılmamış Bahşiş'**
  String get openTips;

  /// Bahşiş dağıtım butonu
  ///
  /// In tr, this message translates to:
  /// **'Dağıtıldı, Kapat'**
  String get distributeTips;

  /// No description provided for @distributeTipsConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bahşiş dağıtımını onaylıyor musunuz?'**
  String get distributeTipsConfirmTitle;

  /// Bahşiş dağıtım onay dialog içeriği
  ///
  /// In tr, this message translates to:
  /// **'{amount} dağıtılmamış bahşiş kasadan düşülecek.'**
  String distributeTipsConfirmBody(String amount);

  /// No description provided for @tipsDistributed.
  ///
  /// In tr, this message translates to:
  /// **'Bahşiş dağıtımı kaydedildi.'**
  String get tipsDistributed;

  /// No description provided for @noRecordsThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta kayıt bulunmuyor.'**
  String get noRecordsThisWeek;

  /// No description provided for @staffDaysTitle.
  ///
  /// In tr, this message translates to:
  /// **'Personel Günleri'**
  String get staffDaysTitle;

  /// No description provided for @noOpenTips.
  ///
  /// In tr, this message translates to:
  /// **'Dağıtılacak bahşiş yok.'**
  String get noOpenTips;

  /// Aylık özet — önceki ay butonu tooltip
  ///
  /// In tr, this message translates to:
  /// **'Önceki Ay'**
  String get prevMonth;

  /// Aylık özet — sonraki ay butonu tooltip
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Ay'**
  String get nextMonth;

  /// Aylık özet — ciro kartı etiketi
  ///
  /// In tr, this message translates to:
  /// **'Aylık Ciro'**
  String get monthlyRevenue;

  /// Aylık özet — kredi kartı kartı etiketi
  ///
  /// In tr, this message translates to:
  /// **'Kredi Kartı'**
  String get monthlyCreditCard;

  /// Aylık özet — kasa masrafı kartı etiketi
  ///
  /// In tr, this message translates to:
  /// **'Kasa Masrafı'**
  String get monthlyCashExpenses;

  /// Aylık özet — patron masrafı kartı etiketi
  ///
  /// In tr, this message translates to:
  /// **'Patron Masrafı'**
  String get monthlyOwnerExpenses;

  /// Aylık özet — personel ücretleri kartı etiketi
  ///
  /// In tr, this message translates to:
  /// **'Personel Ücretleri'**
  String get monthlyStaffWages;

  /// Aylık özet — tahsil bekleyen (ödenmemiş) veresiye toplamı
  ///
  /// In tr, this message translates to:
  /// **'Tahsil Bekleyen Veresiye'**
  String get monthlyOutstandingCredit;

  /// Aylık özet — tahsil edilemeyen veresiye etiketi
  ///
  /// In tr, this message translates to:
  /// **'Tahsil Edilemeyen'**
  String get monthlyUncollectible;

  /// Aylık özet — kâr zarar kartı etiketi
  ///
  /// In tr, this message translates to:
  /// **'Kâr / Zarar'**
  String get monthlyProfitLabel;

  /// Aylık özet — kayıt yoksa gösterilen mesaj
  ///
  /// In tr, this message translates to:
  /// **'Bu ay kayıt bulunmuyor.'**
  String get noRecordsThisMonth;

  /// Aylık özet — veresiye tablosu başlığı
  ///
  /// In tr, this message translates to:
  /// **'Aylık Veresiyeler'**
  String get monthlyCreditSalesTable;

  /// Ayarlar — bildirim bölümü başlığı
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// Ayarlar — günlük hatırlatma aç/kapa switch etiketi
  ///
  /// In tr, this message translates to:
  /// **'Günlük Hatırlatma'**
  String get notificationsEnabled;

  /// Ayarlar — hatırlatma saati seçici etiketi
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma Saati'**
  String get notificationTime;

  /// Günlük hatırlatma bildirim gövdesi
  ///
  /// In tr, this message translates to:
  /// **'Bugünün kasa kaydını girmeyi unutmayın.'**
  String get notificationBody;

  /// Ayarlar — dil bölümü başlığı
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get languageSection;

  /// Dil seçeneği — Türkçe
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// Dil seçeneği — İngilizce
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get english;

  /// Dashboard — ayarlar ikonu tooltip
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get openSettings;

  /// Beklenmeyen bir hata olduğunda gösterilen genel mesaj
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get genericError;

  /// Zorunlu sayısal alan boş bırakıldığında hata (0 girilebilir)
  ///
  /// In tr, this message translates to:
  /// **'Bu alan boş bırakılamaz'**
  String get requiredField;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
