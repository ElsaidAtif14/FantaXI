part of 'bootstrap_cubit.dart';

abstract class BootstrapState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BootstrapInitial extends BootstrapState {}
class BootstrapLoading extends BootstrapState {}

class BootstrapLoaded extends BootstrapState {
  final BootstrapModel data;
  BootstrapLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class BootstrapError extends BootstrapState {
  final String message;
  BootstrapError(this.message);
  @override
  List<Object?> get props => [message];
}
