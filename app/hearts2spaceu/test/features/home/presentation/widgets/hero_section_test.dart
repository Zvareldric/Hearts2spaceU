import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/features/home/presentation/widgets/hero_section.dart';

Future<void> _pumpHero(WidgetTester tester, double width) async {
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: HeroSection()),
    ),
  );
  await tester.pump();
}

void main() {
  // The wordmark is the app's name on the first screen: it must never clip.
  // Its width depends on the font, and the font depends on the platform — so
  // instead of trusting one measurement, the layout is built to survive any
  // width. These tests hold that promise.
  for (final width in [360.0, 320.0, 240.0]) {
    testWidgets('the hero wordmark does not overflow at ${width}dp', (
      tester,
    ) async {
      await _pumpHero(tester, width);
      expect(tester.takeException(), isNull);
      expect(find.text('Hearts2spaceU'), findsOneWidget);
    });
  }

  testWidgets('the wordmark stays on one line', (tester) async {
    // Shrinking is the intended fallback; wrapping to two lines would push the
    // whole hero taller and change Home's layout.
    await _pumpHero(tester, 320);

    final text = tester.widget<Text>(find.text('Hearts2spaceU'));
    expect(text.maxLines, 1);
  });
}
