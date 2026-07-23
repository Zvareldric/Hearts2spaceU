import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/capability_card.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/hero_section.dart';

/// Landing screen — Design System V1 (docs/specs/home-layout.md).
///
/// Checkpoint 3.3: real Hero + Capability Cards. Up Next / Coming Soon remain
/// neutral placeholders (wired in 3.4–3.5). No AppBar — the Hero section
/// carries brand identity.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                        _SectionLabelPlaceholder(label: 'UP NEXT'),
                        const SizedBox(height: AppSpacing.md),
                        _CardPlaceholder(label: 'Up Next Card', height: 72),
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

/// Neutral placeholder standing in for a real card (Checkpoint 3.3–3.5).
class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder({required this.label, this.height = 100});

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.lgRadius,
      ),
      child: Text(label),
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
