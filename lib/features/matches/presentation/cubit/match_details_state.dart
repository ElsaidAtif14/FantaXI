import 'package:equatable/equatable.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';

sealed class MatchDetailsState extends Equatable {
  const MatchDetailsState();
  @override
  List<Object?> get props => [];
}

class MatchDetailsInitial extends MatchDetailsState {
  const MatchDetailsInitial();
}

class MatchDetailsLoading extends MatchDetailsState {
  const MatchDetailsLoading();
}

class MatchDetailsLoaded extends MatchDetailsState {
  const MatchDetailsLoaded(this.details);
  final PremierLeagueMatchDetails details;
  @override
  List<Object?> get props => [
    details.matchId,
    details.status,
    details.events.length,
    details.commentary.length,
    details.failedSections,
  ];
}

class MatchDetailsError extends MatchDetailsState {
  const MatchDetailsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
