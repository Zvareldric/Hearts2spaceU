/// Something the user marked as a favourite.
///
/// Stored as a flat `"type:id"` key so a new content type needs no storage
/// change (docs/specs/personal-collection.md §4).
class Favorite {
  const Favorite({required this.type, required this.id});

  static const typePhoto = 'photo';
  static const typeEvent = 'event';
  static const typeAward = 'award';
  static const typeMember = 'member';
  static const typeUpdate = 'update';

  final String type;
  final String id;

  String get key => '$type:$id';

  /// Parses a stored key. Returns null for anything malformed, so one bad
  /// entry can never take the whole collection down.
  static Favorite? tryParse(String key) {
    final separator = key.indexOf(':');
    if (separator <= 0 || separator == key.length - 1) return null;
    // Ids may contain ':' themselves, so only split on the first one.
    return Favorite(
      type: key.substring(0, separator),
      id: key.substring(separator + 1),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Favorite && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);
}
