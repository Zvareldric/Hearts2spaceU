/// A single photo in an album.
class Photo {
  const Photo({required this.id, required this.url, this.caption});

  /// Unique within its album.
  final String id;

  /// Where the image lives. Always `https` — enforced when parsing.
  final String url;

  final String? caption;
}
