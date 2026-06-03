import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/credit_book/application/credit_book_providers.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';
import 'package:gilanli_meyhane/features/credit_book/presentation/credit_list_screen.dart';

void main() {
  testWidgets('CreditListScreen: kayıt varsa müşteri adı görünür',
      (WidgetTester tester) async {
    final sales = [
      CreditSale(
        id: '1',
        customerName: 'Test Müşteri',
        totalAmount: 100000,
        remainingAmount: 100000,
        date: DateTime(2026, 1, 1),
        status: CreditStatus.pending,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          creditSaleListProvider.overrideWith((_) => Stream.value(sales)),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CreditListScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Test Müşteri'), findsOneWidget);
  });
}
