import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/data/cached_event_repository.dart';
import 'package:hearts2spaceu/features/schedule/data/calendar_event_repository.dart';
import 'package:hearts2spaceu/features/schedule/presentation/pages/schedule_page.dart';
import 'package:hearts2spaceu/features/schedule/presentation/providers/event_providers.dart';
import 'package:hearts2spaceu/routes/app_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('a first launch says how old the schedule is', (tester) async {
    // Found by running the release build: a reader whose phone had never
    // fetched the schedule saw the attribution but no "Updated …" line, and
    // kept not seeing it until the app was restarted. The timestamp was read
    // from the cache in parallel with the very fetch that fills it, found
    // nothing, and was never asked again.
    SharedPreferences.setMockInitialValues({});
    final soon = DateTime.now().add(const Duration(days: 3));
    final day =
        '${soon.year}-${soon.month.toString().padLeft(2, '0')}-'
        '${soon.day.toString().padLeft(2, '0')}';
    final feed = MockClient(
      (_) async => http.Response.bytes(
        utf8.encode(
          jsonEncode([
            {
              'id': 'e1',
              'title': 'Fansign in Tokyo',
              'date': day,
              'time': '18:00',
              'cat': 'fansign',
              'timezone': 'Asia/Tokyo',
            },
          ]),
        ),
        200,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(
            CachedEventRepository(
              remote: CalendarEventRepository(
                client: feed,
                url: 'https://example.com/feed',
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: SchedulePage(),
        ),
      ),
    );
    // The cache is read and written through shared_preferences, which settles
    // on the real event loop.
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.text('Fansign in Tokyo'), findsOneWidget);
    expect(find.textContaining('Updated just now'), findsOneWidget);
  });
}
