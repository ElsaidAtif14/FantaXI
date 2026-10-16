import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantasy/features/league/data/models/league_response_model.dart';
import 'package:fantasy/features/league/domain/repositories/league_repository.dart';

part 'league_state.dart';

class LeagueCubit extends Cubit<LeagueState> {
  final LeagueRepository _repository;
  int? _leagueId;

  LeagueCubit(this._repository) : super(LeagueInitial());

  Future<void> loadLeague(int leagueId) async {
    _leagueId = leagueId;
    emit(LeagueLoading());
    final result = await _repository.getLeagueStandings(leagueId);
    result.fold(
      (failure) => emit(LeagueError(failure.errMessage)),
      (league) => emit(LeagueLoaded(league, nextPage: 2)),
    );
  }

  Future<void> loadNextPage() async {
    final current = state;
    final leagueId = _leagueId;
    if (current is! LeagueLoaded ||
        !current.response.hasNextPage ||
        current.isLoadingMore ||
        leagueId == null) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true, paginationError: null));
    final result = await _repository.getLeagueStandings(
      leagueId,
      page: current.nextPage,
    );
    result.fold(
      (failure) {
        final latestState = state;
        if (isClosed ||
            latestState is! LeagueLoaded ||
            latestState.response != current.response ||
            latestState.nextPage != current.nextPage) {
          return;
        }
        emit(current.copyWith(
          isLoadingMore: false,
          paginationError: failure.errMessage,
        ));
      },
      (next) {
        final latestState = state;
        if (isClosed ||
            latestState is! LeagueLoaded ||
            latestState.response != current.response ||
            latestState.nextPage != current.nextPage) {
          return;
        }
        final merged = LeagueResponseModel(
          league: current.response.league,
          standings: [...current.response.standings, ...next.standings],
          lastUpdated: next.lastUpdated,
          hasNextPage: next.standings.isNotEmpty && next.hasNextPage,
        );
        emit(current.copyWith(
          response: merged,
          nextPage: current.nextPage + 1,
          isLoadingMore: false,
        ));
      },
    );
  }
}
