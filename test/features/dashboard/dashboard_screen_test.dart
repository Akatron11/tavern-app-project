import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/dashboard/application/dashboard_providers.dart';
import 'package:gilanli_meyhane/features/dashboard/presentation/dashboard_screen.dart';
import 'package:gilanli_meyhane/features/dashboard/presentation/widgets/today_summary_card.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';

final _record = DailyRecord(
  id: '2026-06-03',
  date: DateTime(2026, 6, 3),
  revenue: 1000000,
  creditCard: 300000,
  tips: 50000,
  ownerExpenses: 20000,
  cashExpenses: 30000,
  creditSales: 0,
  previousDayCash: 0,
  dailyCash: 720000,
  totalCash: 720000,
  workingStaffIds: const ['s1', 's2', 's3'],
);

void main() {
  group('DashboardScreen —', () {
    testWidgets('selamlama ve tüm navigasyon kartları görünür', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayRecordProvider.overrideWith((_) async => null),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Merhabalar Kemal Bey'), findsOneWidget);
      expect(find.text('Günlük Kayıt'), findsOneWidget);
      expect(find.text('Haftalık Özet'), findsOneWidget);
      expect(find.text('Aylık Özet'), findsOneWidget);
      expect(find.text('Personel'), findsOneWidget);
      expect(find.text('Veresiye Defteri'), findsOneWidget);
      expect(find.text('Ödemeler'), findsOneWidget);
    });
  });

  group('TodaySummaryCard —', () {
    testWidgets('kayıt yoksa noRecordToday mesajı gösterilir', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayRecordProvider.overrideWith((_) async => null),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(body: TodaySummaryCard()),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Bugün kayıt girilmemiş.'), findsOneWidget);
    });

    testWidgets('kayıt varsa dailyCash ve günün cirosu gösterilir (İYİ-01)',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayRecordProvider.overrideWith((_) async => _record),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(body: TodaySummaryCard()),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Günlük Kasa'), findsOneWidget);
      expect(find.text('Toplam Ciro'), findsOneWidget);
      expect(find.text('10.000 ₺'), findsOneWidget); // günün cirosu
    });
  });
}
