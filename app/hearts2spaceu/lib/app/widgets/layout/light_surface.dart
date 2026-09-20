import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Declares that [child] sits on a fill that is light in *both* modes — the
/// hero gradient, the pastel update card — so everything inside it resolves
/// for a light ground.
///
/// Those fills are brand pastels and do not change with the theme. Without
/// this, a dark-mode reader got dark-theme ink on them: near-white titles on a
/// pale sky gradient at 3.29:1, and dark badge pairs meant for dark glass at
/// 1.43:1. Wrapping the content once is what keeps every title, badge and
/// save button inside correct, rather than hard-coding an ink into each.
///
/// The one adjustment: muted text on a pastel needs [AppColors.pastelMuted],
/// because the ordinary muted ink reaches only 3.23:1 there. It is supplied as
/// `onSurfaceVariant`, so widgets inside keep asking the theme as usual.
///
/// A builder, not a child, on purpose. A text style resolved from the *outer*
/// context — `final textTheme = Theme.of(context).textTheme` at the top of the
/// caller's build — carries the dark theme's colour inside it, and wrapping
/// that in a light theme changes nothing. Resolve styles from the context the
/// builder receives.
class LightSurface extends StatelessWidget {
  const LightSurface({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final light = AppTheme.light;
    final theme = light.copyWith(
      colorScheme: light.colorScheme.copyWith(
        onSurfaceVariant: AppColors.pastelMuted,
      ),
    );

    // The transparent Material re-establishes the default text style from the
    // light theme; a Theme alone would leave plain `Text` inheriting the dark
    // style from the Material above it.
    return Theme(
      data: theme,
      child: Material(
        type: MaterialType.transparency,
        child: Builder(builder: builder),
      ),
    );
  }
}
