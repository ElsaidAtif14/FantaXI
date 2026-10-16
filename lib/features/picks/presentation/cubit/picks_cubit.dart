import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:fantasy/features/picks/domain/repositories/picks_repository.dart';

part 'picks_state.dart';

class PicksCubit extends Cubit<PicksState> {
  final PicksRepository _repository;
  PicksCubit(this._repository) : super(PicksInitial());

  Future<void> loadPicks(int entryId, int gw) async {
    emit(PicksLoading());

    final picks = await _repository.getPicks(entryId, gw);
    picks.fold(
      (failure) => emit(PicksError(failure.errMessage)),
      (picks) => emit(PicksLoaded(picks)),
    );
    // emit(PicksLoaded(picks));
    // emit(PicksError(e.toString()));
  }
}
