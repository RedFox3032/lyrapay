import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/transfer_remote_datasource.dart';
import '../../domain/entities/transfer.dart';
import 'send_state.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';
import '../../../../shared/providers/app_providers.dart';

final sendControllerProvider =
    StateNotifierProvider.autoDispose<SendController, SendState>((ref) {
  final dataSource = ref.watch(transferDataSourceProvider);
  return SendController(dataSource, ref);
});

class SendController extends StateNotifier<SendState> {
  final TransferRemoteDataSource _dataSource;
  final Ref _ref;

  SendController(this._dataSource, this._ref) : super(const SendInitial());

  Future<void> searchUsers(String query) async {
    if (query.trim().length < 2) {
      state = const SendInitial();
      return;
    }
    state = const SendSearching();
    try {
      final results = await _dataSource.searchUsers(query);
      state = SendSearchResults(results.map(SearchResult.fromJson).toList());
    } catch (e) {
      state = SendError(e.toString());
    }
  }

  void selectRecipient(SearchResult recipient, double amount) {
    state = SendRecipientSelected(recipient, amount);
  }

  Future<void> executeTransfer({
    required String toLyraTag,
    required double amount,
    required String pin,
    String? note,
  }) async {
    state = const SendProcessing();

    _ref.read(walletControllerProvider.notifier).applyOptimisticDebit(amount);

    try {
      final result = await _dataSource.processTransfer(
        toLyraTag: toLyraTag,
        amount:    amount,
        pin:       pin,
        note:      note,
      );

      final transfer = Transfer(
        transactionId: result['transaction_id'] as String,
        amount:        amount,
        newBalance:    (result['new_balance'] as num).toDouble(),
        toLyraTag:     toLyraTag,
        note:          note,
        isIdempotent:  result['idempotent'] as bool? ?? false,
      );

      _ref.read(walletControllerProvider.notifier).fetchWallet();

      final currentState = state;
      if (currentState is SendRecipientSelected) {
        state = SendSuccess(transfer, currentState.recipient);
      } else {
        state = SendSuccess(transfer, SearchResult(
          id: '', firstName: '', lastName: '', lyraTag: toLyraTag,
        ));
      }
    } catch (e) {
      _ref.read(walletControllerProvider.notifier).rollbackOptimistic();
      state = SendError(e.toString());
    }
  }
}
