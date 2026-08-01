import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/layout/page_heading.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../routes/app_routes.dart';
import '../../../collection/domain/favorite.dart';
import '../../../collection/presentation/widgets/favorite_button.dart';
import '../providers/gallery_providers.dart';
import '../widgets/remote_image.dart';

/// UC-2 — the photos in one album, as a grid.
class AlbumPage extends ConsumerWidget {
  const AlbumPage({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(albumByIdProvider(albumId));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                0,
              ),
              child: PageHeading.sub(
                title: album?.title ?? 'Album',
                subtitle: album?.year?.toString(),
              ),
            ),
            Expanded(
              child: album == null
                  ? const EmptyView(message: 'Album not found.')
                  // Two across, not three: each tile now carries a caption and
                  // a save button, which need the width to stay legible and
                  // tappable.
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        0,
                        AppSpacing.screenPadding,
                        AppSpacing.xl,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: 0.82,
                          ),
                      itemCount: album.photos.length,
                      itemBuilder: (context, index) {
                        final photo = album.photos[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.photoViewer,
                            arguments: (albumId, index),
                          ),
                          child: Hero(
                            tag: 'photo-${album.id}-${photo.id}',
                            child: ClipRRect(
                              borderRadius: AppRadius.lgRadius,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  RemoteImage(url: photo.url),
                                  // A photo id is only unique inside its album,
                                  // so the favourite key carries both (see
                                  // CollectionPage).
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: _HeartBubble(
                                      albumId: albumId,
                                      photoId: photo.id,
                                    ),
                                  ),
                                  if (photo.caption case final caption?)
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: _CaptionStrip(caption: caption),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The save button as it appears over a photo — a frosted bubble, because a
/// bare icon disappears against a light or busy image.
class _HeartBubble extends StatelessWidget {
  const _HeartBubble({required this.albumId, required this.photoId});

  final String albumId;
  final String photoId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        shape: BoxShape.circle,
      ),
      child: FavoriteButton(type: Favorite.typePhoto, id: '$albumId/$photoId'),
    );
  }
}

/// The caption, over a scrim so it stays readable on a pale photo.
class _CaptionStrip extends StatelessWidget {
  const _CaptionStrip({required this.caption});

  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
        ),
      ),
      child: Text(
        caption,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
