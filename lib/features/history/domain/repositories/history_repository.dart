import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/history/data/models/manager_history_model.dart';

abstract class HistoryRepository {
  Future<Either<Failure, ManagerHistoryModel>> getHistory(int entryId);
}
