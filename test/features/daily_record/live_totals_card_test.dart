import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/daily_record/presentation/widgets/live_totals_card.dart';

Widget wrap(Widget child) => MaterialApp(
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('günlük kasa ve toplam kasa doğru hesaplanıp gösterilir', (tester) async {
    await tester.pumpWidget(wrap(const LiveTotalsCard(
      revenue: 1000000,
      creditCard: 300000,
      tips: 50000,
      ownerExpenses: 20000,
      cashExpenses: 30000,
      creditSales: 100000,
      previousDayCash: 200000,
    )));

    // dailyCash = 620.000 kuruş -> 6.200 ₺ ; totalCash = 820.000 -> 8.200 ₺
    expect(find.byKey(const Key('dailyCashValue')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('dailyCashValue'))).data,
      '6.200 ₺',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('totalCashValue'))).data,
      '8.200 ₺',
    );
    // toplam masraf = patron + kasa = 50.000 kuruş -> 500 ₺
    expect(
      tester.widget<Text>(find.byKey(const Key('totalExpenseValue'))).data,
      '500 ₺',
    );
  });

  testWidgets('patron masrafı günlük kasayı etkilemez', (tester) async {
    await tester.pumpWidget(wrap(const LiveTotalsCard(
      revenue: 500000,
      creditCard: 0,
      tips: 0,
      ownerExpenses: 9999900, // çok büyük patron masrafı
      cashExpenses: 10000,
      creditSales: 0,
      previousDayCash: 0,
    )));

    // dailyCash = 500.000 - 10.000 = 490.000 -> 4.900 ₺ (patron hariç)
    expect(
      tester.widget<Text>(find.byKey(const Key('dailyCashValue'))).data,
      '4.900 ₺',
    );
  });
}
