import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

enum LyraButtonVariant { primary, secondary, ghost, danger }

class LyraButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final LyraButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? leading;

  const LyraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = LyraButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case LyraButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(AppColors.black),
        );
      case LyraButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(AppColors.white),
        );
      case LyraButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(AppColors.neonGreen),
        );
      case LyraButtonVariant.danger:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
          ),
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(AppColors.white),
        );
    }
  }

  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: textColor,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Text(label, style: AppTypography.buttonText.copyWith(color: textColor)),
      ],
    );
  }
}
