import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_spacing.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/app/widgets/cards/coming_soon_card.dart';

void main() {
  testWidgets('three ComingSoonCards fit one row at phone width', (
    tester,
  ) async {
    // Narrowest common phone width, minus Home's screen padding — the real
    // constraint the "Coming soon" grid has to survive.
    const phoneWidth = 360.0;
    const available = phoneWidth - (AppSpacing.screenPadding * 2);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: available,
              child: const Row(
                children: [
                  Expanded(
                    child: ComingSoonCard(
                      icon: Icons.collections_bookmark_rounded,
                      label: 'Collection',
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ComingSoonCard(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ComingSoonCard(
                      icon: Icons.music_note_rounded,
                      label: 'Music',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // A RenderFlex overflow surfaces as a FlutterError during layout.
    expect(tester.takeException(), isNull);
  });
}
