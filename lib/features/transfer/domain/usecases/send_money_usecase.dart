import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/transfer.dart';
import '../repositories/transfer_repository.dart';

class SendMoneyUseCase {
  final TransferRepository _repo;
  SendMoneyUseCase(this._repo);

  Future<Either<Failure, Transfer>> call({
    required String toLyraTag,
    required double amount,
    required String pin,
    String? note,
  }) => _repo.processTransfer(toLyraTag: toLyraTag, amount: amount, pin: pin, note: note);
}
