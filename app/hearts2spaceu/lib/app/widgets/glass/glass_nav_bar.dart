import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
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
          child: Row(
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
    final color = selected ? AppColors.primaryStrong : AppColors.navIdle;

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
              Icon(destination.icon, size: 22, color: color),
              const SizedBox(height: AppSpacing.xs),
              // The dot is always drawn and only changes color: a marker that
              // appears and disappears would shift the icons by its height.
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
