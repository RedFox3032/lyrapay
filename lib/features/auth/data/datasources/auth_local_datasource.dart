import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheSession(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> cacheSession(String accessToken, String refreshToken) async {
    await _storage.write(key: 'supabase_access_token', value: accessToken);
    await _storage.write(key: 'supabase_refresh_token', value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: 'supabase_access_token');

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: 'supabase_access_token');
    await _storage.delete(key: 'supabase_refresh_token');
  }
}
