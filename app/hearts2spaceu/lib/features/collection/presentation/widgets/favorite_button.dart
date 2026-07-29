import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/favorite.dart';
import '../providers/favorites_providers.dart';

/// Marks one item as a favourite.
///
/// The single point where other features touch Collection: each detail page
/// drops this in with its own type and id.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.type, required this.id});

  final String type;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = Favorite(type: type, id: id);
    final isFavorite = ref.watch(isFavoriteProvider(favorite));

    return IconButton(
      onPressed: () => ref.read(favoritesProvider.notifier).toggle(favorite),
      tooltip: isFavorite ? 'Remove from collection' : 'Add to collection',
      icon: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: isFavorite ? AppColors.secondaryStrong : AppColors.inkMuted,
      ),
    );
  }
}
