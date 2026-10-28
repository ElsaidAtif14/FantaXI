import 'package:dartz/dartz.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';

export 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';

abstract class BootstrapRepository {
  Future<Either<Failure, BootstrapModel>> getBootstrap({bool refresh = false});
}
