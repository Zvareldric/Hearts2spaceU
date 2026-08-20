import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/features/home/presentation/pages/home_page.dart';
import 'package:hearts2spaceu/routes/app_routes.dart';

/// Home's four quick actions sit in a single row (Design System V2). Four
/// across is the tightest layout in the app: at phone widths each tile gets
/// roughly 70dp, so this is where a long label like "Statistics" would clip.
/// [width] cramps the surface to a phone; the navigation test leaves it out,
/// since where the shortcut leads has nothing to do with how wide it is.
Future<void> _pumpHome(
  WidgetTester tester, {
  double? width,
  List<String>? pushed,
}) async {
  if (width != null) {
    tester.view
      ..physicalSize = Size(width, 1200)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: const HomePage(),
        onGenerateRoute: (settings) {
          pushed?.add(settings.name!);
          return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
        },
      ),
    ),
  );
  await tester.pump();
}

void main() {
  for (final width in [360.0, 320.0, 280.0]) {
    testWidgets('the quick-action row does not overflow at ${width}dp', (
      tester,
    ) async {
      await _pumpHome(tester, width: width);

      expect(tester.takeException(), isNull);
      for (final label in ['Members', 'Music', 'Statistics', 'Updates']) {
        expect(find.text(label), findsOneWidget, reason: '$label is missing');
      }
    });
  }

  testWidgets('the Music shortcut lands where Music lives', (tester) async {
    // Home and More have to mean the same thing by "Music", which is the
    // releases screen the official platforms now hang off.
    final pushed = <String>[];
    await _pumpHome(tester, pushed: pushed);

    await tester.tap(find.text('Music'));
    await tester.pump();

    expect(pushed, [AppRoutes.discography]);
  });
}
