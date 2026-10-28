import 'package:dartz/dartz.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:fantasy/features/manager/domain/repositories/manager_repository.dart';
import 'package:fantasy/core/network/successful_request_cache.dart';
import 'package:fantasy/core/network/data_cache_policy.dart';

class ManagerRepositoryImpl implements ManagerRepository {
  final DioClient _dioClient;
  ManagerRepositoryImpl(
    this._dioClient, {
    Duration ttl = DataCachePolicy.managerTtl,
  }) : _cache = SuccessfulRequestCache<int, FantasyManagerModel>(ttl: ttl);
  final SuccessfulRequestCache<int, FantasyManagerModel> _cache;

  @override
  Future<Either<Failure, FantasyManagerModel>> getManager(
    int entryId, {
    bool refresh = false,
  }) async {
    try {
      if (entryId <= 0) return Left(Failure(errMessage: 'Invalid manager ID.'));
      final manager = await _cache.get(entryId, () async {
        final data = await _dioClient.get(AppConstants.entry(entryId));
        return FantasyManagerModel.fromJson(data);
      }, refresh: refresh);
      return Right(manager);
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}
