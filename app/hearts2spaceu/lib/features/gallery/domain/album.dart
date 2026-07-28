import 'photo.dart';

/// A set of photos from one era or release.
class Album {
  const Album({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.photos,
    this.year,
  });

  final String id;

  /// Era or release name, e.g. `Lemon Tang`.
  final String title;

  /// Cover image. Always `https` — enforced when parsing.
  final String coverUrl;

  /// Never empty: an album with no photos is rejected at parse time.
  final List<Photo> photos;

  final int? year;
}
