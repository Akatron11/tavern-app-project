import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gilanli_meyhane/app/app.dart';
import 'package:gilanli_meyhane/features/auth/application/auth_providers.dart';
import 'package:gilanli_meyhane/features/auth/data/mock_auth_repository.dart';
import 'package:gilanli_meyhane/features/settings/application/settings_providers.dart';
import 'package:gilanli_meyhane/features/settings/data/mock_notification_service.dart';
import 'package:gilanli_meyhane/shared/providers/preferences_providers.dart';

void main() {
  testWidgets('giriş yapılmışsa Türkçe karşılama metni görünür', (tester) async {
    final mockRepo = MockAuthRepository(initialUid: 'test-uid');
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationServiceProvider
              .overrideWithValue(MockNotificationService()),
        ],
        child: const GilanliApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Merhabalar Kemal Bey'), findsOneWidget);
    expect(find.text('Gilanlı Köy Meyhanesi'), findsOneWidget);

    mockRepo.dispose();
  });
}
