import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

/// Landing screen — Design System V1 (docs/specs/home-layout.md).
///
/// Checkpoint 3.1: layout skeleton only. Sections are neutral placeholders so
/// spacing/scroll/responsive behavior can be reviewed before real content is
/// wired in (3.2–3.5). No AppBar — the Hero section carries brand identity.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroPlaceholder(),
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
                            Expanded(child: _CardPlaceholder(label: 'Members')),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _CardPlaceholder(label: 'Schedule'),
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

/// Full-bleed placeholder standing in for `HeroSection` (Checkpoint 3.2).
class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: const Text('Hero Section'),
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
