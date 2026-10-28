import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/network/successful_request_cache.dart';
import 'package:fantasy/core/network/data_cache_policy.dart';
import 'package:fantasy/features/bootstrap/domain/repositories/bootstrap_repository.dart';

class BootstrapRepositoryImpl implements BootstrapRepository {
  final DioClient _dioClient;
  BootstrapRepositoryImpl(
    this._dioClient, {
    Duration ttl = DataCachePolicy.bootstrapTtl,
  }) : _cache = SuccessfulRequestCache<String, BootstrapModel>(ttl: ttl);
  final SuccessfulRequestCache<String, BootstrapModel> _cache;

  @override
  Future<Either<Failure, BootstrapModel>> getBootstrap({
    bool refresh = false,
  }) async {
    try {
      final model = await _cache.get(AppConstants.bootstrapStatic, () async {
        final data = await _dioClient.get(AppConstants.bootstrapStatic);
        return BootstrapModel.fromJson(data);
      }, refresh: refresh);
      return Right(model);
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}
