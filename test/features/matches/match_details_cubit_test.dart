import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/domain/repositories/match_details_repository.dart';
import 'package:fantasy/features/matches/presentation/cubit/match_details_cubit.dart';
import 'package:fantasy/features/matches/presentation/cubit/match_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emits loading while details are in flight, then loaded', () async {
    final pending = Completer<Either<Failure, PremierLeagueMatchDetails>>();
    final cubit = MatchDetailsCubit(_FakeRepository(pending.future));
    final load = cubit.load(
      _fixture,
      homeTeamName: 'Chelsea',
      awayTeamName: 'Spurs',
    );

    expect(cubit.state, isA<MatchDetailsLoading>());
    pending.complete(Right(PremierLeagueMatchDetails.fromParts()));
    await load;

    expect(cubit.state, isA<MatchDetailsLoaded>());
    await cubit.close();
  });

  test('emits an error state for unavailable Premier League mapping', () async {
    final cubit = MatchDetailsCubit(
      _FakeRepository(
        Future.value(Left(Failure(errMessage: 'Mapping unavailable'))),
      ),
    );
    await cubit.load(_fixture, homeTeamName: 'Chelsea', awayTeamName: 'Spurs');
    expect(cubit.state, isA<MatchDetailsError>());
    await cubit.close();
  });
}

final _fixture = FixtureModel(
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

class _FakeRepository implements MatchDetailsRepository {
  _FakeRepository(this.result);
  final Future<Either<Failure, PremierLeagueMatchDetails>> result;

  @override
  Future<Either<Failure, PremierLeagueMatchDetails>> getDetails({
    required FixtureModel fixture,
    required String? homeTeamName,
    required String? awayTeamName,
  }) => result;
}
