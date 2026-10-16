import 'package:dartz/dartz.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:fantasy/features/manager/domain/repositories/manager_repository.dart';

class ManagerRepositoryImpl implements ManagerRepository {
  final DioClient _dioClient;
  ManagerRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, FantasyManagerModel>> getManager(int entryId) async {
    try {
      final data = await _dioClient.get(AppConstants.entry(entryId));
      return Right(FantasyManagerModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}
