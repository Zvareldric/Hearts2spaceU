import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/features/home/presentation/pages/home_page.dart';
import 'package:hearts2spaceu/routes/app_routes.dart';

/// Home's "Up next" slot still shows only the next event, but "See all" now
/// means every deadline — votes included — so it opens the Agenda instead of
/// switching to the Schedule tab (docs/specs/agenda.md §5).
void main() {
  testWidgets('"See all" on Up next opens the Agenda', (tester) async {
    final pushed = <String>[];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HomePage(),
          onGenerateRoute: (settings) {
            pushed.add(settings.name!);
            return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
          },
        ),
      ),
    );
    await tester.pump();

    // Home has a "See all" per section, so aim at the one in the Up next
    // header row (SectionHeader uppercases its label).
    final upNextHeader = find
        .ancestor(of: find.text('UP NEXT'), matching: find.byType(Row))
        .first;

    await tester.tap(
      find.descendant(of: upNextHeader, matching: find.text('See all')),
    );
    await tester.pump();

    expect(pushed, [AppRoutes.agenda]);
  });
}
