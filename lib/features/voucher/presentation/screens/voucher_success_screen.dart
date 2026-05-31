import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../router/app_routes.dart';
import '../../../../shared/widgets/lyra_button.dart';

class VoucherSuccessScreen extends StatelessWidget {
  const VoucherSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.neonGreen, size: 80),
              const SizedBox(height: 24),
              Text('Voucher Redeemed!', style: AppTypography.h1),
              const SizedBox(height: 16),
              Text('100 LYD has been added to your wallet.', style: AppTypography.bodyMedium, textAlign: TextAlign.center),
              const Spacer(),
              LyraButton(
                label: 'Done',
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
