import 'package:dartz/dartz.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/domain/repositories/matches_repository.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  MatchesRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<Either<Failure, List<FixtureModel>>> getFixtures(int gameweek) async {
    try {
      final data = await _dioClient.getList(
        AppConstants.fixtures,
        queryParams: {'event': gameweek},
      );
      return Right(data.map(FixtureModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}
