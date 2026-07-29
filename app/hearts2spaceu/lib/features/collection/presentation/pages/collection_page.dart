import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../../../awards/presentation/providers/award_providers.dart';
import '../../../awards/presentation/widgets/award_card.dart';
import '../../../gallery/presentation/providers/gallery_providers.dart';
import '../../../gallery/presentation/widgets/remote_image.dart';
import '../../../latest_updates/presentation/providers/update_providers.dart';
import '../../../latest_updates/presentation/widgets/update_card.dart';
import '../../../official_information/presentation/providers/member_providers.dart';
import '../../../official_information/presentation/widgets/member_card.dart';
import '../../../schedule/presentation/providers/event_providers.dart';
import '../../../schedule/presentation/widgets/event_card.dart';
import '../../domain/favorite.dart';
import '../providers/favorites_providers.dart';

/// UC-2 — everything the user has marked, grouped by type.
///
/// Renders the same cards the source features use; nothing new is designed
/// here. Keys whose source item is gone are skipped rather than deleted — the
/// data may just be failing to load right now.
class CollectionPage extends ConsumerWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Collection')),
      body: favoritesAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: "Couldn't open your collection.",
          onRetry: () => ref.invalidate(favoritesProvider),
        ),
        data: (keys) {
          if (keys.isEmpty) {
            return const EmptyView(
              message:
                  'Nothing saved yet.\nTap the heart on anything to keep it here.',
              icon: Icons.favorite_border_rounded,
            );
          }
          return _CollectionList(keys: keys);
        },
      ),
    );
  }
}

class _CollectionList extends ConsumerWidget {
  const _CollectionList({required this.keys});

  final Set<String> keys;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = keys
        .map(Favorite.tryParse)
        .whereType<Favorite>()
        .toList();

    final sections = <String, List<Widget>>{
      'Photos': _photos(context, ref, favorites),
      'Members': _members(context, ref, favorites),
      'Schedule': _events(context, ref, favorites),
      'Updates': _updates(context, ref, favorites),
      'Awards': _awards(context, ref, favorites),
    }..removeWhere((_, cards) => cards.isEmpty);

    if (sections.isEmpty) {
      // Everything saved points at data that is missing or still loading.
      return const EmptyView(
        message: "Your saved items aren't available right now.",
        icon: Icons.favorite_border_rounded,
      );
    }

    var animationIndex = 0;
    final children = <Widget>[];
    for (final entry in sections.entries) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: AppSpacing.xl));
      }
      children
        ..add(SectionHeader(label: entry.key))
        ..add(const SizedBox(height: AppSpacing.md));
      for (final card in entry.value) {
        children
          ..add(StaggeredItem(index: animationIndex++, child: card))
          ..add(const SizedBox(height: AppSpacing.md));
      }
      children.removeLast();
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: children,
    );
  }

  Iterable<String> _idsOf(List<Favorite> favorites, String type) =>
      favorites.where((f) => f.type == type).map((f) => f.id);

  /// Photo favourites are keyed `photo:<albumId>/<photoId>` because a photo id
  /// is only unique inside its album.
  List<Widget> _photos(
    BuildContext context,
    WidgetRef ref,
    List<Favorite> favorites,
  ) {
    final albums = ref.watch(albumsProvider).asData?.value ?? const [];
    final tiles = <Widget>[];

    for (final id in _idsOf(favorites, Favorite.typePhoto)) {
      final slash = id.indexOf('/');
      if (slash <= 0) continue;
      final albumId = id.substring(0, slash);
      final photoId = id.substring(slash + 1);

      for (final album in albums.where((a) => a.id == albumId)) {
        final index = album.photos.indexWhere((p) => p.id == photoId);
        if (index < 0) continue;
        tiles.add(
          GestureDetector(
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.photoViewer, arguments: (albumId, index)),
            child: ClipRRect(
              borderRadius: AppRadius.smRadius,
              child: SizedBox(
                height: 100,
                width: 100,
                child: RemoteImage(url: album.photos[index].url),
              ),
            ),
          ),
        );
      }
    }

    if (tiles.isEmpty) return const [];
    return [
      Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: tiles),
    ];
  }

  List<Widget> _members(
    BuildContext context,
    WidgetRef ref,
    List<Favorite> favorites,
  ) {
    final all = ref.watch(membersProvider).asData?.value ?? const [];
    final ids = _idsOf(favorites, Favorite.typeMember).toSet();
    return [
      for (final member in all.where((m) => ids.contains(m.id)))
        MemberCard(
          member: member,
          onTap: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.memberDetail, arguments: member.id),
        ),
    ];
  }

  List<Widget> _events(
    BuildContext context,
    WidgetRef ref,
    List<Favorite> favorites,
  ) {
    final all = ref.watch(upcomingEventsProvider).asData?.value ?? const [];
    final ids = _idsOf(favorites, Favorite.typeEvent).toSet();
    return [
      for (final event in all.where((e) => ids.contains(e.id)))
        EventCard(
          event: event,
          onTap: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.eventDetail, arguments: event.id),
        ),
    ];
  }

  List<Widget> _updates(
    BuildContext context,
    WidgetRef ref,
    List<Favorite> favorites,
  ) {
    final all = ref.watch(latestUpdatesProvider).asData?.value ?? const [];
    final ids = _idsOf(favorites, Favorite.typeUpdate).toSet();
    return [
      for (final update in all.where((u) => ids.contains(u.id)))
        UpdateCard(
          update: update,
          onTap: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.updateDetail, arguments: update.id),
        ),
    ];
  }

  List<Widget> _awards(
    BuildContext context,
    WidgetRef ref,
    List<Favorite> favorites,
  ) {
    final years = ref.watch(awardsByYearProvider).asData?.value ?? const [];
    final ids = _idsOf(favorites, Favorite.typeAward).toSet();
    return [
      for (final award
          in years.expand((y) => y.awards).where((a) => ids.contains(a.id)))
        AwardCard(
          award: award,
          onTap: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.awardDetail, arguments: award.id),
        ),
    ];
  }
}
