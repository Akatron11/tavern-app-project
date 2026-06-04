import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gilanli_meyhane/features/credit_book/application/credit_book_providers.dart';
import 'package:gilanli_meyhane/features/credit_book/data/mock_credit_sale_repository.dart';
import 'package:gilanli_meyhane/features/credit_book/domain/credit_sale.dart';
import 'package:gilanli_meyhane/features/daily_record/application/daily_record_providers.dart';
import 'package:gilanli_meyhane/features/daily_record/data/mock_daily_record_repository.dart';

void main() {
  late MockDailyRecordRepository dailyRepo;
  late MockCreditSaleRepository creditRepo;
  late ProviderContainer container;

  setUp(() {
    dailyRepo = MockDailyRecordRepository();
    creditRepo = MockCreditSaleRepository();
    container = ProviderContainer(overrides: [
      dailyRecordRepositoryProvider.overrideWithValue(dailyRepo),
      creditSaleRepositoryProvider.overrideWithValue(creditRepo),
    ]);
    addTearDown(container.dispose);
  });

  Future<void> save({
    required DateTime date,
    int revenue = 0,
    int creditCard = 0,
    int tips = 0,
    int ownerExpenses = 0,
    int cashExpenses = 0,
    int creditSales = 0,
    String creditCustomerName = '',
    int previousDayCash = 0,
    List<String> workingStaffIds = const [],
  }) {
    return container.read(dailyRecordControllerProvider.notifier).saveRecord(
          date: date,
          revenue: revenue,
          creditCard: creditCard,
          tips: tips,
          ownerExpenses: ownerExpenses,
          cashExpenses: cashExpenses,
          creditSales: creditSales,
          creditCustomerName: creditCustomerName,
          previousDayCash: previousDayCash,
          workingStaffIds: workingStaffIds,
          notes: '',
        );
  }

  test('kayıt dayKey ile saklanır; dailyCash/totalCash hesaplanır (patron hariç)', () async {
    await save(
      date: DateTime(2026, 6, 3, 14, 30),
      revenue: 1000000,
      creditCard: 300000,
      tips: 50000,
      ownerExpenses: 20000, // kasayı ETKİLEMEMELİ
      cashExpenses: 30000,
      creditSales: 100000,
      previousDayCash: 200000,
      workingStaffIds: ['s1', 's2'],
    );

    final rec = dailyRepo.store['2026-06-03'];
    expect(rec, isNotNull);
    expect(rec!.dailyCash, 620000); // 1.000.000 - 300.000 + 50.000 - 30.000 - 100.000
    expect(rec.totalCash, 820000);
    expect(rec.workingStaffIds, ['s1', 's2']);
    expect(rec.date.hour, 0); // gece yarısına normalize
  });

  test('veresiye>0 ise bağlı CreditSale oluşturulur ve id kayda yazılır', () async {
    await save(
      date: DateTime(2026, 6, 3),
      revenue: 100000,
      creditSales: 40000,
      creditCustomerName: 'Ahmet',
    );

    expect(creditRepo.store.length, 1);
    final sale = creditRepo.store.values.first;
    expect(sale.customerName, 'Ahmet');
    expect(sale.totalAmount, 40000);
    expect(sale.remainingAmount, 40000);
    expect(sale.status, CreditStatus.pending);
    expect(sale.linkedDailyRecordId, '2026-06-03');

    final rec = dailyRepo.store['2026-06-03']!;
    expect(rec.linkedCreditSaleId, sale.id);
  });

  test('düzenlemede veresiye değişince bağlı CreditSale mutabık kılınır (yeni doküman yaratılmaz)', () async {
    await save(date: DateTime(2026, 6, 3), creditSales: 40000, creditCustomerName: 'Ahmet');
    await save(date: DateTime(2026, 6, 3), creditSales: 60000, creditCustomerName: 'Ahmet');

    expect(creditRepo.store.length, 1); // hâlâ tek doküman
    final sale = creditRepo.store.values.first;
    expect(sale.totalAmount, 60000);
    expect(sale.remainingAmount, 60000);
  });

  test('BUG-01: veresiye sıfırlanınca (ödeme yoksa) bağlı CreditSale silinir — "ödendi" yapılmaz', () async {
    await save(date: DateTime(2026, 6, 3), creditSales: 40000, creditCustomerName: 'Ahmet');
    await save(date: DateTime(2026, 6, 3), creditSales: 0);

    // Yanlış girilen veresiye düzeltildi → "ödendi" değil, kayıt tamamen silinir.
    expect(creditRepo.store, isEmpty);
    expect(dailyRepo.store['2026-06-03']!.linkedCreditSaleId, isNull);
  });

  test('veresiye sıfırlansa da ödeme geçmişi varsa kayıt korunur', () async {
    await save(date: DateTime(2026, 6, 3), creditSales: 40000, creditCustomerName: 'Ahmet');
    final saleId = dailyRepo.store['2026-06-03']!.linkedCreditSaleId!;
    // Krediye kısmi ödeme işle (credit book üzerinden yapılmış gibi).
    await creditRepo.update(creditRepo.store[saleId]!.copyWith(
      payments: [CreditPayment(amount: 10000, date: DateTime(2026, 6, 3))],
      remainingAmount: 30000,
      status: CreditStatus.partial,
    ));

    await save(date: DateTime(2026, 6, 3), creditSales: 0);

    // Ödeme geçmişi olan kayıt silinmez.
    expect(creditRepo.store.length, 1);
    expect(creditRepo.store.values.first.payments, isNotEmpty);
  });

  test('veresiye yoksa CreditSale oluşturulmaz', () async {
    await save(date: DateTime(2026, 6, 3), revenue: 100000);
    expect(creditRepo.store, isEmpty);
    expect(dailyRepo.store['2026-06-03']!.linkedCreditSaleId, isNull);
  });
}
