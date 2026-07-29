import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/favorites_repository.dart';

/// Stores favourites as one JSON array of keys in `shared_preferences`.
///
/// No database: the collection is a set of ids with no queries, relations, or
/// migrations, so a key-value entry is enough (docs/specs/personal-collection.md §0).
class PrefsFavoritesRepository implements FavoritesRepository {
  const PrefsFavoritesRepository();

  static const storageKey = 'favorites';

  @override
  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return {};
      return decoded.whereType<String>().toSet();
    } on FormatException {
      // Corrupt storage reads as an empty collection, never a crash.
      return {};
    }
  }

  @override
  Future<void> save(Set<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(keys.toList()));
  }
}
