import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../router/app_routes.dart';
import '../../../../shared/widgets/lyra_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('Welcome to\nLyraPay', style: AppTypography.h1),
              const SizedBox(height: 16),
              Text('Send money instantly to anyone in Libya.', style: AppTypography.bodyMedium),
              const Spacer(),
              LyraButton(
                label: 'Get Started',
                onPressed: () => context.go(AppRoutes.register),
              ),
              const SizedBox(height: 16),
              LyraButton(
                label: 'Sign In',
                variant: LyraButtonVariant.secondary,
                onPressed: () => context.go(AppRoutes.login),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
