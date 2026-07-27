import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_motion.dart';

/// Pumps a widget under a given [MediaQueryData] and reports what duration
/// [AppMotion.of] hands back for [AppMotion.base].
Future<Duration> _resolvedDuration(
  WidgetTester tester, {
  required bool disableAnimations,
}) async {
  late Duration resolved;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Builder(
        builder: (context) {
          resolved = AppMotion.of(context, AppMotion.base);
          return const SizedBox();
        },
      ),
    ),
  );
  return resolved;
}

void main() {
  testWidgets('animations run at full duration by default', (tester) async {
    expect(
      await _resolvedDuration(tester, disableAnimations: false),
      AppMotion.base,
    );
  });

  testWidgets('reduced motion collapses every duration to zero', (
    tester,
  ) async {
    // The accessibility guarantee: one switch disables motion app-wide,
    // because every animated widget routes its duration through AppMotion.of.
    expect(
      await _resolvedDuration(tester, disableAnimations: true),
      Duration.zero,
    );
  });
}
