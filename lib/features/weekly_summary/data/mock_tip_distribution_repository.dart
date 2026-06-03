import '../domain/tip_distribution.dart';
import 'tip_distribution_repository.dart';

class MockTipDistributionRepository implements TipDistributionRepository {
  final Map<String, TipDistribution> store = {};
  int _counter = 0;

  @override
  Future<String> add(TipDistribution dist) async {
    final id = 'dist_${_counter++}';
    store[id] = dist.copyWith(id: id);
    return id;
  }

  @override
  Future<List<TipDistribution>> getAll() async => store.values.toList();
}
