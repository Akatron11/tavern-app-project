import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/shared/widgets/money_input_field.dart';

void main() {
  Widget harness(TextEditingController ctrl, {Locale locale = const Locale('tr')}) =>
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: Scaffold(
          body: MoneyInputField(controller: ctrl, label: 'Tutar'),
        ),
      );

  testWidgets('BUG-15: yazılınca binlik ayraç eklenir (TR), kurusOf doğru',
      (tester) async {
    final ctrl = TextEditingController();
    await tester.pumpWidget(harness(ctrl));

    await tester.enterText(find.byType(TextField), '6000');
    await tester.pump();

    expect(find.text('6.000'), findsOneWidget);
    expect(MoneyInputField.kurusOf(ctrl), 600000); // 6.000 ₺ → kuruş
  });

  testWidgets('BUG-15: programatik yüklenen değer de gruplanır', (tester) async {
    final ctrl = TextEditingController();
    await tester.pumpWidget(harness(ctrl));

    ctrl.text = '1000000';
    await tester.pump();

    expect(find.text('1.000.000'), findsOneWidget);
    expect(MoneyInputField.kurusOf(ctrl), 100000000);
  });

  testWidgets('BUG-15: EN locale virgülle gruplar', (tester) async {
    final ctrl = TextEditingController();
    await tester.pumpWidget(harness(ctrl, locale: const Locale('en')));

    await tester.enterText(find.byType(TextField), '6000');
    await tester.pump();

    expect(find.text('6,000'), findsOneWidget);
    expect(MoneyInputField.kurusOf(ctrl), 600000);
  });

  group('liraValue (validator yardımcısı — BUG-15 regresyonu)', () {
    test('ayraçlı metni doğru parse eder, ham int.tryParse bozulmaz', () {
      expect(MoneyInputField.liraValue('6.000'), 6000);
      expect(MoneyInputField.liraValue('1.234.567'), 1234567);
      expect(MoneyInputField.liraValue('6,000'), 6000); // EN ayraç da yok sayılır
      expect(MoneyInputField.liraValue('0'), 0);
      expect(MoneyInputField.liraValue(''), isNull);
      expect(MoneyInputField.liraValue(null), isNull);
    });
  });
}
