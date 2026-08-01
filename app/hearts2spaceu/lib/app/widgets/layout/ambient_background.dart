import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The pastel wash every screen floats on — a soft vertical base with four
/// blurred corner blobs.
///
/// Painted once, behind the whole navigator (see `App.build`), so it does not
/// rebuild or re-animate on navigation and every route — including nested
/// Scaffolds inside the tab shell — shares one continuous background. This is
/// why `scaffoldBackgroundColor` is transparent app-wide.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blobs = AppColors.ambientBlobs;
    // Held below full strength: a phone screen is taller than the design frame,
    // so all four blobs overlap more here, and at full saturation the muted text
    // color loses contrast against the pink corners. Dark mode goes to a
    // whisper — pastels at strength on a plum ground turn to mud.
    final blobOpacity = isDark ? 0.16 : 0.78;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? AppColors.darkAmbientBase : AppColors.ambientBase,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Blobs bleed past the edges so no hard circle edge is ever visible.
          Positioned(
            left: -110,
            top: -120,
            child: _Blob(color: blobs[0], size: 380, opacity: blobOpacity),
          ),
          Positioned(
            right: -130,
            top: -140,
            child: _Blob(color: blobs[1], size: 360, opacity: blobOpacity),
          ),
          Positioned(
            right: -120,
            bottom: -140,
            child: _Blob(color: blobs[2], size: 400, opacity: blobOpacity),
          ),
          Positioned(
            left: -140,
            bottom: -120,
            child: _Blob(color: blobs[3], size: 380, opacity: blobOpacity),
          ),
          child,
        ],
      ),
    );
  }
}

/// One radial pastel bloom, fading to fully transparent at its edge.
class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size, required this.opacity});

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
