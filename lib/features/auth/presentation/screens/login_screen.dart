import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../router/app_routes.dart';
import '../../../../shared/widgets/lyra_button.dart';
import '../../../../shared/widgets/lyra_text_field.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _email    = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signIn(
      email:    _email.text.trim(),
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    ref.listen(authControllerProvider, (_, next) {
      if (next is AuthAuthenticated) {
        context.go(AppRoutes.home);
      } else if (next is AuthNeedsLyraTag) {
        context.go(AppRoutes.lyraTagClaim);
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        height: 1.0,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  curve: Curves.easeOutBack,
                ),

                const SizedBox(height: 32),
                Text('Welcome back', style: AppTypography.h1)
                  .animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your LyraPay account',
                  style: AppTypography.bodyMedium,
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                const SizedBox(height: 48),

                LyraTextField(
                  label: 'Email Address',
                  hint: 'ahmed@example.com',
                  controller: _email,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 20),
                LyraTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _password,
                  validator: (v) => v?.isEmpty == true ? 'Password required' : null,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.forgotPassword),
                    child: Text(
                      'Forgot Password?',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 36),
                LyraButton(
                  label: 'Sign In',
                  onPressed: _submit,
                  isLoading: isLoading,
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: AppTypography.bodyMedium),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.register),
                      child: Text('Sign Up', style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
