part of 'matches_cubit.dart';

abstract class MatchesState extends Equatable {
  const MatchesState({this.gameweek, this.teams = const {}, this.maxGameweek});

  final int? gameweek;
  final Map<int, TeamModel> teams;
  final int? maxGameweek;

  @override
  List<Object?> get props => [gameweek, teams, maxGameweek];
}

class MatchesInitial extends MatchesState {
  const MatchesInitial();
}

class MatchesLoading extends MatchesState {
  const MatchesLoading({super.gameweek, super.teams, super.maxGameweek});
}

class MatchesLoaded extends MatchesState {
  const MatchesLoaded({
    required this.fixtures,
    required super.gameweek,
    required super.teams,
    required super.maxGameweek,
  });

  final List<FixtureModel> fixtures;

  @override
  List<Object?> get props => [...super.props, fixtures];
}

class MatchesError extends MatchesState {
  const MatchesError(
    this.message, {
    super.gameweek,
    super.teams,
    super.maxGameweek,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
