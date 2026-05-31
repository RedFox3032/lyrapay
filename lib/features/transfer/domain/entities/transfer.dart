import 'package:equatable/equatable.dart';

class Transfer extends Equatable {
  final String transactionId;
  final double amount;
  final double newBalance;
  final String toLyraTag;
  final String? note;
  final bool isIdempotent;

  const Transfer({
    required this.transactionId,
    required this.amount,
    required this.newBalance,
    required this.toLyraTag,
    this.note,
    this.isIdempotent = false,
  });

  @override
  List<Object?> get props => [transactionId];
}
