import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../shared/widgets/external_link_button.dart';
import '../../domain/update.dart';
import '../providers/update_providers.dart';
import '../update_date_format.dart';

/// UC-2 — one update's details. Design System V1.
///
/// Reuses the cached [latestUpdatesProvider] and selects by id.
class UpdateDetailPage extends ConsumerWidget {
  const UpdateDetailPage({super.key, required this.updateId});

  final String updateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatesAsync = ref.watch(latestUpdatesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: updatesAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: "Couldn't reach the updates.\nCheck your connection.",
          onRetry: () => ref.invalidate(latestUpdatesProvider),
        ),
        data: (updates) {
          final matches = updates.where((u) => u.id == updateId);
          if (matches.isEmpty) {
            return const EmptyView(message: 'Update not found.');
          }
          return _UpdateDetail(update: matches.first);
        },
      ),
    );
  }
}

/// Renders an update. Only non-null optional fields are shown, and the date is
/// formatted here (presentation) — never in domain/data.
class _UpdateDetail extends StatelessWidget {
  const _UpdateDetail({required this.update});

  final Update update;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _UpdateHero(update: update),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              if (update.body != null)
                AppCard(
                  child: Text(
                    update.body!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              if (update.sourceUrl != null) ...[
                const SizedBox(height: AppSpacing.xl),
                ExternalLinkButton(
                  url: update.sourceUrl!,
                  label: 'Read the source',
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

/// Full-bleed gradient header carrying the update's identity.
class _UpdateHero extends StatelessWidget {
  const _UpdateHero({required this.update});

  final Update update;

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
          if (update.category != null) ...[
            TypeBadge(type: update.category!),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(update.title, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            formatPublishedDate(update.publishedAt),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.inkMuted),
          ),
          if (update.summary != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              update.summary!,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.ink),
            ),
          ],
        ],
      ),
    );
  }
}
