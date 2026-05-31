import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';
import '../datasources/wallet_local_datasource.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remote;
  final WalletLocalDataSource _local;

  WalletRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, Wallet>> getWallet(String userId) async {
    try {
      final wallet = await _remote.getWallet(userId);
      await _local.cacheWallet(wallet);
      return Right(wallet);
    } on AppException catch (_) {
      final cached = await _local.getCachedWallet(userId);
      if (cached != null) return Right(cached);
      return Left(ServerFailure('Failed to load wallet'));
    } catch (e) {
      final cached = await _local.getCachedWallet(userId);
      if (cached != null) return Right(cached);
      return Left(NetworkFailure('No connection and no cached data'));
    }
  }

  @override
  Stream<Either<Failure, Wallet>> watchWallet(String userId) async* {
    try {
      await for (final wallet in _remote.watchWallet(userId)) {
        await _local.cacheWallet(wallet);
        yield Right(wallet);
      }
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }
}
