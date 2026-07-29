import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../awards/presentation/providers/award_providers.dart';
import '../../domain/career_stats.dart';

/// The career summary, derived from the awards already on file.
///
/// Reads `awardRepositoryProvider` rather than owning a repository: the source
/// is literally the same file, and a second repository for it would add code
/// without adding capability (docs/specs/statistics.md §5).
final careerStatsProvider = FutureProvider<CareerStats>(
  (ref) async {
    final awards = await ref.watch(awardRepositoryProvider).getAwards();
    return computeStats(awards);
  },
  // No automatic retry: the source is a local asset, so a failure is not
  // transient and the UI offers an explicit Retry.
  retry: (_, _) => null,
);
