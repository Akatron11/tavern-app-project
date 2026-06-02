import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/credit_book/data/credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/credit_book/data/mock_credit_sale_repository.dart';
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
}
