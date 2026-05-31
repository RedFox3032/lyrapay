import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.white),
            onPressed: () => context.push(AppRoutes.securitySettings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Profile Screen', style: AppTypography.bodyMedium),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              child: Text('Sign Out', style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}
