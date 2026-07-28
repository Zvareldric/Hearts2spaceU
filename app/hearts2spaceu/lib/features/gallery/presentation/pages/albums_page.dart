import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../providers/gallery_providers.dart';
import '../widgets/album_card.dart';

/// UC-1 — the albums.
class AlbumsPage extends ConsumerWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.base),
        child: albumsAsync.when(
          loading: () => const LoadingView(key: ValueKey('loading')),
          error: (error, _) => ErrorView(
            key: const ValueKey('error'),
            message: "Couldn't reach the gallery.\nCheck your connection.",
            onRetry: () => ref.invalidate(albumsProvider),
          ),
          data: (albums) {
            if (albums.isEmpty) {
              return const EmptyView(
                key: ValueKey('empty'),
                message: 'No albums yet.',
                icon: Icons.photo_library_rounded,
              );
            }
            return GridView.builder(
              key: const ValueKey('data'),
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.lg,
                // Square cover plus two lines of text underneath.
                childAspectRatio: 0.78,
              ),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return StaggeredItem(
                  index: index,
                  child: AlbumCard(
                    album: album,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.album, arguments: album.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
