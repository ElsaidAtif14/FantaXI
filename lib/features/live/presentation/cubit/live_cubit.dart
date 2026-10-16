import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';
import 'package:fantasy/features/live/domain/repositories/live_repository.dart';

part 'live_state.dart';

class LiveCubit extends Cubit<LiveState> {
  final LiveRepository _repository;
  LiveCubit(this._repository) : super(LiveInitial());

  Future<void> loadLive(int gw) async {
    emit(LiveLoading());
    final result = await _repository.getLiveData(gw);
    result.fold(
      (failure) => emit(LiveError(failure.errMessage)),
      (data) => emit(LiveLoaded(data)),
    );
  }
}
