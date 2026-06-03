import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/settings/application/settings_providers.dart';
import 'package:gilanli_meyhane/features/settings/data/mock_notification_service.dart';
import 'package:gilanli_meyhane/features/settings/presentation/settings_screen.dart';
import 'package:gilanli_meyhane/shared/providers/preferences_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _wrap(MockNotificationService service) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      notificationServiceProvider.overrideWithValue(service),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('tr'),
      home: SettingsScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dil seçenekleri, bildirim switch ve çıkış görünür',
      (tester) async {
    await tester.pumpWidget(await _wrap(MockNotificationService()));
    await tester.pump();

    expect(find.text('Türkçe'), findsOneWidget);
    expect(find.text('İngilizce'), findsOneWidget);
    expect(find.text('Günlük Hatırlatma'), findsOneWidget);
    expect(find.text('Çıkış Yap'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
  });

  testWidgets('switch kapatınca cancelAll çağrılır', (tester) async {
    final service = MockNotificationService();
    await tester.pumpWidget(await _wrap(service));
    await tester.pump();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(service.cancelCount, 1);
  });
}
