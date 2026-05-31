import 'package:equatable/equatable.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override List<Object?> get props => [];
}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);
  @override List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override List<Object?> get props => [];
}

class AuthEmailUnverified extends AuthState {
  final String email;
  const AuthEmailUnverified(this.email);
  @override List<Object?> get props => [email];
}

class AuthNeedsLyraTag extends AuthState {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  const AuthNeedsLyraTag({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });
  @override List<Object?> get props => [userId];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override List<Object?> get props => [message];
}
