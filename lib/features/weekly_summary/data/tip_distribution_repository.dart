import '../domain/tip_distribution.dart';

abstract class TipDistributionRepository {
  Future<String> add(TipDistribution dist);
  Future<List<TipDistribution>> getAll();
}
