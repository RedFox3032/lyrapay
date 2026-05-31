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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName  = TextEditingController();
  final _email     = TextEditingController();
  final _password  = TextEditingController();
  final _confirm   = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).signUp(
      firstName: _firstName.text.trim(),
      lastName:  _lastName.text.trim(),
      email:     _email.text.trim(),
      password:  _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    ref.listen(authControllerProvider, (_, next) {
      if (next is AuthEmailUnverified) {
        _showVerificationDialog(next.email);
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text('Create your\naccount', style: AppTypography.h1)
                  .animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  'Join thousands of Libyans sending money instantly',
                  style: AppTypography.bodyMedium,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 36),

                Row(
                  children: [
                    Expanded(
                      child: LyraTextField(
                        label: 'First Name',
                        hint: 'Ahmed',
                        controller: _firstName,
                        validator: Validators.firstName,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LyraTextField(
                        label: 'Last Name',
                        hint: 'Saleh',
                        controller: _lastName,
                        validator: Validators.lastName,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                const SizedBox(height: 20),
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
                  hint: 'At least 8 characters',
                  controller: _password,
                  validator: Validators.password,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                const SizedBox(height: 20),
                LyraTextField(
                  label: 'Confirm Password',
                  hint: 'Repeat password',
                  controller: _confirm,
                  validator: (v) => Validators.confirmPassword(v, _password.text),
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 36),
                LyraButton(
                  label: 'Create Account',
                  onPressed: _submit,
                  isLoading: isLoading,
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: AppTypography.bodyMedium),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: Text('Sign In', style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Check your email', style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: AppColors.neonGreen,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We sent a confirmation link to\n\$email\n\nClick the link to verify your account, then come back to sign in.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          LyraButton(
            label: 'Go to Login',
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
