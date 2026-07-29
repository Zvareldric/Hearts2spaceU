import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_spacing.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/app/widgets/cards/capability_card.dart';
import 'package:hearts2spaceu/features/home/presentation/pages/home_page.dart';

/// The last capability row exactly as Home builds it: one card plus the empty
/// slot that holds the ninth card to a normal width.
Future<void> _pumpLastRow(WidgetTester tester, double width) async {
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Row(
            children: const [
              Expanded(
                child: CapabilityCard(
                  icon: Icons.insights_rounded,
                  title: 'Statistics',
                  subtitle: 'Their record so far',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('the ninth capability row does not overflow at phone width', (
    tester,
  ) async {
    await _pumpLastRow(tester, 360);
    expect(tester.takeException(), isNull);
  });

  testWidgets('it survives a cramped width too', (tester) async {
    await _pumpLastRow(tester, 320);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home shows nine cards and the odd one keeps a normal width', (
    tester,
  ) async {
    // 600dp, not 360: the test font draws every glyph as a square the size of
    // the font, so the 32px hero wordmark measures far wider here than in any
    // real typeface. That is a measurement artifact, not a layout bug — so
    // this test asks about card widths, and the row above proves the fit.
    tester.view
      ..physicalSize = const Size(600, 2000)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light, home: const HomePage()),
      ),
    );
    await tester.pump();

    final cards = find.byType(CapabilityCard);
    expect(cards, findsNWidgets(9));

    // Nine cards leave an odd slot; an empty Expanded holds it open so the
    // last card does not stretch across the whole row.
    expect(tester.getSize(cards.last).width, tester.getSize(cards.first).width);
  });
}
