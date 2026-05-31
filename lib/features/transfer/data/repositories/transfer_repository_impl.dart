import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/transfer.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_remote_datasource.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferRemoteDataSource _remote;
  TransferRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, Transfer>> processTransfer({
    required String toLyraTag,
    required double amount,
    required String pin,
    String? note,
  }) async {
    try {
      final result = await _remote.processTransfer(
        toLyraTag: toLyraTag,
        amount: amount,
        pin: pin,
        note: note,
      );
      return Right(Transfer(
        transactionId: result['transaction_id'] as String,
        amount: amount,
        newBalance: (result['new_balance'] as num).toDouble(),
        toLyraTag: toLyraTag,
        note: note,
        isIdempotent: result['idempotent'] as bool? ?? false,
      ));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> searchUsers(String query) async {
    try {
      final results = await _remote.searchUsers(query);
      return Right(results);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
