import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../glass/glass_rim.dart';

/// Base surface for content — a pane of glass: translucent fill, bright
/// hairline edge, soft radius, violet haze, optional tap.
///
/// The single building block every feature-specific card (MemberCard,
/// EventCard, CapabilityCard) composes on top of, so depth/radius/padding —
/// and the press feedback below — stay consistent app-wide.
///
/// Deliberately does *not* blur what is behind it: a `BackdropFilter` per list
/// item costs a render-target each and shows up immediately when scrolling a
/// long list. The translucent fill over the ambient wash carries the look; real
/// blur is reserved for floating chrome that overlaps content (`GlassSurface`).
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.gradient,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Replaces the plain glass fill with a tinted one — for the single hero
  /// card on Home that needs to stand above the rest of the page.
  final Gradient? gradient;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // No drop shadow, and a light-catching rim in place of a flat hairline. A
    // screen of shadowed cards reads as a pile of floating boxes; the shadow is
    // kept for chrome that genuinely floats over content — the nav bar and the
    // pinned headers, which is what GlassSurface is for. The rim goes around
    // the pane, outside its padding, or it draws a box around the contents.
    final card = GlassRim(
      borderRadius: AppRadius.lgRadius,
      child: Container(
        padding: widget.padding,
        // A card you can tap is a tap target, and is held to the platforms'
        // minimum for one: "Listen on official platforms" was 46px tall, under
        // Android's 48. Doing it here covers every tappable card at once.
        constraints: widget.onTap == null
            ? null
            : const BoxConstraints(minHeight: kMinInteractiveDimension),
        decoration: BoxDecoration(
          color: widget.gradient != null
              ? null
              : (isDark ? AppColors.darkGlass : AppColors.glass),
          gradient: widget.gradient,
          borderRadius: AppRadius.lgRadius,
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return card;

    // A slight shrink on press — enough to feel responsive, not bouncy.
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: AppMotion.of(context, AppMotion.fast),
      curve: AppMotion.change,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lgRadius,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          borderRadius: AppRadius.lgRadius,
          child: card,
        ),
      ),
    );
  }
}
