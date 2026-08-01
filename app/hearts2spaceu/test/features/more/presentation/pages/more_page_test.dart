import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/app/widgets/cards/capability_card.dart';
import 'package:hearts2spaceu/features/more/presentation/pages/more_page.dart';

/// The capability grid moved from Home to the More tab (Design System V2).
/// These are the checks that used to guard Home's nine-card grid: the tiles are
/// all there, and the two-column layout survives a cramped phone.
Future<void> _pumpMore(WidgetTester tester, double width) async {
  tester.view
    ..physicalSize = Size(width, 1400)
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: const MorePage()),
  );
  await tester.pump();
}

void main() {
  testWidgets('More lists every capability that is not a nav tab', (
    tester,
  ) async {
    await _pumpMore(tester, 360);

    expect(tester.takeException(), isNull);
    // Nothing shipped may quietly disappear from the menu.
    expect(find.byType(CapabilityCard), findsNWidgets(7));
    for (final title in [
      'Members',
      'Discography',
      'Music',
      'Statistics',
      'Latest Updates',
      'Awards',
      'Voting',
    ]) {
      expect(find.text(title), findsOneWidget, reason: '$title is missing');
    }
  });

  // The tile holds an icon, a title, and a two-line subtitle in a fixed aspect
  // ratio, which is exactly the shape that overflows when the width shrinks.
  for (final width in [360.0, 320.0, 280.0]) {
    testWidgets('the More grid does not overflow at ${width}dp', (
      tester,
    ) async {
      await _pumpMore(tester, width);
      expect(tester.takeException(), isNull);
    });
  }
}
