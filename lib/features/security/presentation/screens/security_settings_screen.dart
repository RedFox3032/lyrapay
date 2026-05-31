import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../router/app_routes.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: Text('Security', style: AppTypography.h3)),
      body: ListView(
        children: [
          ListTile(
            title: Text('Set Transaction PIN', style: AppTypography.bodyLarge),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.white),
            onTap: () => context.push(AppRoutes.setPin),
          ),
          const Divider(color: AppColors.border),
          ListTile(
            title: Text('Biometric Login', style: AppTypography.bodyLarge),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.white),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
