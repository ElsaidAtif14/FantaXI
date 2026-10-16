import 'package:dartz/dartz.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/history/data/models/manager_history_model.dart';
import 'package:fantasy/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final DioClient _dioClient;
  HistoryRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, ManagerHistoryModel>> getHistory(int entryId) async {
    try {
      final data = await _dioClient.get(AppConstants.entryHistory(entryId));
      return Right(ManagerHistoryModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}
