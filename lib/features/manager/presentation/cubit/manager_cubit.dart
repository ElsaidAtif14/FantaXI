import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:fantasy/features/manager/domain/repositories/manager_repository.dart';

part 'manager_state.dart';

class ManagerCubit extends Cubit<ManagerState> {
  final ManagerRepository _repository;
  ManagerCubit(this._repository) : super(ManagerInitial());

  Future<void> loadManager(int entryId) async {
    emit(ManagerLoading());
    final result = await _repository.getManager(entryId);
    result.fold(
      (failure) => emit(ManagerError(failure.errMessage)),
      (manager) => emit(ManagerLoaded(manager)),
    );
  }
}
