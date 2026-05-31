import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/lyra_button.dart';
import '../../../home/presentation/widgets/numpad_widget.dart';
import '../controllers/send_controller.dart';
import '../controllers/send_state.dart';
import '../../domain/entities/transfer.dart';
import '../widgets/transfer_success_sheet.dart';

class SendFlowScreen extends ConsumerStatefulWidget {
  final double initialAmount;
  const SendFlowScreen({super.key, required this.initialAmount});

  @override
  ConsumerState<SendFlowScreen> createState() => _SendFlowScreenState();
}

class _SendFlowScreenState extends ConsumerState<SendFlowScreen> {
  final _searchController = TextEditingController();
  final _noteController   = TextEditingController();
  String _pin = '';
  SearchResult? _selectedRecipient;
  int _step = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendControllerProvider);

    ref.listen(sendControllerProvider, (_, next) {
      if (next is SendSuccess) {
        _showSuccessSheet(next.transfer, next.recipient);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text(
          _step == 0 ? 'Send Money' : _step == 1 ? 'Confirm' : 'Enter PIN',
          style: AppTypography.h3,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _step == 0
              ? _buildSearchStep(sendState)
              : _step == 1
                  ? _buildConfirmStep(sendState)
                  : _buildPinStep(sendState),
        ),
      ),
    );
  }

  Widget _buildSearchStep(SendState sendState) {
    return Column(
      key: const ValueKey(0),
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text('Sending ', style: AppTypography.bodyMedium),
                    Text(
                      Formatters.lyd(widget.initialAmount),
                      style: AppTypography.h3.copyWith(color: AppColors.neonGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search by \$LyraTag or email',
                  hintStyle: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textSecondary, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(sendControllerProvider.notifier)
                               .searchUsers('');
                          },
                        )
                      : null,
                ),
                onChanged: (q) => ref
                    .read(sendControllerProvider.notifier)
                    .searchUsers(q),
              ),
            ],
          ),
        ),

        Expanded(
          child: sendState is SendSearching
              ? const Center(child: CircularProgressIndicator(
                  color: AppColors.neonGreen))
              : sendState is SendSearchResults
                  ? _buildResultsList(sendState.results)
                  : sendState is SendError
                      ? Center(child: Text(
                          sendState.message,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.error),
                        ))
                      : _buildEmptySearch(),
        ),
      ],
    );
  }

  Widget _buildResultsList(List<SearchResult> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_search_rounded,
              color: AppColors.textTertiary, size: 48),
            const SizedBox(height: 12),
            Text('No users found', style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final user = results[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: _UserAvatar(initials: '\${user.firstName[0]}\${user.lastName[0]}'),
          title: Text(user.fullName, style: AppTypography.bodyLarge),
          subtitle: Text(user.formattedTag, style: AppTypography.lyraTag.copyWith(
            fontSize: 13,
          )),
          onTap: () {
            setState(() {
              _selectedRecipient = user;
              _step = 1;
            });
          },
        );
      },
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline_rounded,
            color: AppColors.textTertiary, size: 56),
          const SizedBox(height: 16),
          Text('Enter a \$LyraTag to find someone',
            style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildConfirmStep(SendState sendState) {
    final recipient = _selectedRecipient!;
    return Padding(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _UserAvatar(
                  initials: '\${recipient.firstName[0]}\${recipient.lastName[0]}',
                  size: 52,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipient.fullName, style: AppTypography.h3),
                      const SizedBox(height: 2),
                      Text(recipient.formattedTag, style: AppTypography.lyraTag),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('Amount', style: AppTypography.label),
                const SizedBox(height: 8),
                Text(
                  Formatters.lyd(widget.initialAmount),
                  style: AppTypography.balanceMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _noteController,
            style: AppTypography.bodyLarge,
            maxLength: 280,
            decoration: const InputDecoration(
              hintText: 'Add a note (optional)',
              prefixIcon: Icon(Icons.edit_note_rounded,
                color: AppColors.textSecondary),
              counterText: '',
            ),
          ),

          const Spacer(),

          LyraButton(
            label: 'Continue to PIN',
            onPressed: () => setState(() => _step = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildPinStep(SendState sendState) {
    final isLoading = sendState is SendProcessing;
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text('Enter Transaction PIN', style: AppTypography.h2,
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Confirm your 4-digit PIN to send\n\${Formatters.lyd(widget.initialAmount)} to \$\${_selectedRecipient?.lyraTag}',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length
                      ? AppColors.neonGreen
                      : AppColors.card,
                  border: Border.all(
                    color: i < _pin.length
                        ? AppColors.neonGreen
                        : AppColors.border,
                  ),
                ),
              ),
            )),
          ),

          const SizedBox(height: 12),

          if (sendState is SendError)
            Text(
              _friendlyError(sendState.message),
              style: AppTypography.label.copyWith(color: AppColors.error),
            ),

          const SizedBox(height: 32),

          if (isLoading)
            const CircularProgressIndicator(color: AppColors.neonGreen)
          else
            NumpadWidget(
              showDecimal: false,
              onDigit: (d) {
                if (_pin.length < 4) {
                  setState(() => _pin += d);
                  if (_pin.length == 4) _submitTransfer();
                }
              },
              onDelete: () {
                if (_pin.isNotEmpty) {
                  setState(() => _pin = _pin.substring(0, _pin.length - 1));
                }
              },
            ),
        ],
      ),
    );
  }

  Future<void> _submitTransfer() async {
    await ref.read(sendControllerProvider.notifier).executeTransfer(
      toLyraTag: _selectedRecipient!.lyraTag,
      amount:    widget.initialAmount,
      pin:       _pin,
      note:      _noteController.text.trim().isEmpty
                     ? null
                     : _noteController.text.trim(),
    );
    setState(() => _pin = '');
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'invalid_pin':       return 'Incorrect PIN. Try again.';
      case 'insufficient_funds':return 'Insufficient balance.';
      case 'daily_limit_exceeded': return 'Daily send limit reached.';
      case 'pin_locked':        return 'PIN locked. Try again later.';
      case 'recipient_not_found': return 'Recipient not found.';
      default:                  return 'Something went wrong. Try again.';
    }
  }

  void _showSuccessSheet(Transfer transfer, SearchResult recipient) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (_) => TransferSuccessSheet(
        transfer:  transfer,
        recipient: recipient,
        onDone:    () {
          Navigator.pop(context);
          context.go('/home');
        },
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  const _UserAvatar({required this.initials, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.neonGreen.withOpacity(0.25),
        ),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: AppTypography.label.copyWith(
            color: AppColors.neonGreen,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.3,
          ),
        ),
      ),
    );
  }
}
