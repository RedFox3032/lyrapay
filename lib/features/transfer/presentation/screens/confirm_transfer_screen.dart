import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class ConfirmTransferScreen extends StatelessWidget {
  const ConfirmTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: Text('Confirm', style: AppTypography.h3)),
      body: const Center(child: Text('Confirm Transfer', style: AppTypography.bodyMedium)),
    );
  }
}
