import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class AvatarWidget extends StatelessWidget {
  final String initials;
  final double size;
  const AvatarWidget({super.key, required this.initials, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.25)),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: AppTypography.label.copyWith(
            color: AppColors.neonGreen,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.3,
          ),
        ),
      ),
    );
  }
}
