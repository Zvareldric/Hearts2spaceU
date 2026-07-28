import 'album.dart';

/// Contract for retrieving the photo albums.
abstract interface class GalleryRepository {
  /// Loads every album. Throws if the source cannot be reached or parsed.
  Future<List<Album>> getAlbums();
}
