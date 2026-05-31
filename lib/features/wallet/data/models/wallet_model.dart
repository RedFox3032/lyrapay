import '../../domain/entities/wallet.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.balance,
    required super.heldBalance,
    required super.dailySent,
    required super.dailyLimit,
    required super.currency,
    required super.isFrozen,
    required super.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id:           json['id'] as String,
      userId:       json['user_id'] as String,
      balance:      (json['balance'] as num).toDouble(),
      heldBalance:  (json['held_balance'] as num? ?? 0).toDouble(),
      dailySent:    (json['daily_sent'] as num? ?? 0).toDouble(),
      dailyLimit:   (json['daily_limit'] as num? ?? 5000).toDouble(),
      currency:     json['currency'] as String? ?? 'LYD',
      isFrozen:     json['is_frozen'] as bool? ?? false,
      updatedAt:    DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'user_id':      userId,
    'balance':      balance,
    'held_balance': heldBalance,
    'daily_sent':   dailySent,
    'currency':     currency,
    'is_frozen':    isFrozen,
    'updated_at':   updatedAt.toIso8601String(),
  };
}
