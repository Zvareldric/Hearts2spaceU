import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/prefs_favorites_repository.dart';
import '../../domain/favorite.dart';
import '../../domain/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return const PrefsFavoritesRepository();
});

/// The user's favourite keys, and the only place they are changed.
///
/// Toggling updates the in-memory set first so the UI responds immediately,
/// then persists.
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() => ref.watch(favoritesRepositoryProvider).load();

  Future<void> toggle(Favorite favorite) async {
    final current = state.asData?.value;
    if (current == null) return;

    final next = Set<String>.from(current);
    if (!next.remove(favorite.key)) next.add(favorite.key);

    state = AsyncData(next);
    await ref.read(favoritesRepositoryProvider).save(next);
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

/// Whether one item is favourited. Returns false while loading, so a button
/// renders unfilled rather than flickering.
final isFavoriteProvider = Provider.family<bool, Favorite>((ref, favorite) {
  final keys = ref.watch(favoritesProvider).asData?.value;
  return keys?.contains(favorite.key) ?? false;
});
