import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gilanli_meyhane/app/app.dart';

void main() {
  testWidgets('uygulama açılır ve Türkçe karşılama metnini gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: GilanliApp()));
    await tester.pumpAndSettle();

    expect(find.text('Merhabalar Kemal Bey'), findsOneWidget);
    expect(find.text('Gilanlı Köy Meyhanesi'), findsOneWidget);
  });
}
