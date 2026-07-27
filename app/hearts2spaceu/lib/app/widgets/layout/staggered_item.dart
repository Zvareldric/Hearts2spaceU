import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';

/// Fades and lifts a list item into place, staggered by its [index].
///
/// Uses [TweenAnimationBuilder] (a Flutter built-in) so no controller or
/// package is needed: each item runs the same animation but starts a little
/// later, giving the list a gentle cascade instead of appearing all at once.
class StaggeredItem extends StatelessWidget {
  const StaggeredItem({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  /// Delay added per item, and the cap after which items no longer stagger —
  /// a long list should not take seconds to finish appearing.
  static const int _stepMs = 60;
  static const int _maxSteps = 8;

  @override
  Widget build(BuildContext context) {
    final total = AppMotion.of(context, AppMotion.slow);
    if (total == Duration.zero) return child;

    final steps = index.clamp(0, _maxSteps);
    final start = (steps * _stepMs / total.inMilliseconds).clamp(0.0, 0.8);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: AppMotion.enter),
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
