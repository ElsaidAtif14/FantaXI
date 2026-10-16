part of 'live_cubit.dart';

abstract class LiveState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LiveInitial extends LiveState {}
class LiveLoading extends LiveState {}

class LiveLoaded extends LiveState {
  final LiveGWModel data;
  LiveLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class LiveError extends LiveState {
  final String message;
  LiveError(this.message);
  @override
  List<Object?> get props => [message];
}
