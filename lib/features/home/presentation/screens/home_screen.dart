import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';
import '../../../wallet/presentation/controllers/wallet_state.dart';
import '../widgets/balance_display.dart';
import '../widgets/numpad_widget.dart';
import '../widgets/action_buttons.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {

  String _amountInput = '0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletControllerProvider.notifier).fetchWallet();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onDigit(String digit) {
    setState(() {
      _amountInput = Formatters.appendNumpadDigit(_amountInput, digit);
    });
  }

  void _onDelete() {
    setState(() {
      _amountInput = Formatters.removeLastNumpadChar(_amountInput);
    });
  }

  void _onSend() {
    final amount = double.tryParse(_amountInput) ?? 0;
    if (amount <= 0) {
      HapticFeedback.heavyImpact();
      _shakeAmount();
      return;
    }
    context.push(AppRoutes.send, extra: {'amount': amount});
  }

  void _onRequest() {
    final amount = double.tryParse(_amountInput) ?? 0;
    context.push(AppRoutes.request, extra: {'amount': amount});
  }

  bool _isShaking = false;
  void _shakeAmount() {
    setState(() => _isShaking = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _isShaking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);
    final authState   = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    ref.listen(walletStreamProvider, (_, next) {
      next.whenData((state) {
        ref.read(walletControllerProvider.notifier).state = state;
      });
    });

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.profile),
                    child: _AvatarBadge(
                      initials: user?.initials ?? '??',
                    ),
                  ),
                  Text('LyraPay', style: AppTypography.h3.copyWith(
                    letterSpacing: -0.5,
                  )),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner_rounded,
                          color: AppColors.white, size: 24),
                        onPressed: () => context.push(AppRoutes.qrScan),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded,
                          color: AppColors.white, size: 24),
                        onPressed: () => context.push(AppRoutes.activity),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            BalanceDisplay(walletState: walletState)
              .animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _amountInput != '0'
                        ? AppColors.neonGreen.withOpacity(0.4)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LYD',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 100),
                      offset: _isShaking
                          ? const Offset(0.02, 0)
                          : Offset.zero,
                      child: Text(
                        _amountInput == '0' ? '0' : _amountInput,
                        style: AppTypography.balanceMedium.copyWith(
                          color: _amountInput != '0'
                              ? AppColors.white
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Text(
                      'LYD',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ActionButtons(
                onSend:     _onSend,
                onRequest:  _onRequest,
                onAddMoney: () => context.push(AppRoutes.addMoney),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NumpadWidget(
                  onDigit:  _onDigit,
                  onDelete: _onDelete,
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.activity),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_rounded,
                        color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 8),
                      Text('Activity', style: AppTypography.bodyMedium),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textTertiary, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String initials;
  const _AvatarBadge({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(initials, style: AppTypography.label.copyWith(
          color: AppColors.neonGreen,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        )),
      ),
    );
  }
}
