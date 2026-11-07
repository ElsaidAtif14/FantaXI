import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/matches/data/datasources/premier_league_match_data_source.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/domain/repositories/match_details_repository.dart';

class MatchDetailsRepositoryImpl implements MatchDetailsRepository {
  MatchDetailsRepositoryImpl(
    this._source, {
    DateTime Function()? clock,
    this.requestTimeout = const Duration(seconds: 23),
  }) : _clock = clock ?? DateTime.now;

  final PremierLeagueMatchDataSource _source;
  final DateTime Function() _clock;
  final Duration requestTimeout;
  final Map<int, _Entry> _cache = {};
  final Map<int, Future<Either<Failure, PremierLeagueMatchDetails>>> _pending =
      {};

  @override
  Future<Either<Failure, PremierLeagueMatchDetails>> getDetails({
    required FixtureModel fixture,
    required String? homeTeamName,
    required String? awayTeamName,
  }) {
    final candidate = fixture.code;
    developer.log(
      'load started fpl_fixture_id=${fixture.id} candidate_pl_id=$candidate',
      name: 'match_details.repository',
    );
    if (candidate == null || candidate <= 0) {
      developer.log(
        'mapping rejected: FPL fixture has no usable code',
        name: 'match_details.repository',
      );
      return Future.value(
        Left(
          Failure(errMessage: 'Premier League match mapping is unavailable.'),
        ),
      );
    }
    final cached = _cache[candidate];
    if (cached != null && _clock().isBefore(cached.expiresAt)) {
      developer.log(
        'cache hit candidate_pl_id=$candidate',
        name: 'match_details.repository',
      );
      return Future.value(Right(cached.value));
    }
    developer.log(
      'cache miss candidate_pl_id=$candidate',
      name: 'match_details.repository',
    );
    final pending = _pending[candidate];
    if (pending != null) {
      developer.log(
        'sharing in-flight request candidate_pl_id=$candidate',
        name: 'match_details.repository',
      );
      return pending;
    }
    late final Future<Either<Failure, PremierLeagueMatchDetails>> request;
    request = _load(candidate, fixture, homeTeamName, awayTeamName)
        // The match request and parallel details batch each have 10s Dio timeouts.
        .timeout(
          requestTimeout,
          onTimeout: () {
            developer.log(
              'repository load timed out fpl_fixture_id=${fixture.id} candidate_pl_id=$candidate',
              name: 'match_details.repository',
            );
            return Left(
              Failure(errMessage: 'Premier League match details timed out.'),
            );
          },
        )
        .whenComplete(() => _pending.remove(candidate));
    _pending[candidate] = request;
    return request;
  }

  Future<Either<Failure, PremierLeagueMatchDetails>> _load(
    int candidate,
    FixtureModel fixture,
    String? homeName,
    String? awayName,
  ) async {
    try {
      final payload = await _source.getMatch(candidate);
      final details = PremierLeagueMatchDetails.fromParts(
        match: payload.match,
        eventsJson: payload.events,
        statsJson: payload.stats,
        lineupsJson: payload.lineups,
        officialsJson: payload.officials,
        commentaryJson: payload.commentary,
        failedSections: payload.failedSections,
      );
      final rejection = _validationFailure(
        details,
        fixture,
        homeName,
        awayName,
      );
      if (rejection != null) {
        developer.log(
          'mapping rejected candidate_pl_id=$candidate reason=$rejection',
          name: 'match_details.repository',
        );
        return Left(
          Failure(
            errMessage:
                'Premier League match could not be safely matched to this fixture.',
          ),
        );
      }
      developer.log(
        'mapping accepted fpl_fixture_id=${fixture.id} candidate_pl_id=$candidate',
        name: 'match_details.repository',
      );
      final completed = const {
        'fulltime',
        'finished',
        'complete',
      }.contains(details.status?.toLowerCase());
      if (payload.failedSections.isEmpty) {
        _cache[candidate] = _Entry(
          details,
          _clock().add(
            completed ? const Duration(hours: 24) : const Duration(seconds: 30),
          ),
        );
      }
      for (final section in const [
        'events',
        'stats',
        'lineups',
        'officials',
        'commentary',
      ]) {
        developer.log(
          'partial result section=$section ${payload.failedSections.contains(section) ? 'rejected' : 'accepted'}',
          name: 'match_details.repository',
        );
      }
      return Right(details);
    } catch (error, stackTrace) {
      developer.log(
        'details request failed fpl_fixture_id=${fixture.id} candidate_pl_id=$candidate: $error',
        name: 'match_details.repository',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(
        Failure(errMessage: 'Premier League match details are unavailable.'),
      );
    }
  }

  String? _validationFailure(
    PremierLeagueMatchDetails d,
    FixtureModel f,
    String? home,
    String? away,
  ) {
    if (d.matchId != f.code ||
        d.competition?.toLowerCase() != 'premier league') {
      return 'response match ID or competition did not match';
    }
    final expectedHome = _normalize(home);
    final expectedAway = _normalize(away);
    if (expectedHome.isEmpty ||
        expectedAway.isEmpty ||
        expectedHome != _normalize(d.homeTeam?.name) ||
        expectedAway != _normalize(d.awayTeam?.name)) {
      return 'home/away team names did not match';
    }
    final fixtureKickoff = f.kickoffTime;
    final matchKickoff = d.kickoff;
    if (fixtureKickoff == null || matchKickoff == null) {
      return 'fixture or match kickoff was missing';
    }
    final expectedSeason =
        fixtureKickoff.month >= 8
            ? fixtureKickoff.year
            : fixtureKickoff.year - 1;
    if (d.seasonId != expectedSeason) return 'season did not match';
    // Three hours permits ordinary kickoff changes while rejecting unrelated fixtures.
    if (matchKickoff.toUtc().difference(fixtureKickoff.toUtc()).abs() >
        const Duration(hours: 3)) {
      return 'kickoff differed by more than three hours';
    }
    return null;
  }

  String _normalize(String? value) =>
      (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

class _Entry {
  const _Entry(this.value, this.expiresAt);
  final PremierLeagueMatchDetails value;
  final DateTime expiresAt;
}
