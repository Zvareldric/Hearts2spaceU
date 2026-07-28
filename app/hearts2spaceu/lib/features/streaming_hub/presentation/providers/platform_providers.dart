import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/asset_platform_repository.dart';
import '../../domain/grouped_platforms.dart';
import '../../domain/official_platform.dart';
import '../../domain/platform_repository.dart';

/// Provides the [PlatformRepository] implementation.
final platformRepositoryProvider = Provider<PlatformRepository>((ref) {
  return const AssetPlatformRepository();
});

/// Loads the official platforms, grouped by category and ready to render.
final groupedPlatformsProvider =
    FutureProvider<Map<String, List<OfficialPlatform>>>(
      (ref) async {
        final repository = ref.watch(platformRepositoryProvider);
        final platforms = await repository.getPlatforms();
        return groupByCategory(platforms);
      },
      // No automatic retry, matching the rest of the app: the source is a
      // local asset, so a failure is not transient.
      retry: (_, _) => null,
    );
