import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/transaction.dart';
import '../repositories/activity_repository.dart';

class GetTransactionsUseCase {
  final ActivityRepository _repo;
  GetTransactionsUseCase(this._repo);

  Future<Either<Failure, List<Transaction>>> call({
    required String userId,
    int limit = 50,
    int offset = 0,
    String? typeFilter,
  }) => _repo.getTransactions(userId: userId, limit: limit, offset: offset, typeFilter: typeFilter);
}
