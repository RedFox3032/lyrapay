import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/lyra_button.dart';
import '../../domain/entities/transfer.dart';
import '../controllers/send_state.dart';

class TransferSuccessSheet extends StatelessWidget {
  final Transfer transfer;
  final SearchResult recipient;
  final VoidCallback onDone;

  const TransferSuccessSheet({
    super.key,
    required this.transfer,
    required this.recipient,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.bottomSheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.neonGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                color: AppColors.black, size: 44),
            )
            .animate()
            .scale(begin: const Offset(0, 0), curve: Curves.easeOutBack,
                   duration: 400.ms),

            const SizedBox(height: 20),

            Text('Sent!', style: AppTypography.h1)
              .animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 8),

            Text(
              '\${Formatters.lyd(transfer.amount)} sent to \${recipient.formattedTag}',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 8),

            Text(
              'New balance: \${Formatters.lyd(transfer.newBalance)}',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.neonGreen,
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 36),

            LyraButton(
              label: 'Done',
              onPressed: onDone,
            ).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
