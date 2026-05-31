import 'package:equatable/equatable.dart';
import '../../domain/entities/transfer.dart';

class SearchResult extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String lyraTag;
  final String? avatarUrl;

  const SearchResult({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.lyraTag,
    this.avatarUrl,
  });

  String get fullName => '\$firstName \$lastName';
  String get formattedTag => '\$\$lyraTag';

  factory SearchResult.fromJson(Map<String, dynamic> j) => SearchResult(
    id:        j['id'] as String,
    firstName: j['first_name'] as String,
    lastName:  j['last_name'] as String,
    lyraTag:   j['lyra_tag'] as String,
    avatarUrl: j['avatar_url'] as String?,
  );

  @override List<Object?> get props => [id];
}

abstract class SendState extends Equatable {
  const SendState();
}

class SendInitial extends SendState {
  const SendInitial();
  @override List<Object?> get props => [];
}

class SendSearching extends SendState {
  const SendSearching();
  @override List<Object?> get props => [];
}

class SendSearchResults extends SendState {
  final List<SearchResult> results;
  const SendSearchResults(this.results);
  @override List<Object?> get props => [results];
}

class SendRecipientSelected extends SendState {
  final SearchResult recipient;
  final double amount;
  const SendRecipientSelected(this.recipient, this.amount);
  @override List<Object?> get props => [recipient, amount];
}

class SendProcessing extends SendState {
  const SendProcessing();
  @override List<Object?> get props => [];
}

class SendSuccess extends SendState {
  final Transfer transfer;
  final SearchResult recipient;
  const SendSuccess(this.transfer, this.recipient);
  @override List<Object?> get props => [transfer];
}

class SendError extends SendState {
  final String message;
  final String? code;
  const SendError(this.message, {this.code});
  @override List<Object?> get props => [message, code];
}
