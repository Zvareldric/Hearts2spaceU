import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/layout/page_heading.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/release.dart';
import '../providers/release_providers.dart';
import '../release_format.dart';
import '../widgets/release_cover.dart';

/// UC-2 — one release: its cover, what it is, and what is on it.
class ReleaseDetailPage extends ConsumerWidget {
  const ReleaseDetailPage({super.key, required this.releaseId});

  final String releaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final release = ref.watch(releaseByIdProvider(releaseId));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                0,
              ),
              child: PageHeading.sub(title: release?.title ?? 'Release'),
            ),
            Expanded(
              child: release == null
                  ? const EmptyView(message: 'Release not found.')
                  : _ReleaseBody(release: release),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleaseBody extends StatelessWidget {
  const _ReleaseBody({required this.release});

  final Release release;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.xl,
      ),
      children: [
        Center(
          child: Hero(
            tag: 'release-cover-${release.id}',
            child: ReleaseCover(
              release: release,
              size: 200,
              radius: AppRadius.lg,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          formatReleaseMeta(release),
          textAlign: TextAlign.center,
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.inkMuted,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (release.note case final note?) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            note,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.primaryStrong,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (release.tracks.isEmpty)
          const _NoTracksYet()
        else
          _TrackList(release: release),
        const SizedBox(height: AppSpacing.lg),
        _ListenOn(),
      ],
    );
  }
}

class _TrackList extends StatelessWidget {
  const _TrackList({required this.release});

  final Release release;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tracks = release.tracks;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(label: 'Tracks'),
          const SizedBox(height: AppSpacing.xs),
          for (final (index, track) in tracks.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: index == tracks.length - 1
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      track.title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: track.isTitleTrack
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  // The promoted single is what most people opened this list
                  // looking for, so it is called out rather than just bolded.
                  if (track.isTitleTrack)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        borderRadius: AppRadius.pillRadius,
                      ),
                      child: Text(
                        'TITLE',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryStrong,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Says the track list is missing rather than showing an empty panel.
///
/// The discography ships with release-level data only; track lists are curated
/// by hand (docs/specs/discography.md §4), so "not recorded yet" is the honest
/// state for a release nobody has typed up yet — not "this release has no songs".
class _NoTracksYet extends StatelessWidget {
  const _NoTracksYet();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          const Icon(
            Icons.queue_music_rounded,
            color: AppColors.inkMuted,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Track list not recorded yet.',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sends the user to the platforms the app already knows about, rather than
/// storing a per-release link the Product Owner would have to maintain seven
/// times over.
class _ListenOn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.streamingHub),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.headphones_rounded,
            color: AppColors.primaryStrong,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Listen on official platforms',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.navIdle,
            size: 20,
          ),
        ],
      ),
    );
  }
}
