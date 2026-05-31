import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../router/app_routes.dart';
import '../../../../shared/widgets/lyra_button.dart';

class AddMoneyScreen extends StatelessWidget {
  const AddMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: Text('Add Money', style: AppTypography.h3)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Choose a method to add money to your wallet.', style: AppTypography.bodyMedium),
            const SizedBox(height: 24),
            LyraButton(
              label: 'Redeem Voucher',
              onPressed: () => context.push(AppRoutes.voucherInput),
            ),
          ],
        ),
      ),
    );
  }
}
