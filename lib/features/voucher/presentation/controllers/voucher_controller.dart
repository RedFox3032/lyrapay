import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'voucher_state.dart';

final voucherControllerProvider = StateNotifierProvider<VoucherController, VoucherState>((ref) {
  return VoucherController();
});

class VoucherController extends StateNotifier<VoucherState> {
  VoucherController() : super(const VoucherInitial());
}
