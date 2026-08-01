/// One song on a [Release].
class Track {
  const Track({required this.title, this.isTitleTrack = false});

  final String title;

  /// The promoted single off the release. Marked in the UI, since it is what
  /// most fans came to the track list looking for.
  final bool isTitleTrack;
}

/// Something Hearts2Hearts has put out — a single, a mini album, an album.
///
/// Pure, immutable domain entity: no knowledge of JSON, assets, or rendering.
class Release {
  const Release({
    required this.id,
    required this.title,
    required this.year,
    this.type,
    this.releaseDate,
    this.note,
    this.coverUrl,
    this.tracks = const [],
  });

  static const typeSingle = 'single';
  static const typeMiniAlbum = 'mini-album';
  static const typeAlbum = 'album';

  /// Stable, unique identifier.
  final String id;

  /// The release's name, e.g. `Lemon Tang`.
  final String title;

  /// The year it came out — the grouping and sort key.
  ///
  /// A year rather than a full date is required, and [releaseDate] optional, for
  /// the same reason as `Award.year`: the sources for the earlier releases
  /// publish only the year, and inventing a day would state something they never
  /// said (docs/specs/discography.md §4).
  final int year;

  /// One of [typeSingle], [typeMiniAlbum], [typeAlbum] — or null when the
  /// format is not recorded.
  final String? type;

  /// The exact release date, when it is actually known.
  final DateTime? releaseDate;

  /// Extra context, e.g. `Japanese debut single`.
  final String? note;

  /// Cover art. Null renders a placeholder rather than a broken image.
  final String? coverUrl;

  /// The track list, in running order. Empty means "not recorded yet" — which
  /// the UI says out loud instead of showing an empty panel.
  final List<Track> tracks;

  /// The promoted single, when the track list marks one.
  Track? get titleTrack =>
      tracks.where((track) => track.isTitleTrack).firstOrNull;
}
