import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'glass_surface.dart';

/// One destination in the [GlassNavBar].
class NavDestination {
  const NavDestination({required this.icon, required this.label});

  final IconData icon;

  /// Screen-reader label and tooltip. Not drawn — the bar is icons only.
  final String label;
}

/// The floating glass tab bar: a blurred pill hovering over the content, with a
/// dot under the icon marking where you are.
///
/// Scrolling content passes *underneath* it, which is the point of the blur —
/// so each tab's scroll view has to keep [reservedSpace] of clear room at the
/// bottom or its last item would end up behind the glass.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const double _height = 66;
  static const double _margin = AppSpacing.lg;

  /// Bottom padding a scroll view needs so its last item clears the bar.
  /// Excludes the safe-area inset, which callers add from their own MediaQuery.
  static const double reservedSpace = _height + _margin * 2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _margin,
        0,
        _margin,
        _margin + MediaQuery.paddingOf(context).bottom,
      ),
      child: GlassSurface(
        borderRadius: AppRadius.xxlRadius,
        child: SizedBox(
          height: _height,
          child: Stack(
            children: [
              // A lozenge that slides to the tab you picked, rather than a
              // marker that blinks out in one place and in again in another.
              // Through AppMotion, so a reader who asked for less movement
              // simply finds it already there.
              AnimatedAlign(
                alignment: destinations.length < 2
                    ? Alignment.center
                    : Alignment(
                        -1 + 2 * currentIndex / (destinations.length - 1),
                        0,
                      ),
                duration: AppMotion.of(context, AppMotion.base),
                curve: AppMotion.change,
                child: FractionallySizedBox(
                  widthFactor: 1 / destinations.length,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.16),
                        borderRadius: AppRadius.xxlRadius,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    Expanded(
                      child: _NavItem(
                        destination: destinations[i],
                        selected: i == currentIndex,
                        onTap: () => onSelected(i),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdRadius,
        // Icon-only, so the tooltip is the sighted user's equivalent of the
        // semantics label above.
        child: Tooltip(
          message: destination.label,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The dot that used to mark the active tab is gone: the lozenge
              // behind the icon says it, and two markers for one state is one
              // too many. Nothing moves when the selection changes, so the
              // icons no longer need a placeholder to hold their position.
              Icon(destination.icon, size: 22, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
