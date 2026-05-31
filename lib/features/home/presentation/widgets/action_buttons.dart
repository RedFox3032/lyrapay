import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onRequest;
  final VoidCallback onAddMoney;

  const ActionButtons({
    super.key,
    required this.onSend,
    required this.onRequest,
    required this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ActionButton(
          label: 'Add',
          icon: Icons.add_rounded,
          onTap: onAddMoney,
          isPrimary: false,
        )),
        const SizedBox(width: 12),
        Expanded(child: _ActionButton(
          label: 'Send',
          icon: Icons.arrow_upward_rounded,
          onTap: onSend,
          isPrimary: true,
        )),
        const SizedBox(width: 12),
        Expanded(child: _ActionButton(
          label: 'Request',
          icon: Icons.arrow_downward_rounded,
          onTap: onRequest,
          isPrimary: false,
        )),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.neonGreen : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? AppColors.black : AppColors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.buttonText.copyWith(
                color: isPrimary ? AppColors.black : AppColors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
