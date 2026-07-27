import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/cards/capability_card.dart';
import '../../../../app/widgets/cards/coming_soon_card.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../routes/app_routes.dart';
import '../../../schedule/presentation/providers/event_providers.dart';
import '../widgets/hero_section.dart';
import '../widgets/up_next_card.dart';

/// Landing screen — Design System V1 (docs/specs/home-layout.md).
///
/// Checkpoint 3.5 (final): Hero + Capability Cards + Up Next + Coming Soon —
/// Home Refresh complete. No AppBar — the Hero section carries brand identity.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        // top:false — HeroSection reaches the very top itself and handles the
        // safe-area inset internally, so its gradient is truly full-bleed.
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const HeroSection(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            Expanded(
                              child: CapabilityCard(
                                icon: Icons.groups_rounded,
                                title: 'Members',
                                subtitle: 'Meet Hearts2Hearts',
                                onTap: () => Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.memberList),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: CapabilityCard(
                                icon: Icons.event_rounded,
                                title: 'Schedule',
                                subtitle: 'Upcoming activities',
                                onTap: () => Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.schedule),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const SectionHeader(label: 'Up next'),
                        const SizedBox(height: AppSpacing.md),
                        const _UpNextSection(),
                        const SizedBox(height: AppSpacing.xxl),
                        const SectionHeader(label: 'Coming soon'),
                        const SizedBox(height: AppSpacing.md),
                        const Row(
                          children: [
                            Expanded(
                              child: ComingSoonCard(
                                icon: Icons.collections_bookmark_rounded,
                                label: 'Collection',
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: ComingSoonCard(
                                icon: Icons.photo_library_rounded,
                                label: 'Gallery',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Row(
                          children: [
                            Expanded(
                              child: ComingSoonCard(
                                icon: Icons.music_note_rounded,
                                label: 'Music',
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: ComingSoonCard(
                                icon: Icons.newspaper_rounded,
                                label: 'News',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Home's "Up next" slot — reads [upcomingEventsProvider] (Sprint 2) and
/// renders the same Loading/Empty/Error/Data states used app-wide, always
/// visible regardless of state (docs/specs/home-layout.md §5).
///
/// Every state uses the compact variant inside an [AppCard], so the slot keeps
/// one fixed height: switching states never reflows the sections below it.
class _UpNextSection extends ConsumerWidget {
  const _UpNextSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    // Cross-fades between states; every state is the same height, so the
    // sections below never move (see up_next_slot_height_test.dart).
    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.base),
      child: eventsAsync.when(
        loading: () => const AppCard(
          key: ValueKey('loading'),
          child: LoadingView(compact: true),
        ),
        error: (error, _) => AppCard(
          key: const ValueKey('error'),
          child: ErrorView(
            message: 'Couldn\'t load the schedule.',
            onRetry: () => ref.invalidate(upcomingEventsProvider),
            compact: true,
          ),
        ),
        data: (events) {
          if (events.isEmpty) {
            return const AppCard(
              key: ValueKey('empty'),
              child: EmptyView(
                message: 'No upcoming events yet.',
                icon: Icons.event_available_rounded,
                compact: true,
              ),
            );
          }
          final next = events.first;
          return UpNextCard(
            key: const ValueKey('data'),
            event: next,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.eventDetail, arguments: next.id),
          );
        },
      ),
    );
  }
}
