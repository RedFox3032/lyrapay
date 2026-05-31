import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/transfer.dart';

abstract class TransferRepository {
  Future<Either<Failure, Transfer>> processTransfer({
    required String toLyraTag,
    required double amount,
    required String pin,
    String? note,
  });
  Future<Either<Failure, List<Map<String, dynamic>>>> searchUsers(String query);
}
