import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/payments/application/payments_providers.dart';
import 'package:gilanli_meyhane/features/payments/domain/payroll_summary.dart';
import 'package:gilanli_meyhane/features/payments/domain/pending_expense.dart';
import 'package:gilanli_meyhane/features/payments/domain/staff_payment.dart';
import 'package:gilanli_meyhane/features/payments/presentation/payments_screen.dart';

void main() {
  testWidgets('PaymentsScreen: Personel sekmesi aktif, Giderler sekmesine geçilebilir',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffPayrollRowsProvider
              .overrideWith((_) async => <StaffPayrollRow>[]),
          expensesStreamProvider
              .overrideWith((_) => Stream.value(<PendingExpense>[])),
          staffPaymentsStreamProvider
              .overrideWith((_) => Stream.value(<StaffPayment>[])),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PaymentsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // TabBar görünmeli
    expect(find.byType(TabBar), findsOneWidget);

    // Giderler sekmesine geç
    await tester.tap(find.text('Giderler'));
    await tester.pumpAndSettle();

    // Gider yok mesajı görünmeli
    expect(find.text('Henüz gider kaydı yok.'), findsOneWidget);
  });
}
