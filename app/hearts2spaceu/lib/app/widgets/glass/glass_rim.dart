import 'package:flutter/material.dart';

/// The bright edge a pane of glass catches where the light hits it.
///
/// A flat hairline of one colour reads as a drawn border; real glass is
/// brightest along the edge facing the light and fades away around the far
/// side. This strokes the pane's outline with that gradient instead, which is
/// what makes a translucent surface read as glass rather than as a tinted box.
///
/// Painted in front of the child so it survives whatever the pane is filled
/// with, and it never intercepts a touch.
class GlassRim extends StatelessWidget {
  const GlassRim({super.key, required this.borderRadius, required this.child});

  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      foregroundPainter: _RimPainter(borderRadius: borderRadius, dark: dark),
      child: child,
    );
  }
}

class _RimPainter extends CustomPainter {
  const _RimPainter({required this.borderRadius, required this.dark});

  final BorderRadius borderRadius;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    // Inset by half the stroke so the line sits on the edge rather than
    // straddling it, which would leave half of it outside the clip.
    final outline = borderRadius.toRRect(bounds).deflate(0.5);

    canvas.drawRRect(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0x4DFFFFFF), Color(0x1AFFFFFF), Color(0x0DFFFFFF)]
              : const [Color(0xF2FFFFFF), Color(0x80FFFFFF), Color(0x33FFFFFF)],
          stops: const [0, 0.45, 1],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(_RimPainter old) =>
      old.dark != dark || old.borderRadius != borderRadius;
}
