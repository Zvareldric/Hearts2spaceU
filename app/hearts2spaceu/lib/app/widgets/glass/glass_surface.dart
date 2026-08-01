import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';

/// Floating chrome that genuinely blurs the content behind it — the nav bar and
/// the pinned month headers.
///
/// Unlike [AppCard] this pays for a `BackdropFilter`, which is the whole point:
/// these surfaces sit *over* scrolling content, where a flat translucent fill
/// would let text show through legibly and look like a bug. There are only ever
/// a couple of these on screen at once, so the cost is bounded.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    this.blur = 24,
    this.border = true,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blur;

  /// The bright hairline edge. Off for full-width surfaces (a pinned header),
  /// where an outline on all four sides would read as a stray box.
  final bool border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // The shadow lives on an outer box: inside the ClipRRect it would be
    // clipped away by the very shape it is meant to sit under.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: border ? AppShadows.lg : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkGlass : AppColors.glass,
              borderRadius: borderRadius,
              border: border
                  ? Border.all(
                      color: isDark
                          ? AppColors.darkGlassBorder
                          : AppColors.glassBorder,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
