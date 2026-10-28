import 'package:equatable/equatable.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/bootstrap/domain/repositories/bootstrap_repository.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/domain/repositories/matches_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'matches_state.dart';

class MatchesCubit extends Cubit<MatchesState> {
  MatchesCubit(this._matchesRepository, this._bootstrapRepository)
    : super(const MatchesInitial());

  final MatchesRepository _matchesRepository;
  final BootstrapRepository _bootstrapRepository;
  int _requestVersion = 0;
  Map<int, TeamModel> _teams = const {};
  int? _maxGameweek;
  int? _selectedGameweek;

  Future<void> loadInitial() async {
    final version = ++_requestVersion;
    _selectedGameweek = null;
    _teams = const {};
    _maxGameweek = null;
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
    final selectedGameweek =
        gameweeks.where((gameweek) => gameweek.isCurrent).firstOrNull?.id ??
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

  Future<void> _loadGameweek(int gameweek, int version) async {
    _selectedGameweek = gameweek;
    emit(
      MatchesLoading(
        gameweek: gameweek,
        teams: _teams,
        maxGameweek: _maxGameweek,
      ),
    );

    final result = await _matchesRepository.getFixtures(gameweek);
    if (version != _requestVersion || isClosed) return;

    result.fold(
      (failure) => emit(
        MatchesError(
          failure.errMessage,
          gameweek: gameweek,
          teams: _teams,
          maxGameweek: _maxGameweek,
        ),
      ),
      (fixtures) => emit(
        MatchesLoaded(
          fixtures: fixtures,
          gameweek: gameweek,
          teams: _teams,
          maxGameweek: _maxGameweek,
        ),
      ),
    );
  }
}
