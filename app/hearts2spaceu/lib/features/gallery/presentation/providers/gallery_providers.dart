import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/http_gallery_repository.dart';
import '../../domain/album.dart';
import '../../domain/gallery_repository.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return HttpGalleryRepository();
});

final albumsProvider = FutureProvider<List<Album>>(
  (ref) => ref.watch(galleryRepositoryProvider).getAlbums(),
  // No automatic retry, matching the rest of the app: the UI offers an
  // explicit Retry.
  retry: (_, _) => null,
);

/// One album by id, or null when it is not in the loaded list.
///
/// Lets the grid and viewer pages select without refetching — they read the
/// same cached [albumsProvider].
final albumByIdProvider = Provider.family<Album?, String>((ref, id) {
  final albums = ref.watch(albumsProvider).asData?.value;
  if (albums == null) return null;
  for (final album in albums) {
    if (album.id == id) return album;
  }
  return null;
});
