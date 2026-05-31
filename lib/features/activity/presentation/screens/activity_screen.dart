import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../controllers/activity_controller.dart';
import '../controllers/activity_state.dart';
import '../../domain/entities/transaction.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final _tabs = ['All', 'Sent', 'Received', 'Vouchers'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final filter = _tabFilter(_tabController.index);
        ref.read(activityControllerProvider.notifier).setFilter(filter);
      }
    });
  }

  String? _tabFilter(int idx) {
    switch (idx) {
      case 1: return 'p2p_send';
      case 2: return 'p2p_receive';
      case 3: return 'voucher_redemption';
      default: return null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityState = ref.watch(activityControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text('Activity', style: AppTypography.h3),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.neonGreen,
          indicatorWeight: 2,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTypography.label.copyWith(
            fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: AppTypography.label.copyWith(fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((_) => _ActivityList(state: activityState)).toList(),
      ),
    );
  }
}

class _ActivityList extends ConsumerWidget {
  final ActivityState state;
  const _ActivityList({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state is ActivityLoading) return _buildShimmer();
    if (state is ActivityError) return _buildError((state as ActivityError).message, ref);
    if (state is ActivityLoaded) {
      final txns = (state as ActivityLoaded).transactions;
      if (txns.isEmpty) return _buildEmpty();
      return RefreshIndicator(
        color: AppColors.neonGreen,
        backgroundColor: AppColors.card,
        onRefresh: () => ref.read(activityControllerProvider.notifier).refresh(),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: txns.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1, indent: 72, endIndent: 20),
          itemBuilder: (ctx, i) => _TransactionTile(txn: txns[i]),
        ),
      );
    }
    return _buildShimmer();
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (ctx, _) => Shimmer.fromColors(
        baseColor: AppColors.card,
        highlightColor: AppColors.cardElevated,
        child: Container(
          height: 72,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.receipt_long_outlined,
          color: AppColors.textTertiary, size: 56),
        const SizedBox(height: 16),
        Text('No transactions yet', style: AppTypography.bodyMedium),
      ]),
    );
  }

  Widget _buildError(String message, WidgetRef ref) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded,
          color: AppColors.error, size: 48),
        const SizedBox(height: 12),
        Text(message, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => ref.read(activityControllerProvider.notifier).refresh(),
          child: Text('Retry', style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neonGreen)),
        ),
      ]),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction txn;
  const _TransactionTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.isCredit;
    final isPending = txn.isPending;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isCredit
              ? AppColors.neonGreen.withOpacity(0.12)
              : AppColors.card,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _typeIcon(txn.type),
          color: isCredit ? AppColors.neonGreen : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(txn.displayName,
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isPending)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Pending', style: AppTypography.label.copyWith(
                color: AppColors.warning)),
            ),
        ],
      ),
      subtitle: Text(
        Formatters.relativeTime(txn.createdAt),
        style: AppTypography.label,
      ),
      trailing: Text(
        '\${isCredit ? '+' : '-'}\${Formatters.lyd(txn.amount)}',
        style: AppTypography.bodyLarge.copyWith(
          color: isCredit ? AppColors.neonGreen : AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => context.push(
        AppRoutes.transactionDetail.replaceFirst(':id', txn.id),
        extra: txn,
      ),
    );
  }

  IconData _typeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.voucherRedemption: return Icons.card_giftcard_rounded;
      case TransactionType.p2pSend:           return Icons.arrow_upward_rounded;
      case TransactionType.p2pReceive:        return Icons.arrow_downward_rounded;
      case TransactionType.p2pRequest:        return Icons.request_page_rounded;
      default:                                return Icons.swap_horiz_rounded;
    }
  }
}
