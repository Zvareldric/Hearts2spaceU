import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../routes/app_routes.dart';
import '../providers/gallery_providers.dart';
import '../widgets/remote_image.dart';

/// UC-2 — the photos in one album, as a grid.
class AlbumPage extends ConsumerWidget {
  const AlbumPage({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(albumByIdProvider(albumId));

    if (album == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(message: 'Album not found.'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(album.title)),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemCount: album.photos.length,
        itemBuilder: (context, index) {
          final photo = album.photos[index];
          return GestureDetector(
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.photoViewer, arguments: (albumId, index)),
            child: Hero(
              tag: 'photo-${album.id}-${photo.id}',
              child: ClipRRect(
                borderRadius: AppRadius.smRadius,
                child: RemoteImage(url: photo.url),
              ),
            ),
          );
        },
      ),
    );
  }
}
