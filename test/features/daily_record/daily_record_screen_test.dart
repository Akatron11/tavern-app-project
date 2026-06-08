import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/credit_book/application/credit_book_providers.dart';
import 'package:gilanli_meyhane/features/credit_book/data/credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/credit_book/data/mock_credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/dashboard/application/dashboard_providers.dart';
import 'package:gilanli_meyhane/features/daily_record/application/daily_record_providers.dart';
import 'package:gilanli_meyhane/features/daily_record/data/daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/presentation/daily_record_screen.dart';
import 'package:gilanli_meyhane/features/daily_record/presentation/widgets/live_totals_card.dart';
import 'package:gilanli_meyhane/features/staff/application/staff_providers.dart';
import 'package:gilanli_meyhane/features/staff/data/mock_staff_repository.dart';
import 'package:gilanli_meyhane/features/staff/data/staff_repository.dart';

Widget buildApp({
  required DailyRecordRepository dailyRepo,
  required CreditSaleRepository creditRepo,
  required StaffRepository staffRepo,
}) {
  return ProviderScope(
    overrides: [
      dailyRecordRepositoryProvider.overrideWithValue(dailyRepo),
      creditSaleRepositoryProvider.overrideWithValue(creditRepo),
      staffRepositoryProvider.overrideWithValue(staffRepo),
    ],
    child: const MaterialApp(
      locale: Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: DailyRecordScreen(),
    ),
  );
}

void main() {
  testWidgets('ciro girilince günlük kasa canlı güncellenir', (tester) async {
    // Tüm ListView içeriği (alanlar + canlı toplam kartı) tek viewport'a
    // sığsın diye uzun bir test yüzeyi ver — aksi halde kart "fold" altında
    // lazily build edilmez.
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp(
      dailyRepo: MockDailyRecordRepository(),
      creditRepo: MockCreditSaleRepository(),
      staffRepo: MockStaffRepository(),
    ));
    await tester.pumpAndSettle();

    // Başlangıçta günlük kasa 0 ₺
    expect(
      tester.widget<Text>(find.byKey(const Key('dailyCashValue'))).data,
      '0 ₺',
    );

    // Toplam Ciro alanına 10000 (lira) gir -> 1.000.000 kuruş
    final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.revenue),
      '10000',
    );
    await tester.pump();

    // Günlük kasa = 10.000 ₺ ; canlı kart güncellenmeli
    expect(find.byType(LiveTotalsCard), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('dailyCashValue'))).data,
      '10.000 ₺',
    );
  });

  testWidgets('BUG-02: zorunlu alanlar boşken kayıt engellenir', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dailyRepo = MockDailyRecordRepository();
    await tester.pumpWidget(buildApp(
      dailyRepo: dailyRepo,
      creditRepo: MockCreditSaleRepository(),
      staffRepo: MockStaffRepository(),
    ));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('tr'));

    // Hiçbir alan doldurulmadan Kaydet'e bas.
    await tester.tap(find.widgetWithText(ElevatedButton, l10n.save));
    await tester.pumpAndSettle();

    // Zorunlu alan hatası görünür; onay dialog'u açılmaz; kayıt yazılmaz.
    expect(find.text(l10n.requiredField), findsWidgets);
    expect(find.text(l10n.saveConfirmTitle), findsNothing);
    expect(dailyRepo.store, isEmpty);
  });

  testWidgets('BUG-03: kayıt sonrası dashboard bugün kaydı tazelenir',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dailyRepo = MockDailyRecordRepository();
    final container = ProviderContainer(overrides: [
      dailyRecordRepositoryProvider.overrideWithValue(dailyRepo),
      creditSaleRepositoryProvider.overrideWithValue(MockCreditSaleRepository()),
      staffRepositoryProvider.overrideWithValue(MockStaffRepository()),
    ]);
    addTearDown(container.dispose);

    // Başlangıçta bugün kaydı yok.
    expect(await container.read(todayRecordProvider.future), isNull);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DailyRecordScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
    await tester.enterText(
        find.widgetWithText(TextFormField, l10n.revenue), '1000');
    await tester.enterText(
        find.widgetWithText(TextFormField, l10n.creditCardTotal), '0');
    await tester.enterText(
        find.widgetWithText(TextFormField, l10n.ownerExpense), '0');
    await tester.enterText(
        find.widgetWithText(TextFormField, l10n.cashExpense), '0');
    await tester.enterText(
        find.widgetWithText(TextFormField, l10n.previousDayCash), '0');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, l10n.save));
    await tester.pumpAndSettle();
    // Onay dialog'unda "Onayla".
    await tester.tap(find.widgetWithText(TextButton, l10n.confirm));
    await tester.pumpAndSettle();

    // Invalidate sonrası bugün kaydı görünür (BUG-03).
    final rec = await container.read(todayRecordProvider.future);
    expect(rec, isNotNull);
    expect(rec!.revenue, 100000);
  });
}
