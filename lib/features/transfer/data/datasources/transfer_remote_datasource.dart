import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/app_exception.dart';

abstract class TransferRemoteDataSource {
  Future<Map<String, dynamic>> processTransfer({
    required String toLyraTag,
    required double amount,
    required String pin,
    String? note,
  });

  Future<List<Map<String, dynamic>>> searchUsers(String query);
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  TransferRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> processTransfer({
    required String toLyraTag,
    required double amount,
    required String pin,
    String? note,
  }) async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) throw const AppException('Not authenticated');

      final response = await _client.functions.invoke(
        'process-transfer',
        body: {
          'to_lyra_tag':   toLyraTag,
          'amount':        amount,
          'pin':           pin,
          'note':          note ?? '',
          'reference_id':  _uuid.v4(),
        },
        headers: {
          'Authorization': 'Bearer \${session.accessToken}',
        },
      );

      if (response.data == null) {
        throw const AppException('Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      if (data['error'] != null) {
        throw AppException(data['error'] as String);
      }

      return data;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Transfer failed: \$e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];

      final results = await _client
          .from('profiles')
          .select('id, first_name, last_name, lyra_tag, avatar_url')
          .or('lyra_tag.ilike.%\${query.replaceAll('\$', '')}%,email.ilike.%\$query%')
          .neq('id', currentUser.id)
          .limit(10);

      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      throw AppException('Search failed: \$e');
    }
  }
}
