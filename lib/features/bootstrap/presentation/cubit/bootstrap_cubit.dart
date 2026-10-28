import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantasy/features/bootstrap/domain/repositories/bootstrap_repository.dart';

part 'bootstrap_state.dart';

class BootstrapCubit extends Cubit<BootstrapState> {
  final BootstrapRepository _repository;
  BootstrapCubit(this._repository) : super(BootstrapInitial());
  int _generation = 0;

  Future<void> loadBootstrap({bool refresh = false}) async {
    final generation = ++_generation;
    emit(BootstrapLoading());

    final data = await _repository.getBootstrap(refresh: refresh);
    if (isClosed || generation != _generation) return;
    data.fold(
      (failure) => emit(BootstrapError(failure.errMessage)),
      (bootstrap) => emit(BootstrapLoaded(bootstrap)),
    );
  }
}
