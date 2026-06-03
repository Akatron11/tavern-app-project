import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/core/utils/date_utils.dart';
import 'package:gilanli_meyhane/features/daily_record/application/daily_record_providers.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record.dart';
import 'package:gilanli_meyhane/features/daily_record/domain/daily_record_calculator.dart';
import 'package:gilanli_meyhane/features/staff/application/staff_providers.dart';
import 'package:gilanli_meyhane/features/staff/data/mock_staff_repository.dart';
import 'package:gilanli_meyhane/features/weekly_summary/application/weekly_providers.dart';
import 'package:gilanli_meyhane/features/weekly_summary/data/mock_tip_distribution_repository.dart';
import 'package:gilanli_meyhane/features/weekly_summary/presentation/weekly_summary_screen.dart';

DailyRecord _rec(DateTime date, {int revenue = 100000}) {
  final daily = DailyRecordCalculator.dailyCash(
    revenue: revenue,
    creditCard: 0,
    tips: 0,
    cashExpenses: 0,
    creditSales: 0,
  );
  return DailyRecord(
    id: dayKey(date),
    date: date,
    revenue: revenue,
    creditCard: 0,
    tips: 0,
    ownerExpenses: 0,
    cashExpenses: 0,
    creditSales: 0,
    previousDayCash: 0,
    dailyCash: daily,
    totalCash: daily,
  );
}

Widget _wrap({
  MockDailyRecordRepository? dailyRepo,
  MockStaffRepository? staffRepo,
  MockTipDistributionRepository? tipRepo,
}) {
  return ProviderScope(
    overrides: [
      dailyRecordRepositoryProvider
          .overrideWithValue(dailyRepo ?? MockDailyRecordRepository()),
      staffRepositoryProvider
          .overrideWithValue(staffRepo ?? MockStaffRepository()),
      tipDistributionRepositoryProvider
          .overrideWithValue(tipRepo ?? MockTipDistributionRepository()),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('tr'),
      home: WeeklySummaryScreen(),
    ),
  );
}

void main() {
  testWidgets('AppBar başlığı ve navigasyon butonları görünür', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('Haftalık Özet'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('Kayıt yoksa noRecordsThisWeek mesajı görünür', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Bu hafta kayıt bulunmuyor.'), findsOneWidget);
  });

  testWidgets('Kayıt varsa noRecordsThisWeek mesajı görünmez', (tester) async {
    final repo = MockDailyRecordRepository();
    final monday = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    final rec = _rec(DateTime(monday.year, monday.month, monday.day),
        revenue: 500000);
    repo.store[rec.id] = rec;

    await tester.pumpWidget(_wrap(dailyRepo: repo));
    await tester.pumpAndSettle();

    expect(find.text('Bu hafta kayıt bulunmuyor.'), findsNothing);
  });

  testWidgets('Açık bahşiş yoksa noOpenTips kartı görünür', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Dağıtılacak bahşiş yok.'), findsOneWidget);
  });
}
