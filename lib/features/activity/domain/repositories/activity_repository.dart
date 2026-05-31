import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/transaction.dart';

abstract class ActivityRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
    int limit = 50,
    int offset = 0,
    String? typeFilter,
  });
}
