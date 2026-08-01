import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/features/home/presentation/pages/home_page.dart';

/// Home's four quick actions sit in a single row (Design System V2). Four
/// across is the tightest layout in the app: at phone widths each tile gets
/// roughly 70dp, so this is where a long label like "Statistics" would clip.
Future<void> _pumpHome(WidgetTester tester, double width) async {
  tester.view
    ..physicalSize = Size(width, 1200)
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(theme: AppTheme.light, home: const HomePage()),
    ),
  );
  await tester.pump();
}

void main() {
  for (final width in [360.0, 320.0, 280.0]) {
    testWidgets('the quick-action row does not overflow at ${width}dp', (
      tester,
    ) async {
      await _pumpHome(tester, width);

      expect(tester.takeException(), isNull);
      for (final label in ['Members', 'Music', 'Statistics', 'Updates']) {
        expect(find.text(label), findsOneWidget, reason: '$label is missing');
      }
    });
  }
}
