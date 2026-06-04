import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/credit_book/presentation/widgets/payment_dialog.dart';

void main() {
  int? result;

  Widget harness() {
    result = null;
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('tr'),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showPaymentDialog(context, remainingAmount: 100000);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
  }

  testWidgets('BUG-04: onaylanınca hata fırlatmaz ve tutarı döndürür',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '500');
    await tester.tap(find.text('Onayla'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(result, 50000); // 500 ₺ → kuruş
  });

  testWidgets('BUG-04: iptal edilince hata fırlatmaz', (tester) async {
    await tester.pumpWidget(harness());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(result, isNull);
  });
}
