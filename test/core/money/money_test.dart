import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/core/money/money.dart';

void main() {
  group('liraToKurus', () {
    test('whole lira çarpı 100 kuruş döner', () {
      expect(liraToKurus(0), 0);
      expect(liraToKurus(1), 100);
      expect(liraToKurus(12500), 1250000);
    });

    test('negatif lira için işaret korunur', () {
      expect(liraToKurus(-100), -10000);
    });
  });

  group('kurusToLira', () {
    test('kuruş tam liraya çevrilir', () {
      expect(kurusToLira(0), 0);
      expect(kurusToLira(100), 1);
      expect(kurusToLira(1250000), 12500);
    });

    test('negatif kuruş için işaret korunur', () {
      expect(kurusToLira(-10000), -100);
    });

    test('liraToKurus ile gidiş-dönüş tutarlı', () {
      expect(kurusToLira(liraToKurus(987)), 987);
    });
  });
}
