class TransferModel {
  final String transactionId;
  final double amount;
  final double newBalance;
  final String toLyraTag;
  final String? note;
  final bool isIdempotent;

  TransferModel({
    required this.transactionId,
    required this.amount,
    required this.newBalance,
    required this.toLyraTag,
    this.note,
    this.isIdempotent = false,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      transactionId: json['transaction_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      newBalance: (json['new_balance'] as num).toDouble(),
      toLyraTag: json['to_lyra_tag'] as String,
      note: json['note'] as String?,
      isIdempotent: json['idempotent'] as bool? ?? false,
    );
  }
}
