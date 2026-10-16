part of 'league_cubit.dart';

abstract class LeagueState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LeagueInitial extends LeagueState {}
class LeagueLoading extends LeagueState {}

class LeagueLoaded extends LeagueState {
  final LeagueResponseModel response;
  final int nextPage;
  final bool isLoadingMore;
  final String? paginationError;

  LeagueLoaded(
    this.response, {
    this.nextPage = 2,
    this.isLoadingMore = false,
    this.paginationError,
  });

  LeagueLoaded copyWith({
    LeagueResponseModel? response,
    int? nextPage,
    bool? isLoadingMore,
    String? paginationError,
  }) {
    return LeagueLoaded(
      response ?? this.response,
      nextPage: nextPage ?? this.nextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationError: paginationError,
    );
  }

  @override
  List<Object?> get props => [
    response,
    nextPage,
    isLoadingMore,
    paginationError,
  ];
}

class LeagueError extends LeagueState {
  final String message;
  LeagueError(this.message);
  @override
  List<Object?> get props => [message];
}
