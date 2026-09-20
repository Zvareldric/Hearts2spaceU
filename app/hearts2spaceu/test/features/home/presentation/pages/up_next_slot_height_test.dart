import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/app/widgets/cards/app_card.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/app/widgets/states/error_view.dart';
import 'package:hearts2spaceu/app/widgets/states/loading_view.dart';
import 'package:hearts2spaceu/features/home/presentation/widgets/up_next_card.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';

import '../../../../app/sweep/page_catalog.dart';

/// Renders [slot] at a fixed width and returns its laid-out height.
Future<double> _slotHeight(WidgetTester tester, Widget slot) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(child: SizedBox(width: 360, child: slot)),
      ),
    ),
  );
  // pump() only — LoadingView's spinner animates forever, so pumpAndSettle
  // would time out.
  await tester.pump();
  return tester.getSize(find.byWidget(slot)).height;
}

void main() {
  // Real Roboto, because this is a layout measurement. In the placeholder test
  // face — twice Roboto's width — the error message wraps to three lines and
  // needs 60px. The states used to sit in a fixed 48px box, so that third line
  // was silently clipped and this test passed; now that the box is a minimum,
  // the placeholder face makes the error state taller than the others. On a
  // real phone the message fits and all four states are 82px, which is the
  // claim this test is for.
  setUpAll(loadRealFonts);

  testWidgets('Home "Up next" slot keeps one height across all four states', (
    tester,
  ) async {
    final event = Event(
      id: 'e1',
      title: 'Alpha Show',
      startDateTime: DateTime(2026, 8, 20, 17, 30),
    );

    final loading = AppCard(child: const LoadingView(compact: true));
    final empty = AppCard(
      child: const EmptyView(message: 'No upcoming events yet.', compact: true),
    );
    final error = AppCard(
      child: ErrorView(
        message: "Couldn't load the schedule.",
        onRetry: () {},
        compact: true,
      ),
    );
    final data = UpNextCard(event: event);

    final loadingHeight = await _slotHeight(tester, loading);
    final emptyHeight = await _slotHeight(tester, empty);
    final errorHeight = await _slotHeight(tester, error);
    final dataHeight = await _slotHeight(tester, data);

    // Equal heights mean switching states never pushes the sections below
    // ("Coming soon") up or down — the reflow bug this guards against.
    expect(emptyHeight, loadingHeight);
    expect(errorHeight, loadingHeight);
    expect(dataHeight, loadingHeight);
  });
}
