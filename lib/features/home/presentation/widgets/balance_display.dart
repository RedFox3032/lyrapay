import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../wallet/presentation/controllers/wallet_state.dart';

class BalanceDisplay extends StatelessWidget {
  final WalletState walletState;

  const BalanceDisplay({super.key, required this.walletState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Balance', style: AppTypography.label.copyWith(
          letterSpacing: 1.5,
          color: AppColors.textSecondary,
        )),
        const SizedBox(height: 8),
        _buildBalanceValue(),
        const SizedBox(height: 4),
        _buildSubtitle(),
      ],
    );
  }

  Widget _buildBalanceValue() {
    if (walletState is WalletLoading || walletState is WalletInitial) {
      return Shimmer.fromColors(
        baseColor: AppColors.card,
        highlightColor: AppColors.cardElevated,
        child: Container(
          width: 200,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    if (walletState is WalletError) {
      return Text('- - -', style: AppTypography.balanceLarge.copyWith(
        color: AppColors.textSecondary,
      ));
    }

    if (walletState is WalletLoaded) {
      final wallet = (walletState as WalletLoaded).wallet;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          key: ValueKey(wallet.balance),
          Formatters.lyd(wallet.availableBalance),
          style: AppTypography.balanceLarge,
          textAlign: TextAlign.center,
        ),
      )
      .animate(key: ValueKey(wallet.balance))
      .fadeIn(duration: 200.ms);
    }

    return const SizedBox.shrink();
  }

  Widget _buildSubtitle() {
    if (walletState is WalletLoaded) {
      final isStale = (walletState as WalletLoaded).isStale;
      if (isStale) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sync_rounded, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text('Syncing...', style: AppTypography.label),
          ],
        );
      }
    }
    return Text('Available', style: AppTypography.label);
  }
}
