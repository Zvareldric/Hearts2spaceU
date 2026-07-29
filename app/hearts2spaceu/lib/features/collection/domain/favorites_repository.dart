/// Contract for reading and writing the user's favourites.
///
/// Keys are the flat `"type:id"` strings from [Favorite.key].
abstract interface class FavoritesRepository {
  /// Every saved key. Returns empty rather than throwing when storage is
  /// unreadable — a corrupt file must not lock the user out of the app.
  Future<Set<String>> load();

  /// Replaces the whole set.
  Future<void> save(Set<String> keys);
}
