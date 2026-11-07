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

      expect(find.text('FULL TIME'), findsNWidgets(2));
      expect(find.text('2 - 1'), findsOneWidget);
    },
  );

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

    expect(find.text('MATCH REPORT'), findsOneWidget);
    expect(find.text('Match report unavailable'), findsOneWidget);
    expect(find.text('Match Dynamics'), findsOneWidget);
    expect(find.text('Possession'), findsOneWidget);
    expect(find.text('Total Shots'), findsOneWidget);
    expect(find.text('On Target'), findsOneWidget);
    expect(find.text('Match timeline unavailable'), findsOneWidget);
    expect(find.text('Manager Quotes'), findsOneWidget);
    expect(
      find.text('No verified manager quote is available for this team.'),
      findsNWidgets(2),
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
  finishedProvisional: finished,
  minutes: minutes,
);
