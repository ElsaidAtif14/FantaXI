import 'package:dartz/dartz.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/league/data/models/league_response_model.dart';
import 'package:fantasy/features/league/domain/repositories/league_repository.dart';

class LeagueRepositoryImpl implements LeagueRepository {
  final DioClient _dioClient;
  LeagueRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, LeagueResponseModel>> getLeagueStandings(
    int leagueId, {
    int page = 1,
  }) async {
    try {
      final data = await _dioClient.get(
        AppConstants.leagueStandings(leagueId),
        queryParams: {'page_standings': page},
      );
      return Right(LeagueResponseModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}
