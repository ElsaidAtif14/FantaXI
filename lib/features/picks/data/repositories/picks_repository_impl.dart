import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:fantasy/features/picks/domain/repositories/picks_repository.dart';

class PicksRepositoryImpl implements PicksRepository {
  final DioClient _dioClient;
  PicksRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, GameWeekPicksModel>> getPicks(
    int entryId,
    int gw,
  ) async {
    try {
      final data = await _dioClient.get(AppConstants.entryPicks(entryId, gw));
      return Right(GameWeekPicksModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}
