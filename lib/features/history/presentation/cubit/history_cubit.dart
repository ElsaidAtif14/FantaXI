import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantasy/features/history/data/models/manager_history_model.dart';
import 'package:fantasy/features/history/domain/repositories/history_repository.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _repository;
  HistoryCubit(this._repository) : super(HistoryInitial());

  Future<void> loadHistory(int entryId) async {
    emit(HistoryLoading());
    final result = await _repository.getHistory(entryId);
    result.fold(
      (failure) => emit(HistoryError(failure.errMessage)),
      (history) => emit(HistoryLoaded(history)),
    );
  }
}
