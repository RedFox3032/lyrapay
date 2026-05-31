import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String id;
  final String userId;
  final double balance;
  final double heldBalance;
  final double dailySent;
  final double dailyLimit;
  final String currency;
  final bool isFrozen;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.heldBalance,
    required this.dailySent,
    required this.dailyLimit,
    required this.currency,
    required this.isFrozen,
    required this.updatedAt,
  });

  double get availableBalance => balance - heldBalance;
  double get remainingDailyLimit => dailyLimit - dailySent;
  bool get hasBalance => availableBalance > 0;

  @override
  List<Object?> get props => [id, balance, updatedAt];
}
