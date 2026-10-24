import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/features/agenda/presentation/pages/agenda_page.dart';
import 'package:hearts2spaceu/features/home/presentation/pages/home_page.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';
import 'package:hearts2spaceu/features/schedule/domain/event_repository.dart';
import 'package:hearts2spaceu/features/schedule/presentation/pages/schedule_page.dart';
import 'package:hearts2spaceu/features/schedule/presentation/providers/event_providers.dart';
import 'package:hearts2spaceu/features/voting/domain/voting_campaign.dart';
import 'package:hearts2spaceu/features/voting/domain/voting_repository.dart';
import 'package:hearts2spaceu/features/voting/presentation/providers/voting_providers.dart';
import 'package:hearts2spaceu/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Found by running the release build against the live calendar: two
/// fansigns marked "[CANCELLED]" were shown as ordinary upcoming events, and
/// the first of them would have been Home's "Up next".
class _Events implements EventRepository {
  @override
  Future<List<Event>> getEvents({bool forceRefresh = false}) async {
    final now = DateTime.now();
    return [
      Event(
        id: 'cancelled',
        title: 'Fansign in Shenzhen',
        startDateTime: now.add(const Duration(days: 1)),
        type: 'fanmeeting',
        status: EventStatus.cancelled,
      ),
      Event(
        id: 'going-ahead',
        title: 'Music Awards',
        startDateTime: now.add(const Duration(days: 2)),
        type: 'award',
      ),
    ];
  }
}

class _NoVotes implements VotingRepository {
  @override
  Future<List<VotingCampaign>> getCampaigns() async => const [];
}

Future<void> _pump(WidgetTester tester, Widget page) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(_Events()),
        votingRepositoryProvider.overrideWithValue(_NoVotes()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: page,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Up next skips a cancelled event for the next real one', (
    tester,
  ) async {
    await _pump(tester, const HomePage());

    expect(find.text('Music Awards'), findsOneWidget);
    expect(find.text('Fansign in Shenzhen'), findsNothing);
  });

  testWidgets('the Agenda leaves a cancelled event out', (tester) async {
    await _pump(tester, const AgendaPage());

    expect(find.text('Music Awards'), findsOneWidget);
    expect(find.text('Fansign in Shenzhen'), findsNothing);
  });

  testWidgets('the Schedule keeps it, struck through and labelled', (
    tester,
  ) async {
    // That a fansign was cancelled is itself the news, so it is not hidden —
    // but it must never read as going ahead.
    await _pump(tester, const SchedulePage());

    final title = tester.widget<Text>(find.text('Fansign in Shenzhen'));
    expect(title.style?.decoration, TextDecoration.lineThrough);
    expect(find.text('CANCELLED'), findsOneWidget);
    // The status replaces the type: it is the one fact that matters now.
    expect(find.text('FAN MEETING'), findsNothing);

    // The event that is going ahead is untouched.
    final other = tester.widget<Text>(find.text('Music Awards'));
    expect(other.style?.decoration, isNot(TextDecoration.lineThrough));
  });
}
