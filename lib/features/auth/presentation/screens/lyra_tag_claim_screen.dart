import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/lyra_tag_generator.dart';
import '../../../../router/app_routes.dart';
import '../../../../shared/widgets/lyra_button.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

class LyraTagClaimScreen extends ConsumerStatefulWidget {
  const LyraTagClaimScreen({super.key});

  @override
  ConsumerState<LyraTagClaimScreen> createState() => _LyraTagClaimScreenState();
}

class _LyraTagClaimScreenState extends ConsumerState<LyraTagClaimScreen> {
  final _tagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isChecking = false;
  bool? _isAvailable;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _initSuggestions();
    _tagController.addListener(_onTagChanged);
  }

  void _initSuggestions() {
    final state = ref.read(authControllerProvider);
    if (state is AuthNeedsLyraTag) {
      _suggestions = LyraTagGenerator.suggest(state.firstName, state.lastName);
      if (_suggestions.isNotEmpty) {
        _tagController.text = _suggestions.first;
      }
    }
  }

  void _onTagChanged() {
    setState(() => _isAvailable = null);
    _debounceCheck();
  }

  DateTime? _lastCheck;
  void _debounceCheck() {
    _lastCheck = DateTime.now();
    final check = _lastCheck!;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_lastCheck == check && _tagController.text.length >= 4) {
        _checkAvailability();
      }
    });
  }

  Future<void> _checkAvailability() async {
    final tag = _tagController.text.trim().toLowerCase();
    if (Validators.lyraTag(tag) != null) return;

    setState(() => _isChecking = true);
    final available = await ref
        .read(authControllerProvider.notifier)
        .checkLyraTagAvailable(tag);
    setState(() {
      _isAvailable = available;
      _isChecking = false;
    });
  }

  Future<void> _claim() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isAvailable != true) {
      await _checkAvailability();
      if (_isAvailable != true) return;
    }

    final state = ref.read(authControllerProvider);
    if (state is! AuthNeedsLyraTag) return;

    await ref.read(authControllerProvider.notifier).claimLyraTag(
      userId:    state.userId,
      tag:       _tagController.text.trim().toLowerCase(),
      firstName: state.firstName,
      lastName:  state.lastName,
      email:     state.email,
    );
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    ref.listen(authControllerProvider, (_, next) {
      if (next is AuthAuthenticated) {
        context.go(AppRoutes.home);
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Text('Claim your\n\$LyraTag', style: AppTypography.h1)
                  .animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'Your unique ID. Others can find and pay you using it.',
                  style: AppTypography.bodyMedium,
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 48),

                Stack(
                  children: [
                    TextFormField(
                      controller: _tagController,
                      style: AppTypography.h3.copyWith(color: AppColors.neonGreen),
                      validator: Validators.lyraTag,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        prefixText: '\$',
                        prefixStyle: AppTypography.h3.copyWith(color: AppColors.textSecondary),
                        hintText: 'yourname',
                        hintStyle: AppTypography.h3.copyWith(color: AppColors.textTertiary),
                        suffixIcon: _buildAvailabilityIcon(),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 12),
                if (_tagController.text.length >= 4)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isChecking
                        ? Row(
                            children: [
                              SizedBox(
                                width: 14, height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Checking...', style: AppTypography.label),
                            ],
                          )
                        : _isAvailable == null
                            ? const SizedBox.shrink()
                            : Row(
                                children: [
                                  Icon(
                                    _isAvailable!
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: _isAvailable!
                                        ? AppColors.neonGreen
                                        : AppColors.error,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isAvailable!
                                        ? '\$\${_tagController.text} is available!'
                                        : 'This tag is already taken',
                                    style: AppTypography.label.copyWith(
                                      color: _isAvailable!
                                          ? AppColors.neonGreen
                                          : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                  ),

                const SizedBox(height: 24),

                if (_suggestions.isNotEmpty) ...[
                  Text('Suggestions', style: AppTypography.label),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestions.map((tag) => GestureDetector(
                      onTap: () => _tagController.text = tag,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text('\$\$tag', style: AppTypography.lyraTag.copyWith(
                          fontSize: 14,
                        )),
                      ),
                    )).toList(),
                  ).animate().fadeIn(delay: 300.ms),
                ],

                const Spacer(),

                LyraButton(
                  label: 'Claim \$LyraTag',
                  onPressed: _isAvailable == true ? _claim : null,
                  isLoading: isLoading,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildAvailabilityIcon() {
    if (_isChecking) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_isAvailable == true) {
      return const Icon(Icons.check_circle_rounded, color: AppColors.neonGreen);
    }
    if (_isAvailable == false) {
      return const Icon(Icons.cancel_rounded, color: AppColors.error);
    }
    return null;
  }
}
