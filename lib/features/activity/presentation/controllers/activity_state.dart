import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();
}
class ActivityLoading extends ActivityState {
  const ActivityLoading();
  @override List<Object?> get props => [];
}
class ActivityLoaded extends ActivityState {
  final List<Transaction> transactions;
  final bool hasMore;
  final String? activeFilter;
  const ActivityLoaded(this.transactions, {this.hasMore = false, this.activeFilter});
  @override List<Object?> get props => [transactions, activeFilter];
}
class ActivityError extends ActivityState {
  final String message;
  const ActivityError(this.message);
  @override List<Object?> get props => [message];
}
