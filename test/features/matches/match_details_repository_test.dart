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
  'homeTeam': {'id': '8', 'name': 'Chelsea', 'score': 0, 'halfTimeScore': 0},
  'awayTeam': {
    'id': '6',
    'name': 'Tottenham Hotspur',
    'score': 2,
    'halfTimeScore': 0,
  },
};

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
