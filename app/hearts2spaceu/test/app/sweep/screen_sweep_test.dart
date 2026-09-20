import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/app/widgets/layout/ambient_background.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/app/widgets/states/error_view.dart';

import 'contrast_probe.dart';
import 'page_catalog.dart';

/// Contrast the app is allowed to miss, each with the reason WCAG allows it.
///
/// Kept here, in the open, so an exemption is something a reviewer reads and
/// agrees to — not a threshold quietly lowered inside the probe.
final _exempt = <({String page, String text, String why})>[
  (
    page: 'Home',
    text: String.fromCharCode(Icons.favorite_rounded.codePoint),
    why:
        'the white heart in the brand mark beside the wordmark: a logo, which '
        '1.4.3 and 1.4.11 both exclude. Its colour is a brand decision.',
  ),
];

List<ContrastFailure> _unexempted(String page, List<ContrastFailure> found) =>
    found
        .where((f) => !_exempt.any((e) => e.page == page && e.text == f.text))
        .toList();

void main() {
  setUpAll(loadRealFonts);

  testWidgets('the sweep measures with real fonts, not placeholder boxes', (
    tester,
  ) async {
    // Roboto sets this phrase about 223px wide; the test placeholder face,
    // 419px. Anything near the latter means every layout verdict below is off.
    expect(await measureThemeFont(tester), lessThan(300));
  });

  for (final brightness in Brightness.values) {
    group('${brightness.name} mode', () {
      for (final page in sweepPages) {
        testWidgets('$page shows its content and every word is readable', (
          tester,
        ) async {
          // Renders at an ordinary 390dp phone and asserts the screen reached
          // its real content (see SweepPage.expects).
          await pumpSweepPage(tester, page, brightness: brightness);

          expect(
            _unexempted(page.name, measureContrast(tester, brightness)),
            isEmpty,
            reason: 'text on ${page.name} below its WCAG bar',
          );
        });
      }

      // No screen in the catalogue renders these — the fixtures all succeed —
      // so they are measured on their own. They are the screens a reader sees
      // exactly when something has already gone wrong.
      for (final (name, state) in [
        ('empty', const EmptyView(message: 'No upcoming events.')),
        ('error', ErrorView(message: 'Failed to load.', onRetry: () {})),
        (
          'compact empty',
          const EmptyView(message: 'Nothing yet.', compact: true),
        ),
        (
          'compact error',
          ErrorView(message: 'Failed.', compact: true, onRetry: () {}),
        ),
      ]) {
        testWidgets('the $name state is readable', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: brightness == Brightness.dark
                  ? AppTheme.dark
                  : AppTheme.light,
              builder: (_, child) => AmbientBackground(child: child!),
              home: Scaffold(body: Center(child: state)),
            ),
          );

          expect(measureContrast(tester, brightness), isEmpty);
        });
      }
    });
  }
}
