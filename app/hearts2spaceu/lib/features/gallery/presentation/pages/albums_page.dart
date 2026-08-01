import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/glass/glass_nav_bar.dart';
import '../../../../app/widgets/layout/page_heading.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../providers/gallery_providers.dart';
import '../widgets/album_card.dart';

/// UC-1 — the albums. A tab root, so it carries a large inline title instead of
/// an AppBar (Design System V2).
class AlbumsPage extends ConsumerWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                0,
              ),
              child: PageHeading(title: 'Gallery'),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.base),
                child: albumsAsync.when(
                  loading: () => const LoadingView(key: ValueKey('loading')),
                  error: (error, _) => ErrorView(
                    key: const ValueKey('error'),
                    message:
                        "Couldn't reach the gallery.\nCheck your connection.",
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
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        0,
                        AppSpacing.screenPadding,
                        // Clear the floating nav bar this grid scrolls under.
                        GlassNavBar.reservedSpace,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            // Cover plus two lines of text underneath.
                            childAspectRatio: 0.82,
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
            ),
          ],
        ),
      ),
    );
  }
}
