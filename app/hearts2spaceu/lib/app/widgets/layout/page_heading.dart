import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// The heading every screen opens with — Design System V2 uses no AppBar.
///
/// Two shapes:
/// * [PageHeading] — a large inline title, for a tab's own root screen.
/// * [PageHeading.sub] — a round glass back button beside a smaller title, for
///   anything pushed on top.
///
/// Titles live *inside* the scroll view rather than in fixed chrome, so they
/// scroll away and give the content the full height of the screen.
class PageHeading extends StatelessWidget {
  const PageHeading({super.key, required this.title, this.trailing})
    : subtitle = null,
      showBack = false;

  const PageHeading.sub({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  }) : showBack = true;

  final String title;

  /// A second line under a sub-page title (e.g. an album's year).
  final String? subtitle;

  final bool showBack;

  /// Optional action at the far end — a favourite button, usually.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (!showBack) {
      return Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xs,
          bottom: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: textTheme.headlineMedium)),
            ?trailing,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          const _BackBubble(),
          // The bubble's touch target is 10px wider than the bubble itself;
          // a smaller gap keeps the title where it was.
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.headlineSmall,
                  maxLines: AppTypography.maxLines(context, 1),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle case final subtitle?)
                  Text(
                    subtitle,
                    // Straight on the wash, so the soft ink, not the muted one.
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.inkSoftOf(context),
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// The round glass back button.
///
/// Built on [IconButton] with the standard back tooltip on purpose: that is
/// what `WidgetTester.pageBack()` and screen readers look for, so replacing the
/// AppBar's own back button costs nothing in behaviour.
class _BackBubble extends StatelessWidget {
  const _BackBubble();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 48 to touch, 38 to see. The glass bubble is the design; the target
    // around it is what a thumb needs. Both platform guidelines ask for at
    // least 44 (iOS) or 48 (Android), and the bubble alone gave 36.
    return IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      icon: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGlass : AppColors.glass,
          borderRadius: AppRadius.pillRadius,
          border: Border.all(
            color: isDark ? AppColors.darkGlassBorder : AppColors.glassBorder,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 17,
          color: AppColors.inkSoftOf(context),
        ),
      ),
    );
  }
}
