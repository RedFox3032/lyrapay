import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String lyraTag;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.lyraTag,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
  });

  String get fullName => '\$firstName \$lastName';
  String get formattedLyraTag => '\$\$lyraTag';
  String get initials => '\${firstName[0]}\${lastName[0]}'.toUpperCase();

  @override
  List<Object?> get props => [id, lyraTag, email];
}
