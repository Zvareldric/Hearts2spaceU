import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/glass/glass_nav_bar.dart';
import '../../../../app/widgets/layout/page_heading.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../../../awards/presentation/providers/award_providers.dart';
import '../../../gallery/presentation/providers/gallery_providers.dart';
import '../../../gallery/presentation/widgets/remote_image.dart';
import '../../../latest_updates/presentation/providers/update_providers.dart';
import '../../../latest_updates/presentation/update_date_format.dart';
import '../../../official_information/presentation/member_palette.dart';
import '../../../official_information/presentation/providers/member_providers.dart';
import '../../../schedule/presentation/providers/event_providers.dart';
import '../../domain/favorite.dart';
import '../providers/favorites_providers.dart';

/// UC-2 — everything the user has marked, grouped by type (Design System V2).
///
/// Saved photos read as a contact sheet; everything else as one compact line
/// each, because this page answers "what did I keep?" — the full card belongs to
/// the feature that owns the item. Keys whose source item is gone are skipped
/// rather than deleted: the data may just be failing to load right now.
class CollectionPage extends ConsumerWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                0,
              ),
              child: PageHeading(title: 'My Collection'),
            ),
            Expanded(
              child: favoritesAsync.when(
                loading: () => const LoadingView(),
                error: (error, _) => ErrorView(
                  message: "Couldn't open your collection.",
                  onRetry: () => ref.invalidate(favoritesProvider),
                ),
                data: (keys) => _CollectionList(keys: keys),
              ),
            ),
          ],
        ),
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

    final photos = _photos(context, ref, favorites);
    final events = _events(context, ref, favorites);

    // Only these two sections keep a placeholder when empty: they are the two
    // the heart buttons feed, so the hint is a instruction, not filler.
    final sections = <Widget>[
      const SectionHeader(label: 'Saved moments'),
      const SizedBox(height: AppSpacing.sm),
      if (photos.isEmpty)
        const _EmptyHint(
          'No favorite photos yet — tap the heart on any Gallery photo to save '
          'it here.',
        )
      else
        _PhotoSheet(tiles: photos),
      const SizedBox(height: AppSpacing.xl),
      const SectionHeader(label: 'Saved events'),
      const SizedBox(height: AppSpacing.sm),
      if (events.isEmpty)
        const _EmptyHint(
          'No saved events yet — tap the heart on any Schedule item to track '
          'it here.',
        )
      else
        ...events,
    ];

    // The remaining types have no heart on a list yet, so an empty placeholder
    // would be advice the user cannot act on. They appear only once used.
    for (final (label, rows) in [
      ('Saved members', _members(context, ref, favorites)),
      ('Saved updates', _updates(context, ref, favorites)),
      ('Saved awards', _awards(context, ref, favorites)),
    ]) {
      if (rows.isEmpty) continue;
      sections
        ..add(const SizedBox(height: AppSpacing.xl))
        ..add(SectionHeader(label: label))
        ..add(const SizedBox(height: AppSpacing.sm))
        ..addAll(rows);
    }

    var animationIndex = 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        // Clear the floating nav bar this list scrolls underneath.
        GlassNavBar.reservedSpace,
      ),
      children: [
        for (final section in sections)
          if (section is _SavedRow || section is _PhotoSheet)
            StaggeredItem(index: animationIndex++, child: section)
          else
            section,
      ],
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
              borderRadius: AppRadius.mdRadius,
              child: RemoteImage(url: album.photos[index].url),
            ),
          ),
        );
      }
    }
    return tiles;
  }

  List<Widget> _members(
    BuildContext context,
    WidgetRef ref,
    List<Favorite> favorites,
  ) {
    final all = ref.watch(membersProvider).asData?.value ?? const [];
    final ids = _idsOf(favorites, Favorite.typeMember).toSet();
    // The full roster, not just the saved ones: `memberColor` ranks against the
    // whole list, so passing a filtered subset would give a member a different
    // dot here than her avatar has everywhere else.
    final roster = all.map((m) => m.id).toList();
    return [
      for (final member in all.where((m) => ids.contains(m.id)))
        _SavedRow(
          dot: memberColor(member.id, roster),
          title: member.stageName,
          trailing: member.positions.isEmpty ? null : member.positions.first,
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
        _SavedRow(
          dot: typeStyleFor(event.type).foreground,
          title: event.title,
          trailing: _monthDay(event.startDateTime),
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
        _SavedRow(
          dot: typeStyleFor(update.category).foreground,
          title: update.title,
          trailing: formatPublishedDate(update.publishedAt),
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
        _SavedRow(
          dot: typeStyleFor(award.type).foreground,
          title: award.title,
          trailing: '${award.year}',
          onTap: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.awardDetail, arguments: award.id),
        ),
    ];
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _monthDay(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}';
}

/// Saved photos as a contact sheet — three across, square.
class _PhotoSheet extends StatelessWidget {
  const _PhotoSheet({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      // Inside a ListView: size to content instead of taking its own viewport.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisCount: 3,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      children: tiles,
    );
  }
}

/// One saved item as a single line: a colored dot for its kind, its title, and
/// one piece of context.
class _SavedRow extends StatelessWidget {
  const _SavedRow({
    required this.dot,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final Color dot;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing case final trailing?) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                trailing,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.inkMuted,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A dashed placeholder that tells the user how to fill the section, instead of
/// leaving a silent gap.
class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.primaryStrong.withValues(alpha: 0.35),
        radius: AppRadius.lg,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.45),
          borderRadius: AppRadius.lgRadius,
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.inkMuted,
            fontWeight: FontWeight.w400,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

/// Draws a dashed rounded-rectangle outline.
///
/// Flutter's `Border` has no dash support, and the dashes are the whole point:
/// they mark the box as a slot waiting to be filled rather than a real card.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dash = 5.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Walk the outline and stroke only the "on" stretches.
    for (final metric in outline.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + _dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
