import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';
import '../../../../shared/providers/app_providers.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

// Reactive to Supabase auth changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.asyncMap((event) async {
    if (event.session == null) return const AuthUnauthenticated();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.getCurrentUser();
    return result.fold(
      (failure) => const AuthUnauthenticated(),
      (user) {
        if (user != null) return AuthAuthenticated(user);
        return AuthNeedsLyraTag(
          userId: event.session!.user.id,
          firstName: event.session!.user.userMetadata?['first_name'] ?? '',
          lastName: event.session!.user.userMetadata?['last_name'] ?? '',
          email: event.session!.user.email ?? '',
        );
      },
    );
  });
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthInitial()) {
    _checkCurrentSession();
  }

  Future<void> _checkCurrentSession() async {
    state = const AuthLoading();
    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) => state = const AuthUnauthenticated(),
      (user) {
        if (user != null) {
          state = AuthAuthenticated(user);
        } else {
          final session = Supabase.instance.client.auth.currentUser;
          if (session != null) {
            final meta = session.userMetadata ?? {};
            state = AuthNeedsLyraTag(
              userId:    session.id,
              firstName: meta['first_name'] as String? ?? '',
              lastName:  meta['last_name'] as String? ?? '',
              email:     session.email ?? '',
            );
          } else {
            state = const AuthUnauthenticated();
          }
        }
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = const AuthLoading();
    final result = await _repository.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = AuthEmailUnverified(email),
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    final result = await _repository.signIn(email: email, password: password);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthUnauthenticated();
  }

  Future<void> resetPassword(String email) async {
    state = const AuthLoading();
    final result = await _repository.resetPassword(email);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const AuthUnauthenticated(),
    );
  }

  Future<bool> checkLyraTagAvailable(String tag) async {
    final result = await _repository.isLyraTagAvailable(tag);
    return result.fold((failure) => false, (available) => available);
  }

  Future<void> claimLyraTag({
    required String userId,
    required String tag,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    state = const AuthLoading();
    final result = await _repository.claimLyraTag(
      userId, tag,
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) async => await _checkCurrentSession(),
    );
  }
}
