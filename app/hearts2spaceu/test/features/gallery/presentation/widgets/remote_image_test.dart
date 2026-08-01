import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/features/gallery/presentation/widgets/remote_image.dart';

/// In the test environment `Image.network` never resolves to a real image, which
/// is exactly the state these tests care about: what the user sees while a cover
/// is loading, or once its URL has died.
Future<void> _pump(WidgetTester tester, Widget image) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(child: SizedBox(width: 100, height: 100, child: image)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows a placeholder before any frame arrives', (tester) async {
    // The regression this guards: keying the placeholder off loadingBuilder's
    // `progress == null` renders an *empty* image for the whole connect phase,
    // so a slow or hanging request looks like a blank hole rather than a
    // loading tile.
    await _pump(tester, const RemoteImage(url: 'https://example.com/a.jpg'));

    expect(find.byIcon(Icons.broken_image_rounded), findsOneWidget);
  });

  testWidgets('a caller-supplied fallback replaces the default', (
    tester,
  ) async {
    await _pump(
      tester,
      const RemoteImage(
        url: 'https://example.com/a.jpg',
        fallback: ColoredBox(
          color: Colors.teal,
          child: Icon(Icons.album_rounded),
        ),
      ),
    );

    expect(find.byIcon(Icons.album_rounded), findsOneWidget);
    expect(find.byIcon(Icons.broken_image_rounded), findsNothing);
  });
}
