/// An official Hearts2Hearts channel — streaming, video, or social.
///
/// Pure, immutable domain entity. The app links out to these; it never plays
/// or embeds their content (a permanent Non-Goal, docs/01).
class OfficialPlatform {
  const OfficialPlatform({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    this.handle,
  });

  /// Stable, unique identifier.
  final String id;

  /// Display name, e.g. `Spotify`.
  final String name;

  /// The official channel URL. Always `https` — enforced when parsing.
  final String url;

  /// Grouping key: `music`, `video`, `social`, `community`.
  final String category;

  /// Account name where one applies, e.g. `@hearts2hearts`.
  final String? handle;
}
