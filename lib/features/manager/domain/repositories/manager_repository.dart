import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';

abstract class ManagerRepository {
  Future<Either<Failure, FantasyManagerModel>> getManager(int entryId);
}
