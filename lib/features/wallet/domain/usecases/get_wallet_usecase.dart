import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

class GetWalletUseCase {
  final WalletRepository _repo;
  GetWalletUseCase(this._repo);

  Future<Either<Failure, Wallet>> call(String userId) => _repo.getWallet(userId);
}
