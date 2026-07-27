import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

/// Base surface for content — soft radius, diffuse shadow, optional tap.
///
/// The single building block every feature-specific card (MemberCard,
/// EventCard, CapabilityCard) composes on top of, so depth/radius/padding —
/// and the press feedback below — stay consistent app-wide.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

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
    final theme = Theme.of(context);
    final card = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.sm,
      ),
      child: widget.child,
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
