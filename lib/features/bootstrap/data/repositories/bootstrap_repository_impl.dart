import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/features/bootstrap/domain/repositories/bootstrap_repository.dart';

class BootstrapRepositoryImpl implements BootstrapRepository {
  final DioClient _dioClient;
  BootstrapRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, BootstrapModel>> getBootstrap() async {
    try {
      final data = await _dioClient.get(AppConstants.bootstrapStatic);
      return Right(BootstrapModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}
