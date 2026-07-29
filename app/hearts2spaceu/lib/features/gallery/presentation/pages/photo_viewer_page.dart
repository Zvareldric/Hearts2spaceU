import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../collection/domain/favorite.dart';
import '../../../collection/presentation/widgets/favorite_button.dart';
import '../providers/gallery_providers.dart';
import '../widgets/remote_image.dart';

/// UC-3 — one photo, full screen, swipeable within its album.
class PhotoViewerPage extends ConsumerStatefulWidget {
  const PhotoViewerPage({
    super.key,
    required this.albumId,
    required this.initialIndex,
  });

  final String albumId;
  final int initialIndex;

  @override
  ConsumerState<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends ConsumerState<PhotoViewerPage> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final album = ref.watch(albumByIdProvider(widget.albumId));

    if (album == null || album.photos.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(message: 'Photo not found.'),
      );
    }

    final photo = album.photos[_index.clamp(0, album.photos.length - 1)];

    return Scaffold(
      // Dark surround so the photo, not the chrome, is what you look at.
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          '${_index + 1} / ${album.photos.length}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        actions: [
          // A photo id is only unique inside its album, so the favourite key
          // carries both.
          FavoriteButton(
            type: Favorite.typePhoto,
            id: '${album.id}/${photo.id}',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: album.photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, index) {
                final current = album.photos[index];
                return Hero(
                  tag: 'photo-${album.id}-${current.id}',
                  child: RemoteImage(url: current.url, fit: BoxFit.contain),
                );
              },
            ),
          ),
          if (photo.caption != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              child: Text(
                photo.caption!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }
}
