import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    super.fromWalletId,
    super.toWalletId,
    required super.amount,
    required super.fee,
    required super.type,
    required super.status,
    super.note,
    super.referenceId,
    super.metadata,
    required super.createdAt,
    super.fromUserName,
    super.fromLyraTag,
    super.toUserName,
    super.toLyraTag,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final typeStr = json['type'] as String? ?? 'p2p_send';

    TransactionType resolvedType;
    switch (typeStr) {
      case 'voucher_redemption': resolvedType = TransactionType.voucherRedemption; break;
      case 'p2p_send': resolvedType = TransactionType.p2pSend; break;
      case 'p2p_receive': resolvedType = TransactionType.p2pReceive; break;
      case 'p2p_request': resolvedType = TransactionType.p2pRequest; break;
      case 'refund': resolvedType = TransactionType.refund; break;
      case 'admin_credit': resolvedType = TransactionType.adminCredit; break;
      case 'fee': resolvedType = TransactionType.fee; break;
      default: resolvedType = TransactionType.p2pSend;
    }

    TransactionStatus resolvedStatus;
    switch (json['status'] as String? ?? 'pending') {
      case 'completed': resolvedStatus = TransactionStatus.completed; break;
      case 'failed': resolvedStatus = TransactionStatus.failed; break;
      case 'cancelled': resolvedStatus = TransactionStatus.cancelled; break;
      case 'reversed': resolvedStatus = TransactionStatus.reversed; break;
      default: resolvedStatus = TransactionStatus.pending;
    }

    return TransactionModel(
      id:           json['id'] as String,
      fromWalletId: json['from_wallet_id'] as String?,
      toWalletId:   json['to_wallet_id'] as String?,
      amount:       (json['amount'] as num).toDouble(),
      fee:          (json['fee'] as num? ?? 0).toDouble(),
      type:         resolvedType,
      status:       resolvedStatus,
      note:         json['note'] as String?,
      referenceId:  json['reference_id'] as String?,
      metadata:     json['metadata'] as Map<String, dynamic>?,
      createdAt:    DateTime.parse(json['created_at'] as String),
      fromUserName: json['from_user_name'] as String?,
      fromLyraTag:  json['from_lyra_tag'] as String?,
      toUserName:   json['to_user_name'] as String?,
      toLyraTag:    json['to_lyra_tag'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'amount':       amount,
    'type':         type.name,
    'status':       status.name,
    'note':         note,
    'created_at':   createdAt.toIso8601String(),
  };
}
