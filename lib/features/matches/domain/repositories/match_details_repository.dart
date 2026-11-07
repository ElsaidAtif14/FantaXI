import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';

abstract class MatchDetailsRepository {
  Future<Either<Failure, PremierLeagueMatchDetails>> getDetails({
    required FixtureModel fixture,
    required String? homeTeamName,
    required String? awayTeamName,
  });
}
