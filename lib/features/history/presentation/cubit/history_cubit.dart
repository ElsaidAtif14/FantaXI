import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantasy/features/history/data/models/manager_history_model.dart';
import 'package:fantasy/features/history/domain/repositories/history_repository.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _repository;
  HistoryCubit(this._repository) : super(HistoryInitial());
  int? _entryId;
  int _generation = 0;

  Future<void> loadHistory(int entryId) async {
    if (entryId <= 0) {
      emit(HistoryError('Invalid manager ID.'));
      return;
    }
    _entryId = entryId;
    final generation = ++_generation;
    emit(HistoryLoading());
    final result = await _repository.getHistory(entryId);
    if (isClosed || generation != _generation) return;
    result.fold(
      (failure) => emit(HistoryError(failure.errMessage)),
      (history) => emit(HistoryLoaded(history)),
    );
  }

  Future<void> retry() async {
    final entryId = _entryId;
    if (entryId != null) await loadHistory(entryId);
  }
}
