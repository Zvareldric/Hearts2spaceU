import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/capability_card.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../../../schedule/presentation/providers/event_providers.dart';
import '../widgets/hero_section.dart';
import '../widgets/up_next_card.dart';

/// Landing screen — Design System V1 (docs/specs/home-layout.md).
///
/// Checkpoint 3.4: real Hero + Capability Cards + Up Next. Coming Soon
/// remains a neutral placeholder (wired in 3.5). No AppBar — the Hero
/// section carries brand identity.
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
                        _SectionLabelPlaceholder(label: 'COMING SOON'),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _CardPlaceholder(label: 'Collection'),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: _CardPlaceholder(label: 'Gallery')),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(child: _CardPlaceholder(label: 'Music')),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: _CardPlaceholder(label: 'News')),
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

/// Neutral placeholder standing in for a real card (Checkpoint 3.5).
class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.lgRadius,
      ),
      child: Text(label),
    );
  }
}

/// Home's "Up next" slot — reads [upcomingEventsProvider] (Sprint 2) and
/// renders the same Loading/Empty/Error/Data states used app-wide, always
/// visible regardless of state (docs/specs/home-layout.md §5).
class _UpNextSection extends ConsumerWidget {
  const _UpNextSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return eventsAsync.when(
      loading: () => const SizedBox(height: 72, child: LoadingView()),
      error: (error, _) => ErrorView(
        message: 'Failed to load your schedule.',
        onRetry: () => ref.invalidate(upcomingEventsProvider),
      ),
      data: (events) {
        if (events.isEmpty) {
          return const EmptyView(message: 'No upcoming events yet.');
        }
        final next = events.first;
        return UpNextCard(
          event: next,
          onTap: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.eventDetail, arguments: next.id),
        );
      },
    );
  }
}

/// Neutral placeholder standing in for `SectionHeader` (Checkpoint 3.4).
class _SectionLabelPlaceholder extends StatelessWidget {
  const _SectionLabelPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: AppColors.inkMuted),
    );
  }
}
