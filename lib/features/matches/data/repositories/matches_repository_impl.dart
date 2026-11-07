import 'package:dartz/dartz.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/core/network/successful_request_cache.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/domain/repositories/matches_repository.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  MatchesRepositoryImpl(this._dioClient)
    : _fixturesCache = SuccessfulRequestCache<String, List<FixtureModel>>(
        ttl: const Duration(minutes: 2),
      );

  final DioClient _dioClient;
  final SuccessfulRequestCache<String, List<FixtureModel>> _fixturesCache;

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

  @override
  Future<Either<Failure, FixtureModel?>> getFixtureById(int fixtureId) async {
    try {
      final fixtures = await _fixturesCache.get('all', () async {
        final data = await _dioClient.getList(AppConstants.fixtures);
        return data.map(FixtureModel.fromJson).toList();
      });
      for (final fixture in fixtures) {
        if (fixture.id == fixtureId) return Right(fixture);
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}
