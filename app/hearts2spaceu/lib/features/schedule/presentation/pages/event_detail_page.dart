import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/buttons/secondary_button.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/layout/meta_row.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../domain/event.dart';
import '../event_date_format.dart';
import '../providers/event_providers.dart';

/// UC-2 — one event's details. Design System V1 (Checkpoint 6).
///
/// Reuses the cached [upcomingEventsProvider] and selects by id (same
/// Loading/Empty/Error views as the list).
class EventDetailPage extends ConsumerWidget {
  const EventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Scaffold(
      // The hero runs behind the (transparent) app bar, which is reduced to a
      // back button — the hero itself carries the page's identity.
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: eventsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: "Couldn't load the event.",
          onRetry: () => ref.invalidate(upcomingEventsProvider),
        ),
        data: (events) {
          final matches = events.where((e) => e.id == eventId);
          if (matches.isEmpty) {
            return const EmptyView(message: 'Event not found.');
          }
          return _EventDetail(event: matches.first);
        },
      ),
    );
  }
}

/// Renders an event. Only non-null optional fields are shown, and the
/// date/time is formatted here (presentation) — never in domain/data.
class _EventDetail extends StatelessWidget {
  const _EventDetail({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final hasMeta = event.location != null || event.type != null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _EventHero(event: event),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              if (hasMeta)
                AppCard(
                  child: Column(
                    children: [
                      MetaRow(
                        icon: Icons.schedule_rounded,
                        label: 'When',
                        value: formatEventDateTime(event.startDateTime),
                      ),
                      if (event.location != null)
                        MetaRow(
                          icon: Icons.place_rounded,
                          label: 'Location',
                          value: event.location!,
                        ),
                      if (event.type != null)
                        MetaRow(
                          icon: Icons.local_activity_rounded,
                          label: 'Type',
                          value: event.type!,
                        ),
                    ],
                  ),
                ),
              if (event.description != null) ...[
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(label: 'About'),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Text(
                    event.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
              if (event.officialUrl != null) ...[
                const SizedBox(height: AppSpacing.xl),
                // Disabled for now: opening links needs url_launcher, which is
                // still out of scope (docs/specs/schedule.md).
                const SecondaryButton(
                  label: 'Official page (soon)',
                  icon: Icons.open_in_new_rounded,
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-bleed gradient header carrying the event's identity.
class _EventHero extends StatelessWidget {
  const _EventHero({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        topInset + kToolbarHeight + AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.type != null) ...[
            TypeBadge(type: event.type!),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(event.title, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            formatEventDateTime(event.startDateTime),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
