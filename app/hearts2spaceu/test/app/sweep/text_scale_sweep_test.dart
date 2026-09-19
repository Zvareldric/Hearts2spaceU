import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/app/widgets/cards/app_card.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/app/widgets/states/error_view.dart';

import 'contrast_probe.dart';
import 'page_catalog.dart';

/// The narrowest phone the PRD supports.
const _phone = Size(360, 800);

/// Every piece of text on screen that the reader does not get all of.
///
/// Two ways to lose words, and only one of them announces itself. An ellipsis
/// is `didExceedMaxLines`. The other is a paragraph squeezed into a box shorter
/// than its lines: Text clips by default, so the extra lines simply vanish, with
/// no overflow error and no "…". The compact states did that inside a fixed
/// 48px box, and a check for ellipses alone passed them.
Set<String> _truncated(WidgetTester tester) => {
  for (final paragraph
      in tester.allRenderObjects.whereType<RenderParagraph>().toSet())
    if (paragraph.attached &&
        paragraph.hasSize &&
        isPainted(paragraph) &&
        (paragraph.didExceedMaxLines ||
            paragraph.textSize.height > paragraph.size.height + 0.5))
      paragraph.text.toPlainText(),
};

/// WCAG 1.4.4 and the PRD's release gate: at 200% text, at 360dp, no screen
/// breaks and none loses content.
///
/// "Loses content" is measured against the same screen at 100%. A list row
/// that is deliberately one line — its full title is a tap away on the detail
/// page — may be cut short at both sizes; what must not happen is text that
/// fits at 100% being cut off because it was enlarged. Before this sweep, page
/// titles, stat labels and every subtitle in More did exactly that, and four
/// screens overflowed outright — two of them, Statistics and More, at normal
/// text size on a 360dp phone.
void main() {
  setUpAll(loadRealFonts);

  for (final page in sweepPages) {
    testWidgets('$page holds 200% text at 360dp without losing words', (
      tester,
    ) async {
      // An overflow at either size fails the test on its own.
      await pumpSweepPage(tester, page, size: _phone);
      final atNormalSize = _truncated(tester);

      await pumpSweepPage(tester, page, size: _phone, textScale: 2);
      final atDoubleSize = _truncated(tester);

      expect(
        atDoubleSize.difference(atNormalSize),
        isEmpty,
        reason: 'cut off at 200% but whole at 100% on ${page.name}',
      );
    });
  }

  // The compact states live in Home's "Up next" slot, which no fixture shows.
  // They used to sit in a fixed 48px box that 200% text spilled out of.
  for (final (name, state) in [
    ('empty', const EmptyView(message: 'Nothing coming up.', compact: true)),
    (
      'error',
      ErrorView(message: 'Could not load.', compact: true, onRetry: () {}),
    ),
  ]) {
    testWidgets('the compact $name state holds 200% text at 360dp', (
      tester,
    ) async {
      tester.view
        ..physicalSize = _phone
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: AppCard(child: state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(_truncated(tester), isEmpty);
    });
  }
}
