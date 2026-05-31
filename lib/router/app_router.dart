import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_routes.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/controllers/auth_state.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/lyra_tag_claim_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/transfer/presentation/screens/send_flow_screen.dart';
import '../features/activity/presentation/screens/activity_screen.dart';
import '../features/activity/presentation/screens/transaction_detail_screen.dart';
import '../features/voucher/presentation/screens/add_money_screen.dart';
import '../features/voucher/presentation/screens/voucher_input_screen.dart';
import '../features/voucher/presentation/screens/voucher_confirm_screen.dart';
import '../features/voucher/presentation/screens/voucher_success_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/security/presentation/screens/security_settings_screen.dart';
import '../features/security/presentation/screens/set_pin_screen.dart';
import '../features/security/presentation/screens/enter_pin_screen.dart';
import '../features/qr/presentation/screens/qr_display_screen.dart';
import '../features/qr/presentation/screens/qr_scan_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState is AuthAuthenticated;
      final needsTag = authState is AuthNeedsLyraTag;
      final isAuthRoute = [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.onboarding,
        AppRoutes.forgotPassword,
      ].contains(state.matchedLocation);
      final isClaimTagRoute = state.matchedLocation == AppRoutes.lyraTagClaim;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      if (isSplash) return null;

      if (!isAuthenticated && !isAuthRoute && !isClaimTagRoute) {
        return AppRoutes.login;
      }
      if (needsTag && !isClaimTagRoute) {
        return AppRoutes.lyraTagClaim;
      }
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.lyraTagClaim, builder: (_, __) => const LyraTagClaimScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.send,
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SendFlowScreen(initialAmount: (extra?['amount'] as num?)?.toDouble() ?? 0);
        },
      ),
      GoRoute(path: AppRoutes.request, builder: (_, __) => const Scaffold(body: Center(child: Text('Request Money')))),
      GoRoute(path: AppRoutes.addMoney, builder: (_, __) => const AddMoneyScreen()),
      GoRoute(path: AppRoutes.voucherInput, builder: (_, __) => const VoucherInputScreen()),
      GoRoute(path: AppRoutes.voucherConfirm, builder: (_, __) => const VoucherConfirmScreen()),
      GoRoute(path: AppRoutes.voucherSuccess, builder: (_, __) => const VoucherSuccessScreen()),
      GoRoute(path: AppRoutes.activity, builder: (_, __) => const ActivityScreen()),
      GoRoute(path: AppRoutes.transactionDetail, builder: (_, __) => const TransactionDetailScreen()),
      GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
      GoRoute(path: AppRoutes.editProfile, builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: AppRoutes.securitySettings, builder: (_, __) => const SecuritySettingsScreen()),
      GoRoute(path: AppRoutes.setPin, builder: (_, __) => const SetPinScreen()),
      GoRoute(path: AppRoutes.enterPin, builder: (_, __) => const EnterPinScreen()),
      GoRoute(path: AppRoutes.qrDisplay, builder: (_, __) => const QrDisplayScreen()),
      GoRoute(path: AppRoutes.qrScan, builder: (_, __) => const QrScanScreen()),
    ],
  );
});
