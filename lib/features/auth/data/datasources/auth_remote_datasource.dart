import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/errors/app_exception.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<UserModel?> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserModel?> getCurrentUser();
  Future<bool> isLyraTagAvailable(String tag);
  Future<void> claimLyraTag(String userId, String tag);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (response.user == null) {
        throw const AppException('Sign up failed: no user returned');
      }

      return null;
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode);
    }
  }

  @override
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) return null;

      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(profile);
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode);
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(profile);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isLyraTagAvailable(String tag) async {
    final result = await _client.rpc(
      'check_lyra_tag_available',
      params: {'p_tag': tag},
    );
    return result as bool? ?? false;
  }

  @override
  Future<void> claimLyraTag(String userId, String tag) async {
    await _client.from('profiles').insert({
      'id': userId,
      'lyra_tag': tag,
    });
  }
}
