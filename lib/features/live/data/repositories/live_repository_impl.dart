import 'package:dartz/dartz.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';
import 'package:fantasy/features/live/domain/repositories/live_repository.dart';

class LiveRepositoryImpl implements LiveRepository {
  final DioClient _dioClient;
  LiveRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, LiveGWModel>> getLiveData(int gw) async {
    try {
      final data = await _dioClient.get(AppConstants.liveGW(gw));
      return Right(LiveGWModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}
