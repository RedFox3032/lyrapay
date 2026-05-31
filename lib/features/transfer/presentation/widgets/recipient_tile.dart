import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class RecipientTile extends StatelessWidget {
  final String name;
  final String lyraTag;
  final VoidCallback onTap;
  const RecipientTile({super.key, required this.name, required this.lyraTag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: AppColors.neonGreen.withOpacity(0.15),
        child: Text(name[0], style: AppTypography.label.copyWith(color: AppColors.neonGreen))
      ),
      title: Text(name, style: AppTypography.bodyLarge),
      subtitle: Text(lyraTag, style: AppTypography.lyraTag.copyWith(fontSize: 13)),
      onTap: onTap,
    );
  }
}
