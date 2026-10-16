part of 'manager_cubit.dart';

abstract class ManagerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ManagerInitial extends ManagerState {}

class ManagerLoading extends ManagerState {}

class ManagerLoaded extends ManagerState {
  final FantasyManagerModel manager;
  ManagerLoaded(this.manager);
  @override
  List<Object?> get props => [manager.id];
}

class ManagerError extends ManagerState {
  final String message;
  ManagerError(this.message);
  @override
  List<Object?> get props => [message];
}
