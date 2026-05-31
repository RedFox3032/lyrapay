import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../router/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), _navigate);
  }

  void _navigate() {
    final authState = ref.read(authControllerProvider);
    if (!mounted) return;

    switch (authState) {
      case AuthAuthenticated():
        context.go(AppRoutes.home);
      case AuthNeedsLyraTag():
        context.go(AppRoutes.lyraTagClaim);
      default:
        context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.neonGreen,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text(
                  'L',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    height: 1.0,
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),

            const SizedBox(height: 20),

            Text(
              'LyraPay',
              style: AppTypography.h1.copyWith(letterSpacing: -1),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            Text(
              'Send money instantly',
              style: AppTypography.bodyMedium,
            )
            .animate()
            .fadeIn(delay: 600.ms, duration: 500.ms),

            const SizedBox(height: 60),

            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.neonGreen.withOpacity(0.5),
              ),
            )
            .animate()
            .fadeIn(delay: 1000.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
