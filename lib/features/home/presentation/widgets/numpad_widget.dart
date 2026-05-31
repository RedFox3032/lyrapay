import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

typedef NumpadCallback = void Function(String value);

class NumpadWidget extends StatelessWidget {
  final NumpadCallback onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onDecimal;
  final bool showDecimal;

  const NumpadWidget({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.onDecimal,
    this.showDecimal = true,
  });

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: row.map((key) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _NumpadKey(
                label: key,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (key == '⌫') {
                    onDelete();
                  } else if (key == '.') {
                    if (onDecimal != null) onDecimal!();
                    else onDigit('.');
                  } else {
                    onDigit(key);
                  }
                },
              ),
            ),
          )).toList(),
        ),
      )).toList(),
    );
  }
}

class _NumpadKey extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NumpadKey({required this.label, required this.onTap});

  @override
  State<_NumpadKey> createState() => _NumpadKeyState();
}

class _NumpadKeyState extends State<_NumpadKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 72,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.numpadKeyPressed : AppColors.numpadKey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: widget.label == '⌫'
              ? const Icon(
                  Icons.backspace_outlined,
                  color: AppColors.white,
                  size: 22,
                )
              : Text(
                  widget.label,
                  style: AppTypography.numpadDigit,
                ),
        ),
      ),
    );
  }
}
