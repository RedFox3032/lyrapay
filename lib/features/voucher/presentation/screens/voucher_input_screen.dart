import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../router/app_routes.dart';
import '../../../../shared/widgets/lyra_button.dart';

class VoucherInputScreen extends StatelessWidget {
  const VoucherInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: Text('Redeem Voucher', style: AppTypography.h3)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter your 15-character voucher code.', style: AppTypography.bodyMedium),
            const SizedBox(height: 24),
            TextField(
              style: AppTypography.voucherCode,
              maxLength: 17,
              decoration: InputDecoration(
                hintText: 'XXXXX-XXXXX-XXXXX',
                hintStyle: AppTypography.voucherCode.copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const Spacer(),
            LyraButton(
              label: 'Continue',
              onPressed: () => context.push(AppRoutes.voucherConfirm),
            ),
          ],
        ),
      ),
    );
  }
}
