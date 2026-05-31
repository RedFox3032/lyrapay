import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class RecipientSearchScreen extends StatelessWidget {
  const RecipientSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: Text('Find Recipient', style: AppTypography.h3)),
      body: const Center(child: Text('Search', style: AppTypography.bodyMedium)),
    );
  }
}
