import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';

abstract class PicksRepository {
  Future<Either<Failure, GameWeekPicksModel>> getPicks(
    int entryId,
    int gw, {
    bool refresh = false,
  });
}
