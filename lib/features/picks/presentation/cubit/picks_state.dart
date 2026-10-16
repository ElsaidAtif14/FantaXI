part of 'picks_cubit.dart';

abstract class PicksState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PicksInitial extends PicksState {}
class PicksLoading extends PicksState {}

class PicksLoaded extends PicksState {
  final GameWeekPicksModel picks;
  PicksLoaded(this.picks);
  @override
  List<Object?> get props => [picks];
}

class PicksError extends PicksState {
  final String message;
  PicksError(this.message);
  @override
  List<Object?> get props => [message];
}
