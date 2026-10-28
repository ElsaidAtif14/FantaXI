import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';

abstract class MatchesRepository {
  Future<Either<Failure, List<FixtureModel>>> getFixtures(int gameweek);
}
