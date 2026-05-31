import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<Either<Failure, Wallet>> getWallet(String userId);
  Stream<Either<Failure, Wallet>> watchWallet(String userId);
}
