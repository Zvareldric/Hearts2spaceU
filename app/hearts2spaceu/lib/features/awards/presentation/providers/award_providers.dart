import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/asset_award_repository.dart';
import '../../domain/award_repository.dart';
import '../../domain/year_groups.dart';

/// Provides the [AwardRepository] implementation.
final awardRepositoryProvider = Provider<AwardRepository>((ref) {
  return const AssetAwardRepository();
});

/// Loads the awards grouped by year, most recent first.
final awardsByYearProvider = FutureProvider<List<AwardYear>>(
  (ref) async {
    final repository = ref.watch(awardRepositoryProvider);
    final awards = await repository.getAwards();
    return groupByYear(awards);
  },
  // No automatic retry: the source is a local asset, so a failure is not
  // transient and the UI offers an explicit Retry.
  retry: (_, _) => null,
);
