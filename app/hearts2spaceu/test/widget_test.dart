// Basic smoke test for the app shell.
//
// See https://docs.flutter.dev/cookbook/testing/widget/introduction for more
// on widget testing.

import 'package:flutter_test/flutter_test.dart';

import 'package:hearts2spaceu/app/app.dart';

void main() {
  testWidgets('App renders the home page', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Hearts2SpaceU'), findsWidgets);
    expect(find.text('Welcome to Hearts2SpaceU 👋'), findsOneWidget);
  });
}
