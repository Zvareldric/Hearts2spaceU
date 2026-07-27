// Basic smoke test for the app shell.
//
// See https://docs.flutter.dev/cookbook/testing/widget/introduction for more
// on widget testing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hearts2spaceu/app/app.dart';
import 'package:hearts2spaceu/features/home/presentation/pages/home_page.dart';

void main() {
  testWidgets('App renders the home page', (WidgetTester tester) async {
    // ProviderScope: HomePage reads Riverpod providers (Up Next section),
    // same as production `main.dart`.
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Structural, not copy-based: Home's content is mid-redesign (Design
    // System V1, docs/specs/home-layout.md) and its placeholders change every
    // sub-checkpoint (3.1-3.5). This only asserts the app boots into Home.
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
