import 'package:equatable/equatable.dart';

enum TransactionType {
  voucherRedemption,
  p2pSend,
  p2pReceive,
  p2pRequest,
  refund,
  adminCredit,
  fee,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
  reversed,
}

class Transaction extends Equatable {
  final String id;
  final String? fromWalletId;
  final String? toWalletId;
  final double amount;
  final double fee;
  final TransactionType type;
  final TransactionStatus status;
  final String? note;
  final String? referenceId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  final String? fromUserName;
  final String? fromLyraTag;
  final String? toUserName;
  final String? toLyraTag;

  const Transaction({
    required this.id,
    this.fromWalletId,
    this.toWalletId,
    required this.amount,
    required this.fee,
    required this.type,
    required this.status,
    this.note,
    this.referenceId,
    this.metadata,
    required this.createdAt,
    this.fromUserName,
    this.fromLyraTag,
    this.toUserName,
    this.toLyraTag,
  });

  bool get isCredit =>
      type == TransactionType.voucherRedemption ||
      type == TransactionType.p2pReceive ||
      type == TransactionType.adminCredit;

  bool get isPending => status == TransactionStatus.pending;
  bool get isCompleted => status == TransactionStatus.completed;

  String get displayName {
    if (type == TransactionType.voucherRedemption) return 'Voucher Redemption';
    if (isCredit) return fromUserName ?? fromLyraTag ?? 'Unknown';
    return toUserName ?? toLyraTag ?? 'Unknown';
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.voucherRedemption: return 'Voucher';
      case TransactionType.p2pSend:    return 'Sent';
      case TransactionType.p2pReceive: return 'Received';
      case TransactionType.p2pRequest: return 'Request';
      default: return 'Transfer';
    }
  }

  @override
  List<Object?> get props => [id, status, amount];
}
