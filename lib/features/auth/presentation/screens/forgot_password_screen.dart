import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/lyra_button.dart';
import '../../../../shared/widgets/lyra_text_field.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email   = TextEditingController();
  bool _sent     = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).resetPassword(_email.text.trim());
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _sent ? _buildSentState() : _buildForm(isLoading),
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Reset Password', style: AppTypography.h1)
            .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            "Enter your email and we'll send you a reset link.",
            style: AppTypography.bodyMedium,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 48),
          LyraTextField(
            label: 'Email Address',
            hint: 'ahmed@example.com',
            controller: _email,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 28),
          LyraButton(
            label: 'Send Reset Link',
            onPressed: _submit,
            isLoading: isLoading,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildSentState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.neonGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: AppColors.neonGreen,
            size: 44,
          ),
        ).animate().scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack),
        const SizedBox(height: 24),
        Text('Check your email', style: AppTypography.h2, textAlign: TextAlign.center)
          .animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Text(
          'We sent a password reset link to\n\${_email.text}',
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 40),
        LyraButton(
          label: 'Back to Login',
          variant: LyraButtonVariant.secondary,
          onPressed: () => context.pop(),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}
