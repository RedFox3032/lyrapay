import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_remote_datasource.dart';
import '../datasources/activity_local_datasource.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource _remote;
  final ActivityLocalDataSource _local;

  ActivityRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
    int limit = 50,
    int offset = 0,
    String? typeFilter,
  }) async {
    try {
      final models = await _remote.getTransactions(
        userId: userId,
        limit: limit,
        offset: offset,
        typeFilter: typeFilter,
      );
      await _local.cacheTransactions(userId, models);
      return Right(models);
    } on AppException catch (e) {
      final cached = await _local.getCachedTransactions(userId);
      if (cached.isNotEmpty) return Right(cached);
      return Left(ServerFailure(e.message));
    } catch (e) {
      final cached = await _local.getCachedTransactions(userId);
      if (cached.isNotEmpty) return Right(cached);
      return Left(NetworkFailure(e.toString()));
    }
  }
}
