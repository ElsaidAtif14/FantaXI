import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/bootstrap/data/models/gameweek_model.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/bootstrap/domain/repositories/bootstrap_repository.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/domain/repositories/matches_repository.dart';
import 'package:fantasy/features/matches/presentation/cubit/matches_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeBootstrapRepository bootstrap;
  late _FakeMatchesRepository matches;
  late MatchesCubit cubit;

  setUp(() {
    bootstrap = _FakeBootstrapRepository(_bootstrapData());
    matches = _FakeMatchesRepository();
    cubit = MatchesCubit(matches, bootstrap);
  });

  tearDown(() async => cubit.close());

  test('loads the current matchweek and handles an empty result', () async {
    matches.responses[7] = Right([]);

    await cubit.loadInitial();

    expect(cubit.state, isA<MatchesLoaded>());
    expect(cubit.state.gameweek, 7);
    expect((cubit.state as MatchesLoaded).fixtures, isEmpty);
  });

  test('changes gameweek and retries a failed request', () async {
    matches.responses[7] = Left(Failure(errMessage: 'Network unavailable'));
    matches.responses[8] = Right([_fixture(80)]);

    await cubit.loadInitial();
    expect(cubit.state, isA<MatchesError>());
    expect(cubit.state.gameweek, 7);

    matches.responses[7] = Right([_fixture(70)]);
    await cubit.retry();
    expect(cubit.state, isA<MatchesLoaded>());
    expect((cubit.state as MatchesLoaded).fixtures.single.id, 70);

    await cubit.selectGameweek(8);
    expect(cubit.state.gameweek, 8);
    expect((cubit.state as MatchesLoaded).fixtures.single.id, 80);
  });

  test('a stale gameweek response cannot replace the selected week', () async {
    final deferred = _DeferredMatchesRepository();
    final deferredCubit = MatchesCubit(deferred, bootstrap);
    addTearDown(deferredCubit.close);

    final firstLoad = deferredCubit.loadInitial();
    await Future<void>.delayed(Duration.zero);
    final secondLoad = deferredCubit.selectGameweek(8);
    deferred.pending[8]!.complete(Right([_fixture(80)]));
    await secondLoad;
    deferred.pending[7]!.complete(Right([_fixture(70)]));
    await firstLoad;

    expect(deferredCubit.state.gameweek, 8);
    expect((deferredCubit.state as MatchesLoaded).fixtures.single.id, 80);
  });
}

BootstrapModel _bootstrapData() {
  final team = TeamModel(id: 1, name: 'Arsenal', shortName: 'ARS', code: '3');
  return BootstrapModel(
    players: const [],
    playersMap: const {},
    teams: [team],
    teamsMap: {team.id: team},
    gameweeks: const [
      GameweekModel(id: 7, isCurrent: true, isNext: false),
      GameweekModel(id: 8, isCurrent: false, isNext: true),
    ],
  );
}

FixtureModel _fixture(int id) => FixtureModel(
  id: id,
  gameweek: id == 70 ? 7 : 8,
  kickoffTime: DateTime.utc(2026, 10, 20),
  homeTeamId: 1,
  awayTeamId: 2,
  homeScore: null,
  awayScore: null,
  started: false,
  finished: false,
  finishedProvisional: false,
  minutes: 0,
);

class _FakeBootstrapRepository implements BootstrapRepository {
  _FakeBootstrapRepository(this.model);

  final BootstrapModel model;

  @override
  Future<Either<Failure, BootstrapModel>> getBootstrap({
    bool refresh = false,
  }) async => Right(model);
}

class _FakeMatchesRepository implements MatchesRepository {
  final Map<int, Either<Failure, List<FixtureModel>>> responses = {};
  final List<int> requestedGameweeks = [];

  @override
  Future<Either<Failure, List<FixtureModel>>> getFixtures(int gameweek) async {
    requestedGameweeks.add(gameweek);
    return responses[gameweek] ?? Right([_fixture(gameweek * 10)]);
  }

  @override
  Future<Either<Failure, FixtureModel?>> getFixtureById(int fixtureId) async =>
      Right(_fixture(fixtureId));
}

class _DeferredMatchesRepository implements MatchesRepository {
  final Map<int, Completer<Either<Failure, List<FixtureModel>>>> pending = {};

  @override
  Future<Either<Failure, List<FixtureModel>>> getFixtures(int gameweek) {
    final completer = Completer<Either<Failure, List<FixtureModel>>>();
    pending[gameweek] = completer;
    return completer.future;
  }

  @override
  Future<Either<Failure, FixtureModel?>> getFixtureById(int fixtureId) async =>
      Right(_fixture(fixtureId));
}
