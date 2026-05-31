import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../../shared/providers/app_providers.dart';

final walletControllerProvider =
    StateNotifierProvider<WalletController, WalletState>((ref) {
  final repo = ref.watch(walletRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  final userId = authState is AuthAuthenticated ? authState.user.id : null;
  return WalletController(repo, userId);
});

final walletStreamProvider = StreamProvider<WalletState>((ref) {
  final repo = ref.watch(walletRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  if (authState is! AuthAuthenticated) return const Stream.empty();

  return repo.watchWallet(authState.user.id).map((either) {
    return either.fold(
      (failure) => WalletError(failure.message),
      (wallet)  => WalletLoaded(wallet),
    );
  });
});

class WalletController extends StateNotifier<WalletState> {
  final WalletRepository _repository;
  final String? _userId;

  WalletController(this._repository, this._userId)
      : super(const WalletInitial()) {
    if (_userId != null) fetchWallet();
  }

  Future<void> fetchWallet() async {
    if (_userId == null) return;
    state = const WalletLoading();
    final result = await _repository.getWallet(_userId!);
    result.fold(
      (failure) => state = WalletError(failure.message),
      (wallet)  => state = WalletLoaded(wallet),
    );
  }

  void applyOptimisticDebit(double amount) {
    if (state is WalletLoaded) {
      final current = (state as WalletLoaded).wallet;
      state = WalletLoaded(
        WalletOptimistic(current, optimisticBalance: current.balance - amount),
        isStale: true,
      );
    }
  }

  void rollbackOptimistic() => fetchWallet();
}

class WalletOptimistic extends Wallet {
  const WalletOptimistic(Wallet base, {required double optimisticBalance})
      : super(
          id:           base.id,
          userId:       base.userId,
          balance:      optimisticBalance,
          heldBalance:  base.heldBalance,
          dailySent:    base.dailySent,
          dailyLimit:   base.dailyLimit,
          currency:     base.currency,
          isFrozen:     base.isFrozen,
          updatedAt:    base.updatedAt,
        );
}
