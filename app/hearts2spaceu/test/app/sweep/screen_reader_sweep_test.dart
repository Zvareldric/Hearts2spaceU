import 'package:flutter_test/flutter_test.dart';

import 'page_catalog.dart';

/// The PRD's accessibility gate: screen-reader labels on navigation, links,
/// cards and actions, and touch targets of at least 44x44.
///
/// Flutter ships these checks. Three per screen:
/// - every tappable thing has a name a screen reader can announce;
/// - every tap target is at least 44x44, Apple's minimum;
/// - and at least 48x48, Android's, which is the stricter of the two.
///
/// Each check stops at the first failure on a screen, so a clean pass here
/// means clean — the first run found the back button at 36x36 on eleven
/// screens, and only once that was fixed did "See all" (58x20), the Listen
/// card (46px) and the Statistics year rows (44px) show up behind it.
void main() {
  setUpAll(loadRealFonts);

  for (final page in sweepPages) {
    testWidgets('$page can be used with a screen reader and a thumb', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpSweepPage(tester, page);

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

      semantics.dispose();
    });
  }
}
