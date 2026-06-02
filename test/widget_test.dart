import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gilanli_meyhane/app/app.dart';
import 'package:gilanli_meyhane/features/auth/application/auth_providers.dart';
import 'package:gilanli_meyhane/features/auth/data/mock_auth_repository.dart';

void main() {
  testWidgets('giriş yapılmışsa Türkçe karşılama metni görünür', (tester) async {
    final mockRepo = MockAuthRepository(initialUid: 'test-uid');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: const GilanliApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Merhabalar Kemal Bey'), findsOneWidget);
    expect(find.text('Gilanlı Köy Meyhanesi'), findsOneWidget);

    mockRepo.dispose();
  });
}
