import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_colors.dart';
import 'package:hearts2spaceu/app/widgets/layout/ambient_background.dart';

/// One piece of rendered text that does not clear its WCAG bar.
class ContrastFailure {
  const ContrastFailure(this.text, this.ratio, this.required, this.ink);

  final String text;
  final double ratio;
  final double required;
  final Color ink;

  @override
  String toString() =>
      '"$text" ${ratio.toStringAsFixed(2)}:1 < $required '
      '(ink #${(ink.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')})';
}

/// Measures every piece of text on screen against what is actually behind it.
///
/// Token-level tests prove a colour *can* pass on a given ground; they cannot
/// see a widget that puts the right colour on the wrong ground, or the wrong
/// colour anywhere. This walks up the render tree from each paragraph, stacks
/// every fill it passes through — glass veils, badge tints, gradients, Material
/// surfaces — over the ambient wash, and computes the ratio the reader gets.
///
/// Conservative where it has to guess:
/// - The wash is not one colour: it is a base gradient with four blobs, and
///   text can scroll over any part of it. Every paragraph is measured over all
///   six grounds (two base stops, four blobs) and must pass on the worst.
/// - A gradient fill is measured at each of its stops.
///
/// Deliberately skipped, each for a reason WCAG itself gives:
/// - text under an ancestor opacity below 1 — inactive and disabled UI is
///   exempt from 1.4.3, and after settling nothing active is faded;
/// - text on a route or tab that is not being painted.
///
/// Known blind spot: a fill that sits *beside* the text in a Stack rather than
/// above it in the tree — an image with a caption laid over it — is not seen.
/// Text over photos needs its own scrim test.
List<ContrastFailure> measureContrast(
  WidgetTester tester,
  Brightness brightness,
) {
  final grounds = ambientGrounds(brightness);
  final failures = <ContrastFailure>[];

  // A set: `allRenderObjects` walks elements, and a component element reports
  // its child's render object — so `Text` and the `RichText` under it both
  // yield the same paragraph, which was then judged twice.
  for (final paragraph
      in tester.allRenderObjects.whereType<RenderParagraph>().toSet()) {
    if (!paragraph.attached || !paragraph.hasSize || paragraph.size.isEmpty) {
      continue;
    }
    final text = paragraph.text.toPlainText().trim();
    if (text.isEmpty) continue;

    final layers = _layersBehind(paragraph);
    if (layers == null) continue; // not painted, or inactive

    var backgrounds = grounds;
    for (final layer in layers.reversed) {
      backgrounds = [
        for (final ground in backgrounds)
          for (final stop in layer) _composite(stop, ground),
      ];
    }

    for (final style in _effectiveStyles(paragraph.text)) {
      final ink = style.color;
      if (ink == null || ink.a == 0) continue;

      final worst = backgrounds
          .map((bg) => _contrast(_composite(ink, bg), bg))
          .reduce(math.min);
      final required = _requiredRatio(style);
      if (worst < required) {
        failures.add(ContrastFailure(_short(text), worst, required, ink));
      }
    }
  }
  return failures;
}

/// The distinct styles text is actually drawn in, each merged with what it
/// inherits from its parent spans. A child span with no colour of its own is
/// drawn in its parent's — judging spans one by one either missed that or
/// reported the same run of text twice.
Iterable<TextStyle> _effectiveStyles(InlineSpan root) {
  final seen = <(int?, double?, int?, String?)>{};
  final styles = <TextStyle>[];

  void visit(InlineSpan span, TextStyle inherited) {
    final style = inherited.merge(span.style);
    if (span is TextSpan) {
      if ((span.text ?? '').trim().isNotEmpty) {
        final key = (
          style.color?.toARGB32(),
          style.fontSize,
          style.fontWeight?.value,
          style.fontFamily,
        );
        if (seen.add(key)) styles.add(style);
      }
      for (final child in span.children ?? const <InlineSpan>[]) {
        visit(child, style);
      }
    }
  }

  visit(root, const TextStyle());
  return styles;
}

/// The six opaque colours the wash can put behind a piece of text.
List<Color> ambientGrounds(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final base = dark ? AppColors.darkAmbientBase : AppColors.ambientBase;
  final opacity = dark
      ? AmbientBackground.darkBlobOpacity
      : AmbientBackground.lightBlobOpacity;
  return [
    ...base,
    for (final (index, blob) in AppColors.ambientBlobs.indexed)
      _composite(
        blob.withValues(alpha: opacity),
        index < 2 ? base.first : base.last,
      ),
  ];
}

/// Every fill between [paragraph] and the wash, innermost first — each as the
/// list of colours it can be (one for a flat fill, every stop for a gradient).
/// Null when the paragraph is not painted or sits under a fade.
List<List<Color>>? _layersBehind(RenderParagraph paragraph) {
  final layers = <List<Color>>[];
  RenderObject child = paragraph;
  var node = paragraph.parent;

  while (node != null) {
    if (node is RenderOffstage && node.offstage) return null;
    if (node is RenderOpacity && node.opacity < 1) return null;
    if (node is RenderAnimatedOpacity && node.opacity.value < 1) return null;
    if (node is RenderIndexedStack &&
        node.getChildrenAsList().indexOf(child as RenderBox) != node.index) {
      return null;
    }

    if (node is RenderDecoratedBox && node.decoration is BoxDecoration) {
      final decoration = node.decoration as BoxDecoration;
      final gradient = decoration.gradient;
      if (_isAmbientBase(gradient)) break; // the wash: grounds take over
      if (decoration.color != null) layers.add([decoration.color!]);
      if (gradient != null) layers.add(gradient.colors);
    }
    if (node is RenderPhysicalModel) layers.add([node.color]);
    if (node is RenderPhysicalShape) layers.add([node.color]);
    // `Container(color: …)` builds a ColoredBox, whose render object is private
    // and so cannot be matched by type. Its creating widget is public.
    final creator = node.debugCreator;
    if (creator is DebugCreator && creator.element.widget is ColoredBox) {
      layers.add([(creator.element.widget as ColoredBox).color]);
    }

    child = node;
    node = node.parent;
  }
  return layers;
}

bool _isAmbientBase(Gradient? gradient) {
  if (gradient is! LinearGradient) return false;
  final colors = gradient.colors;
  return _sameColors(colors, AppColors.ambientBase) ||
      _sameColors(colors, AppColors.darkAmbientBase);
}

bool _sameColors(List<Color> a, List<Color> b) =>
    a.length == b.length &&
    [
      for (var i = 0; i < a.length; i++) a[i].toARGB32() == b[i].toARGB32(),
    ].every((same) => same);

/// 4.5:1 for body text; 3:1 for large text (WCAG: 24px, or 18.66px bold) and
/// for icons, which are graphics under 1.4.11 rather than text under 1.4.3.
double _requiredRatio(TextStyle style) {
  if (style.fontFamily == 'MaterialIcons') return 3;
  final size = style.fontSize ?? 14;
  final bold = (style.fontWeight?.value ?? 400) >= 700;
  if (size >= 24 || (bold && size >= 18.66)) return 3;
  return 4.5;
}

String _short(String text) {
  final flat = text.replaceAll('\n', ' ');
  return flat.length <= 40 ? flat : '${flat.substring(0, 37)}...';
}

Color _composite(Color fg, Color bg) {
  final a = fg.a;
  return Color.from(
    alpha: 1,
    red: fg.r * a + bg.r * (1 - a),
    green: fg.g * a + bg.g * (1 - a),
    blue: fg.b * a + bg.b * (1 - a),
  );
}

double _luminance(Color color) {
  double channel(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
