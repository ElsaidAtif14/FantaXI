import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/presentation/pages/match_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final teams = {
    1: TeamModel(id: 1, name: 'Arsenal', shortName: 'ARS', code: ''),
    2: TeamModel(id: 2, name: 'Chelsea', shortName: 'CHE', code: ''),
  };

  testWidgets('shows fixture teams and kickoff details when scheduled', (
    tester,
  ) async {
    await _pumpDetails(tester, _fixture(started: false), teams);

    expect(find.text('Arsenal'), findsOneWidget);
    expect(find.text('Chelsea'), findsOneWidget);
    expect(find.text('UPCOMING'), findsOneWidget);
    expect(find.text('vs'), findsOneWidget);
  });

  testWidgets('shows current score and live status for an active fixture', (
    tester,
  ) async {
    await _pumpDetails(
      tester,
      _fixture(
        started: true,
        finished: false,
        homeScore: 1,
        awayScore: 0,
        minutes: 55,
      ),
      teams,
    );

    expect(find.text("LIVE · 55'"), findsOneWidget);
    expect(find.text('1 - 0'), findsOneWidget);
  });

  testWidgets(
    'shows final score and full-time status for a completed fixture',
    (tester) async {
      await _pumpDetails(
        tester,
        _fixture(started: true, finished: true, homeScore: 2, awayScore: 1),
        teams,
      );

      expect(find.text('FULL TIME'), findsOneWidget);
      expect(find.text('2 - 1'), findsOneWidget);
    },
  );

  testWidgets('shows full-time status when only the provisional flag is set', (
    tester,
  ) async {
    await _pumpDetails(
      tester,
      _fixture(
        started: true,
        finished: false,
        finishedProvisional: true,
        homeScore: 3,
        awayScore: 1,
        minutes: 90,
      ),
      teams,
    );

    expect(find.text('FULL TIME'), findsOneWidget);
    expect(find.textContaining('LIVE'), findsNothing);
    expect(find.text('3 - 1'), findsOneWidget);
  });

  testWidgets('handles invalid fixture IDs without making a request', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MatchDetailsScreen(fixtureId: 0)),
    );

    expect(find.text('This fixture link is invalid.'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('renders recap sections with unavailable data states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 2048);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpDetails(tester, _fixture(started: false), teams);

    expect(find.text('MATCH FACTS'), findsOneWidget);
    expect(find.text('DATE'), findsOneWidget);
    expect(find.text('MATCH DYNAMICS'), findsOneWidget);
    expect(find.text('Statistics unavailable'), findsOneWidget);
    expect(find.text('Match timeline unavailable'), findsOneWidget);
    // Removed permanently: the section never contained real data.
    expect(find.text('Manager Quotes'), findsNothing);
    expect(
      find.text('No verified manager quote is available for this team.'),
      findsNothing,
    );
    expect(find.text('Erling Haaland'), findsNothing);
    expect(find.text('Pep Guardiola'), findsNothing);

    await tester.tap(find.text('Lineups'));
    await tester.pumpAndSettle();
    expect(find.text('Lineups unavailable'), findsOneWidget);
  });
}

Future<void> _pumpDetails(
  WidgetTester tester,
  FixtureModel fixture,
  Map<int, TeamModel> teams,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MatchDetailsScreen(
        fixtureId: fixture.id,
        fixture: fixture,
        teams: teams,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

FixtureModel _fixture({
  bool started = false,
  bool finished = false,
  bool? finishedProvisional,
  int? homeScore,
  int? awayScore,
  int minutes = 0,
}) => FixtureModel(
  id: 42,
  gameweek: 7,
  kickoffTime: DateTime.utc(2026, 10, 20, 18),
  homeTeamId: 1,
  awayTeamId: 2,
  homeScore: homeScore,
  awayScore: awayScore,
  started: started,
  finished: finished,
  finishedProvisional: finishedProvisional ?? finished,
  minutes: minutes,
);
