import 'package:equatable/equatable.dart';

abstract class VoucherState extends Equatable {
  const VoucherState();
  @override List<Object?> get props => [];
}

class VoucherInitial extends VoucherState {
  const VoucherInitial();
}
class VoucherLoading extends VoucherState {
  const VoucherLoading();
}
class VoucherLoaded extends VoucherState {
  const VoucherLoaded();
}
class VoucherError extends VoucherState {
  final String message;
  const VoucherError(this.message);
  @override List<Object?> get props => [message];
}
