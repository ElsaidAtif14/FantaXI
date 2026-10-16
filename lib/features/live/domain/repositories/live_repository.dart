import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';

abstract class LiveRepository {
  Future<Either<Failure, LiveGWModel>> getLiveData(int gw);
}
