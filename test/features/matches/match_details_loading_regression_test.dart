import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:fantasy/core/di/injection.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/domain/repositories/match_details_repository.dart';
import 'package:fantasy/features/matches/presentation/cubit/match_details_cubit.dart';
import 'package:fantasy/features/matches/presentation/pages/match_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async => sl.reset());
  tearDown(() async => sl.reset());

  testWidgets('successful details leave loading and preserve partial events', (
    tester,
  ) async {
    _register(_SuccessRepository());
    await _pump(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('0 - 2'), findsOneWidget);
    expect(find.textContaining('Half-time 0 - 0'), findsOneWidget);
    expect(find.textContaining('Own goal'), findsOneWidget);
    expect(
      find.text('Some match detail sections could not be loaded.'),
      findsOneWidget,
    );
  });

  testWidgets('complete failure shows retry and keeps FPL fixture data', (
    tester,
  ) async {
    _register(_FailureRepository());
    await _pump(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('1 - 0'), findsOneWidget);
    expect(find.text('Premier League request failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('a hung repository reaches a visible timeout state', (
    tester,
  ) async {
    _register(_FailureRepository(hang: true), timeout: Duration.zero);
    await _pump(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.text('Match details request timed out. Please retry.'),
      findsOneWidget,
    );
    expect(find.text('1 - 0'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}

void _register(MatchDetailsRepository repository, {Duration? timeout}) {
  sl.registerFactory<MatchDetailsCubit>(
    () => MatchDetailsCubit(
      repository,
      loadTimeout: timeout ?? const Duration(seconds: 25),
    ),
  );
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 2048);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: MatchDetailsScreen(
        fixtureId: 73,
        fixture: _fixture,
        teams: {
          6: TeamModel(id: 6, name: 'Chelsea', shortName: 'CHE', code: ''),
          19: TeamModel(
            id: 19,
            name: 'Tottenham Hotspur',
            shortName: 'TOT',
            code: '',
          ),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final _fixture = FixtureModel(
  id: 73,
  code: 2645267,
  gameweek: 8,
  kickoffTime: DateTime.utc(2026, 10, 24, 16, 30),
  homeTeamId: 6,
  awayTeamId: 19,
  homeScore: 1,
  awayScore: 0,
  started: true,
  finished: true,
  finishedProvisional: true,
  minutes: 90,
);

class _SuccessRepository implements MatchDetailsRepository {
  @override
  Future<Either<Failure, PremierLeagueMatchDetails>> getDetails({
    required FixtureModel fixture,
    required String? homeTeamName,
    required String? awayTeamName,
  }) async => Right(
    PremierLeagueMatchDetails.fromParts(
      match: {
        'matchId': '2645267',
        'competition': 'Premier League',
        'seasonInfo': {'id': '2026'},
        'matchWeek': 8,
        'kickoff': '2026-10-24 17:30:00',
        'kickoffTimezone': 'BST',
        'period': 'FullTime',
        'homeTeam': {
          'id': '8',
          'name': 'Chelsea',
          'score': 0,
          'halfTimeScore': 0,
        },
        'awayTeam': {
          'id': '6',
          'name': 'Tottenham Hotspur',
          'score': 2,
          'halfTimeScore': 0,
        },
      },
      eventsJson: {
        'homeTeam': {'id': '8', 'goals': [], 'cards': [], 'subs': []},
        'awayTeam': {
          'id': '6',
          'goals': [
            {'time': '77', 'goalType': 'Own'},
          ],
          'cards': [],
          'subs': [],
        },
      },
      failedSections: const {'stats'},
    ),
  );
}

class _FailureRepository implements MatchDetailsRepository {
  _FailureRepository({this.hang = false});
  final bool hang;

  @override
  Future<Either<Failure, PremierLeagueMatchDetails>> getDetails({
    required FixtureModel fixture,
    required String? homeTeamName,
    required String? awayTeamName,
  }) {
    if (hang) {
      return Completer<Either<Failure, PremierLeagueMatchDetails>>().future;
    }
    return Future.value(
      Left(Failure(errMessage: 'Premier League request failed')),
    );
  }
}
