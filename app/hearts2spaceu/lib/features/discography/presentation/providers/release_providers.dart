import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/asset_release_repository.dart';
import '../../domain/newest_first.dart';
import '../../domain/release.dart';
import '../../domain/release_repository.dart';

/// Provides the [ReleaseRepository] implementation.
///
/// The feature depends on this — not the concrete class — so tests can
/// `override` it with a fake and never touch an asset.
final releaseRepositoryProvider = Provider<ReleaseRepository>((ref) {
  return const AssetReleaseRepository();
});

/// The discography, newest first.
final discographyProvider = FutureProvider<List<Release>>(
  (ref) async {
    final repository = ref.watch(releaseRepositoryProvider);
    return newestFirst(await repository.getReleases());
  },
  // No automatic retry: the source is a local asset, so a failure is not
  // transient and the UI offers an explicit Retry.
  retry: (_, _) => null,
);

/// One release by id, from the already-loaded list — no refetch.
final releaseByIdProvider = Provider.family<Release?, String>((ref, id) {
  final releases = ref.watch(discographyProvider).asData?.value ?? const [];
  return releases.where((release) => release.id == id).firstOrNull;
});
