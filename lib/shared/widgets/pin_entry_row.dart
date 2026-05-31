import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PinEntryRow extends StatelessWidget {
  final int length;
  final int filled;
  const PinEntryRow({super.key, required this.length, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: i < filled ? AppColors.neonGreen : AppColors.card,
          border: Border.all(color: AppColors.border),
        ),
      )),
    );
  }
}
