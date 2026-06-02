import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/app/router.dart';
import 'package:gilanli_meyhane/core/l10n/generated/app_localizations.dart';
import 'package:gilanli_meyhane/features/auth/application/auth_providers.dart';
import 'package:gilanli_meyhane/features/auth/data/mock_auth_repository.dart';
import 'package:gilanli_meyhane/features/auth/presentation/login_screen.dart';
import 'package:gilanli_meyhane/app/placeholder_home_screen.dart';

Widget buildTestApp(MockAuthRepository mockRepo) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
    child: Consumer(
      builder: (context, ref, _) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          routerConfig: router,
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    ),
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('kimlik doğrulanmamışsa login ekranı gösterilir', (tester) async {
      final mockRepo = MockAuthRepository();

      await tester.pumpWidget(buildTestApp(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      mockRepo.dispose();
    });

    testWidgets('hatalı giriş hata snackbar gösterir', (tester) async {
      final mockRepo = MockAuthRepository()..shouldThrowOnSignIn = true;

      await tester.pumpWidget(buildTestApp(mockRepo));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'yanlis@test.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'yanlissifre',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);

      mockRepo.dispose();
    });

    testWidgets('başarılı giriş ana sayfaya yönlendirir', (tester) async {
      final mockRepo = MockAuthRepository();

      await tester.pumpWidget(buildTestApp(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).first,
        'kemal@gilanli.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'sifre123',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(PlaceholderHomeScreen), findsOneWidget);

      mockRepo.dispose();
    });
  });
}
