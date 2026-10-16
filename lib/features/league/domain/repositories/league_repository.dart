import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/league/data/models/league_response_model.dart';

abstract class LeagueRepository {
  Future<Either<Failure, LeagueResponseModel>> getLeagueStandings(
    int leagueId, {
    int page = 1,
  });
}
