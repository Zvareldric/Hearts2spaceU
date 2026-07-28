/// A piece of official Hearts2Hearts news shown in the Latest Updates
/// capability.
///
/// Pure, immutable domain entity — no knowledge of JSON, HTTP, or rendering.
/// [publishedAt] is parsed from an ISO string in the data layer and formatted
/// for display only in the presentation layer.
class Update {
  const Update({
    required this.id,
    required this.title,
    required this.publishedAt,
    this.summary,
    this.body,
    this.category,
    this.sourceUrl,
    this.imageUrl,
  });

  /// Stable, unique identifier.
  final String id;

  /// Headline of the update.
  final String title;

  /// When the update was published. The key field for sorting.
  final DateTime publishedAt;

  /// Short teaser shown in the list.
  final String? summary;

  /// Full text shown on the detail page.
  final String? body;

  /// Kind of update, e.g. `announcement`, `release` (a String for MVP).
  final String? category;

  /// Link to the official source (stored; opening it is out of scope for now).
  final String? sourceUrl;

  /// Image for the update (stored; rendering it is out of scope for now).
  final String? imageUrl;
}
