import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/features/statistics/presentation/widgets/count_bar.dart';

/// Renders one bar at a fixed width and returns the size of its filled portion.
Future<Size> _fillSize(
  WidgetTester tester, {
  required int count,
  required int max,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 200,
            child: CountBar(label: 'Y', count: count, max: max),
          ),
        ),
      ),
    ),
  );
  // The fill animates in; settle so the measurement is of its final width.
  await tester.pumpAndSettle();

  return tester.getSize(
    find.descendant(
      of: find.byType(FractionallySizedBox),
      matching: find.byType(DecoratedBox),
    ),
  );
}

void main() {
  // A bar that renders at full width regardless of its count is worse than no
  // bar: it silently states that every year was equally busy.
  testWidgets('the fill is proportional to count/max', (tester) async {
    final half = await _fillSize(tester, count: 1, max: 2);
    final full = await _fillSize(tester, count: 2, max: 2);

    expect(half.width, closeTo(full.width / 2, 1));
    expect(half.width, lessThan(full.width));
  });

  testWidgets('the fill has height — it is actually visible', (tester) async {
    // The regression this guards: with a loose height constraint the fill
    // collapses to zero height and only the track shows, which reads as a full
    // bar on every row.
    final size = await _fillSize(tester, count: 1, max: 4);

    expect(size.height, greaterThan(0));
  });

  testWidgets('a zero max does not divide by zero or overflow', (tester) async {
    final size = await _fillSize(tester, count: 0, max: 0);

    expect(tester.takeException(), isNull);
    expect(size.width, 0);
  });
}
