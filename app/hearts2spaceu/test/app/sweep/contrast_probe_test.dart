import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/app/widgets/layout/ambient_background.dart';

import 'contrast_probe.dart';

/// The probe is itself code that can be wrong, and every sweep verdict rests on
/// it — so it is checked against cases whose answer is known by hand.
Future<List<ContrastFailure>> _probe(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
      builder: (_, page) => AmbientBackground(child: page!),
      home: Scaffold(body: Center(child: child)),
    ),
  );
  return measureContrast(tester, brightness);
}

void main() {
  testWidgets('passes text that clears the bar', (tester) async {
    final failures = await _probe(
      tester,
      const Text('ink', style: TextStyle(color: Color(0xFF16283C))),
    );
    expect(failures, isEmpty);
  });

  testWidgets('catches mid-grey body text on a white card', (tester) async {
    // #888888 on opaque white is 3.54:1 — a textbook failure of the 4.5 bar.
    final failures = await _probe(
      tester,
      const ColoredBox(
        color: Colors.white,
        child: Text('grey', style: TextStyle(color: Color(0xFF888888))),
      ),
    );
    expect(failures.single.ratio, closeTo(3.54, 0.01));
    expect(failures.single.required, 4.5);
  });

  testWidgets('holds large text to 3:1, not 4.5:1', (tester) async {
    final failures = await _probe(
      tester,
      const ColoredBox(
        color: Colors.white,
        child: Text(
          'big',
          style: TextStyle(color: Color(0xFF888888), fontSize: 24),
        ),
      ),
    );
    expect(failures, isEmpty, reason: '3.54:1 clears the large-text bar');
  });

  testWidgets('measures over the worst blob, not the pale base', (
    tester,
  ) async {
    // The old inkMuted: 4.60:1 on the pale base the old contrast test used,
    // 3.90:1 on a glass card over the pink blob. The probe has to find 3.90.
    final failures = await _probe(
      tester,
      DecoratedBox(
        decoration: const BoxDecoration(color: Color(0x8CFFFFFF)),
        child: const Text('old', style: TextStyle(color: Color(0xFF60758A))),
      ),
    );
    expect(failures.single.ratio, closeTo(3.90, 0.01));
  });

  testWidgets('sees a light ink on a dark card', (tester) async {
    // The dark-mode bug this sweep exists for: a light-palette ink on dark
    // glass, measured by hand at 3.12:1 on the plain base.
    final failures = await _probe(
      tester,
      const DecoratedBox(
        decoration: BoxDecoration(color: Color(0x14FFFFFF)),
        child: Text('leak', style: TextStyle(color: Color(0xFF60758A))),
      ),
      brightness: Brightness.dark,
    );
    expect(failures, isNotEmpty);
    expect(failures.first.ratio, lessThan(3.2));
  });

  testWidgets('skips faded, inactive text', (tester) async {
    final failures = await _probe(
      tester,
      const Opacity(
        opacity: 0.6,
        child: Text('disabled', style: TextStyle(color: Color(0xFF888888))),
      ),
    );
    expect(failures, isEmpty);
  });
}
