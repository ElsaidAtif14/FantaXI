import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/domain/repositories/match_details_repository.dart';
import 'match_details_state.dart';

class MatchDetailsCubit extends Cubit<MatchDetailsState> {
  MatchDetailsCubit(
    this._repository, {
    this.loadTimeout = const Duration(seconds: 25),
  }) : super(const MatchDetailsInitial());
  final MatchDetailsRepository _repository;
  // One 10s match request plus one parallel 10s section batch, with 5s margin.
  final Duration loadTimeout;
  int _generation = 0;

  Future<void> load(
    FixtureModel fixture, {
    String? homeTeamName,
    String? awayTeamName,
  }) async {
    final generation = ++_generation;
    developer.log(
      'load started fpl_fixture_id=${fixture.id} candidate_pl_id=${fixture.code}',
      name: 'match_details.cubit',
    );
    emit(const MatchDetailsLoading());
    try {
      final result = await _repository
          .getDetails(
            fixture: fixture,
            homeTeamName: homeTeamName,
            awayTeamName: awayTeamName,
          )
          .timeout(loadTimeout);
      if (isClosed || generation != _generation) return;
      result.fold(
        (failure) {
          developer.log(
            'emitting error: ${failure.errMessage}',
            name: 'match_details.cubit',
          );
          emit(MatchDetailsError(failure.errMessage));
        },
        (details) {
          developer.log(
            'emitting loaded match=${details.matchId} partial_failures=${details.failedSections.length}',
            name: 'match_details.cubit',
          );
          emit(MatchDetailsLoaded(details));
        },
      );
    } on TimeoutException catch (error, stackTrace) {
      developer.log(
        'details load timed out: $error',
        name: 'match_details.cubit',
        error: error,
        stackTrace: stackTrace,
      );
      if (!isClosed && generation == _generation) {
        emit(
          const MatchDetailsError(
            'Match details request timed out. Please retry.',
          ),
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'details load threw: $error',
        name: 'match_details.cubit',
        error: error,
        stackTrace: stackTrace,
      );
      if (!isClosed && generation == _generation) {
        emit(
          const MatchDetailsError(
            'Match details are unavailable. Please retry.',
          ),
        );
      }
    }
  }
}
