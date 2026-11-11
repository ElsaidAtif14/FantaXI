import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/bootstrap/domain/repositories/bootstrap_repository.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/domain/repositories/matches_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'matches_state.dart';

class MatchesCubit extends Cubit<MatchesState> {
  MatchesCubit(
    this._matchesRepository,
    this._bootstrapRepository, {
    this.liveRefreshInterval = const Duration(seconds: 60),
  }) : super(const MatchesInitial());

  final MatchesRepository _matchesRepository;
  final BootstrapRepository _bootstrapRepository;
  final Duration liveRefreshInterval;
  int _requestVersion = 0;
  Map<int, TeamModel> _teams = const {};
  int? _maxGameweek;
  int? _selectedGameweek;
  int? _currentGameweek;
  Timer? _liveRefreshTimer;
  bool _refreshing = false;

  @override
  Future<void> close() {
    _liveRefreshTimer?.cancel();
    _liveRefreshTimer = null;
    return super.close();
  }

  Future<void> loadInitial() async {
    final version = ++_requestVersion;
    _liveRefreshTimer?.cancel();
    _liveRefreshTimer = null;
    _selectedGameweek = null;
    _teams = const {};
    _maxGameweek = null;
    _currentGameweek = null;
    emit(const MatchesLoading());

    final bootstrapResult = await _bootstrapRepository.getBootstrap();
    if (version != _requestVersion || isClosed) return;

    final bootstrap = bootstrapResult.fold<BootstrapModel?>((failure) {
      emit(MatchesError(failure.errMessage));
      return null;
    }, (data) => data);
    if (bootstrap == null) return;

    _teams = bootstrap.teamsMap;
    final gameweeks = bootstrap.gameweeks;
    _maxGameweek =
        gameweeks.isEmpty
            ? null
            : gameweeks
                .map((gameweek) => gameweek.id)
                .reduce((a, b) => a > b ? a : b);
    final currentGameweek =
        gameweeks.where((gameweek) => gameweek.isCurrent).firstOrNull?.id;
    _currentGameweek = currentGameweek;
    final selectedGameweek =
        currentGameweek ??
        gameweeks.where((gameweek) => gameweek.isNext).firstOrNull?.id ??
        (gameweeks.isEmpty ? null : gameweeks.first.id);

    if (selectedGameweek == null) {
      emit(const MatchesError('Matchweeks are not available.'));
      return;
    }
    await _loadGameweek(selectedGameweek, version);
  }

  Future<void> selectGameweek(int gameweek) async {
    if (_teams.isEmpty || gameweek < 1) return;
    if (_maxGameweek != null && gameweek > _maxGameweek!) return;

    final version = ++_requestVersion;
    await _loadGameweek(gameweek, version);
  }

  Future<void> retry() async {
    final gameweek = _selectedGameweek;
    if (gameweek == null || _teams.isEmpty) {
      await loadInitial();
      return;
    }
    final version = ++_requestVersion;
    await _loadGameweek(gameweek, version);
  }

  /// Re-fetches the selected matchweek without showing a loading state so live
  /// scores can update in place. Failures keep the current data visible.
  Future<void> refresh() async {
    final gameweek = _selectedGameweek;
    if (gameweek == null || _teams.isEmpty) {
      await loadInitial();
      return;
    }
    if (_refreshing) return;
    _refreshing = true;
    try {
      await _fetchGameweek(gameweek, ++_requestVersion, quiet: true);
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _loadGameweek(int gameweek, int version) async {
    _selectedGameweek = gameweek;
    emit(
      MatchesLoading(
        gameweek: gameweek,
        teams: _teams,
        maxGameweek: _maxGameweek,
      ),
    );
    await _fetchGameweek(gameweek, version, quiet: false);
  }

  Future<void> _fetchGameweek(
    int gameweek,
    int version, {
    required bool quiet,
  }) async {
    final result = await _matchesRepository.getFixtures(gameweek);
    if (version != _requestVersion || isClosed) return;

    result.fold(
      (failure) {
        if (quiet) {
          _restartLiveRefreshFromState();
          return;
        }
        emit(
          MatchesError(
            failure.errMessage,
            gameweek: gameweek,
            teams: _teams,
            maxGameweek: _maxGameweek,
          ),
        );
      },
      (fixtures) {
        emit(
          MatchesLoaded(
            fixtures: fixtures,
            gameweek: gameweek,
            teams: _teams,
            maxGameweek: _maxGameweek,
          ),
        );
        _syncLiveRefresh(fixtures, gameweek);
      },
    );
  }

  /// Polls only while the selected matchweek is the current one and at least
  /// one fixture is live; stops once every match has finished.
  void _syncLiveRefresh(List<FixtureModel> fixtures, int gameweek) {
    _liveRefreshTimer?.cancel();
    _liveRefreshTimer = null;
    final shouldPoll =
        gameweek == _currentGameweek &&
        fixtures.any((fixture) => fixture.isLive);
    if (!shouldPoll) return;
    _liveRefreshTimer = Timer.periodic(liveRefreshInterval, (_) => refresh());
  }

  void _restartLiveRefreshFromState() {
    final state = this.state;
    final gameweek = state.gameweek;
    if (state is MatchesLoaded && gameweek != null) {
      _syncLiveRefresh(state.fixtures, gameweek);
    }
  }
}
