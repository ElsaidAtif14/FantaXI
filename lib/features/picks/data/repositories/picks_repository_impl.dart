import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:fantasy/features/picks/domain/repositories/picks_repository.dart';
import 'package:fantasy/core/network/successful_request_cache.dart';
import 'package:fantasy/core/network/data_cache_policy.dart';

class PicksRepositoryImpl implements PicksRepository {
  final DioClient _dioClient;
  PicksRepositoryImpl(
    this._dioClient, {
    Duration ttl = DataCachePolicy.picksTtl,
  }) : _cache = SuccessfulRequestCache<(int, int), GameWeekPicksModel>(
         ttl: ttl,
       );
  final SuccessfulRequestCache<(int, int), GameWeekPicksModel> _cache;

  @override
  Future<Either<Failure, GameWeekPicksModel>> getPicks(
    int entryId,
    int gw, {
    bool refresh = false,
  }) async {
    try {
      if (entryId <= 0 || gw <= 0) {
        return Left(Failure(errMessage: 'Invalid manager ID or gameweek.'));
      }
      final key = (entryId, gw);
      final picks = await _cache.get(key, () async {
        final data = await _dioClient.get(AppConstants.entryPicks(entryId, gw));
        return GameWeekPicksModel.fromJson(data);
      }, refresh: refresh);
      return Right(picks);
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}
