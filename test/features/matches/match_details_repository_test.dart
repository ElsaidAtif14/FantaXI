import 'dart:async';

import 'package:fantasy/features/matches/data/datasources/premier_league_match_data_source.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/data/repositories/match_details_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixture = FixtureModel(
    id: 73,
    code: 2645267,
    gameweek: 8,
    kickoffTime: DateTime.utc(2026, 10, 24, 16, 30),
    homeTeamId: 6,
    awayTeamId: 19,
    homeScore: 0,
    awayScore: 2,
    started: true,
    finished: true,
    finishedProvisional: true,
    minutes: 90,
  );

  test(
    'validates PL match identity and shares/caches duplicate requests',
    () async {
      final source = _FakeSource(_validMatch);
      final repository = MatchDetailsRepositoryImpl(source);
      final first = await repository.getDetails(
        fixture: fixture,
        homeTeamName: 'Chelsea',
        awayTeamName: 'Tottenham Hotspur',
      );
      final second = await repository.getDetails(
        fixture: fixture,
        homeTeamName: 'Chelsea',
        awayTeamName: 'Tottenham Hotspur',
      );
      expect(first.isRight(), isTrue);
      expect(second.isRight(), isTrue);
      expect(source.calls, 1);
    },
  );

  test('accepts the FPL short team names from the failing fixture', () async {
    expect(
      await _accepted(_leedsSpursMatch, _leedsSpursFixture, 'Leeds', 'Spurs'),
      isTrue,
    );
  });

  test('accepts either PL name form when it equals the FPL name', () async {
    // Official PL name form.
    expect(
      await _accepted(_validMatch, fixture, 'Chelsea', 'Tottenham Hotspur'),
      isTrue,
    );
    // PL shortName form.
    expect(
      await _accepted(_leedsSpursMatch, _leedsSpursFixture, 'Leeds', 'Spurs'),
      isTrue,
    );
  });

  test('rejects swapped home and away teams', () async {
    final swapped = <String, dynamic>{
      ..._leedsSpursMatch,
      'homeTeam': _leedsSpursMatch['awayTeam'],
      'awayTeam': _leedsSpursMatch['homeTeam'],
    };
    expect(
      await _accepted(swapped, _leedsSpursFixture, 'Leeds', 'Spurs'),
      isFalse,
    );
  });

  test('rejects a genuinely incorrect team pairing', () async {
    final wrongPairing = <String, dynamic>{
      ..._leedsSpursMatch,
      'awayTeam': {
        'id': '8',
        'name': 'Chelsea',
        'shortName': 'Chelsea',
        'score': 0,
        'halfTimeScore': 0,
      },
    };
    expect(
      await _accepted(wrongPairing, _leedsSpursFixture, 'Leeds', 'Spurs'),
      isFalse,
    );
  });

  test('rejects a response for a different candidate match id', () async {
    final wrongCandidate = <String, dynamic>{
      ..._leedsSpursMatch,
      'matchId': '2645285',
    };
    expect(
      await _accepted(wrongCandidate, _leedsSpursFixture, 'Leeds', 'Spurs'),
      isFalse,
    );
  });

  test(
    'resolves promptly instead of deadlocking on in-flight bookkeeping',
    () async {
      final source = _FakeSource(_validMatch, failSections: true);
      final repository = MatchDetailsRepositoryImpl(source);

      final first = await repository
          .getDetails(
            fixture: fixture,
            homeTeamName: 'Chelsea',
            awayTeamName: 'Tottenham Hotspur',
          )
          .timeout(const Duration(seconds: 2));
      expect(first.isRight(), isTrue);

      // A partial result is not cached, so reaching the source again proves the
      // in-flight entry was cleared after completion.
      final second = await repository
          .getDetails(
            fixture: fixture,
            homeTeamName: 'Chelsea',
            awayTeamName: 'Tottenham Hotspur',
          )
          .timeout(const Duration(seconds: 2));
      expect(second.isRight(), isTrue);
      expect(source.calls, 2);
    },
  );

  test(
    'rejects a wrong team, season, competition or kickoff candidate',
    () async {
      for (final mismatch in [
        {
          'homeTeam': {
            'name': 'Arsenal',
            'id': '1',
            'score': 0,
            'halfTimeScore': 0,
          },
        },
        {
          'seasonInfo': {'id': '2025'},
        },
        {'competition': 'Other league'},
        {'kickoff': '2026-10-25 12:00:00', 'kickoffTimezone': 'GMT'},
      ]) {
        final source = _FakeSource({..._validMatch, ...mismatch});
        final result = await MatchDetailsRepositoryImpl(source).getDetails(
          fixture: fixture,
          homeTeamName: 'Chelsea',
          awayTeamName: 'Tottenham Hotspur',
        );
        expect(result.isLeft(), isTrue);
      }
    },
  );

  test('keeps match metadata if optional section endpoints fail', () async {
    final source = _FakeSource(_validMatch, failSections: true);
    final repository = MatchDetailsRepositoryImpl(source);
    final result = await repository.getDetails(
      fixture: fixture,
      homeTeamName: 'Chelsea',
      awayTeamName: 'Tottenham Hotspur',
    );
    final details = result.getOrElse(
      () => throw StateError('expected partial details'),
    );
    expect(details.matchId, 2645267);
    expect(details.events, isEmpty);
    expect(details.statistics, isEmpty);
    expect(details.failedSections, {'events', 'stats'});
    source.failSections = false;
    await repository.getDetails(
      fixture: fixture,
      homeTeamName: 'Chelsea',
      awayTeamName: 'Tottenham Hotspur',
    );
    expect(source.calls, 2);
  });

  test(
    'times out a stuck details source and clears its in-flight entry',
    () async {
      final source = _HungSource();
      final repository = MatchDetailsRepositoryImpl(
        source,
        requestTimeout: Duration.zero,
      );
      final first = await repository.getDetails(
        fixture: fixture,
        homeTeamName: 'Chelsea',
        awayTeamName: 'Tottenham Hotspur',
      );
      final second = await repository.getDetails(
        fixture: fixture,
        homeTeamName: 'Chelsea',
        awayTeamName: 'Tottenham Hotspur',
      );
      expect(first.isLeft(), isTrue);
      expect(second.isLeft(), isTrue);
      expect(source.calls, 2);
    },
  );
}

final _validMatch = <String, dynamic>{
  'matchId': '2645267',
  'competition': 'Premier League',
  'seasonInfo': {'id': '2026'},
  'kickoff': '2026-10-24 17:30:00',
  'kickoffTimezone': 'BST',
  'period': 'FullTime',
  'homeTeam': {
    'id': '8',
    'name': 'Chelsea',
    'shortName': 'Chelsea',
    'score': 0,
    'halfTimeScore': 0,
  },
  'awayTeam': {
    'id': '6',
    'name': 'Tottenham Hotspur',
    'shortName': 'Spurs',
    'score': 2,
    'halfTimeScore': 0,
  },
};

/// Real payload shape for the fixture that failed in production: FPL exposes
/// `Leeds` and `Spurs`, while the PL API's official names are `Leeds United`
/// and `Tottenham Hotspur` and its `shortName` fields match FPL.
final _leedsSpursFixture = FixtureModel(
  id: 97,
  code: 2645291,
  gameweek: 10,
  kickoffTime: DateTime.utc(2026, 11, 7, 12, 30),
  homeTeamId: 13,
  awayTeamId: 19,
  homeScore: 1,
  awayScore: 0,
  started: true,
  finished: false,
  finishedProvisional: true,
  minutes: 90,
);

final _leedsSpursMatch = <String, dynamic>{
  'matchId': '2645291',
  'competition': 'Premier League',
  'seasonInfo': {'id': '2026'},
  'matchWeek': 10,
  'kickoff': '2026-11-07 12:30:00',
  'kickoffTimezone': 'GMT',
  'period': 'FullTime',
  'homeTeam': {
    'id': '2',
    'name': 'Leeds United',
    'shortName': 'Leeds',
    'score': 1,
    'halfTimeScore': 0,
  },
  'awayTeam': {
    'id': '6',
    'name': 'Tottenham Hotspur',
    'shortName': 'Spurs',
    'score': 0,
    'halfTimeScore': 0,
  },
};

Future<bool> _accepted(
  Map<String, dynamic> match,
  FixtureModel fixture,
  String homeTeamName,
  String awayTeamName,
) async {
  final result = await MatchDetailsRepositoryImpl(
    _FakeSource(match),
  ).getDetails(
    fixture: fixture,
    homeTeamName: homeTeamName,
    awayTeamName: awayTeamName,
  );
  return result.isRight();
}

class _FakeSource extends PremierLeagueMatchDataSource {
  _FakeSource(this.match, {this.failSections = false});
  final Map<String, dynamic> match;
  bool failSections;
  int calls = 0;

  @override
  Future<PremierLeagueMatchPayload> getMatch(int id) async {
    calls++;
    return PremierLeagueMatchPayload(
      match: match,
      events:
          failSections
              ? null
              : {
                'homeTeam': {'id': '8'},
                'awayTeam': {'id': '6'},
              },
      stats: failSections ? null : const [],
      failedSections: failSections ? const {'events', 'stats'} : const {},
    );
  }
}

class _HungSource extends PremierLeagueMatchDataSource {
  int calls = 0;

  @override
  Future<PremierLeagueMatchPayload> getMatch(int id) {
    calls++;
    return Completer<PremierLeagueMatchPayload>().future;
  }
}
