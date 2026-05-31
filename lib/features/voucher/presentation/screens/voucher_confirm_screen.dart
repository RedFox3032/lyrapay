import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../router/app_routes.dart';
import '../../../../shared/widgets/lyra_button.dart';

class VoucherConfirmScreen extends StatelessWidget {
  const VoucherConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: Text('Confirm', style: AppTypography.h3)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Redeem 100 LYD voucher?', style: AppTypography.h2),
            const Spacer(),
            LyraButton(
              label: 'Confirm Redemption',
              onPressed: () => context.push(AppRoutes.voucherSuccess),
            ),
          ],
        ),
      ),
    );
  }
}
