import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet.dart';

abstract class WalletState extends Equatable {
  const WalletState();
}

class WalletInitial extends WalletState {
  const WalletInitial();
  @override List<Object?> get props => [];
}

class WalletLoading extends WalletState {
  const WalletLoading();
  @override List<Object?> get props => [];
}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final bool isStale;
  const WalletLoaded(this.wallet, {this.isStale = false});
  @override List<Object?> get props => [wallet, isStale];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
  @override List<Object?> get props => [message];
}
