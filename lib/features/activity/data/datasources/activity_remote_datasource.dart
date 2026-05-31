import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';
import '../../../../core/errors/app_exception.dart';

abstract class ActivityRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({
    required String userId,
    int limit = 50,
    int offset = 0,
    String? typeFilter,
  });

  Stream<TransactionModel> watchNewTransactions(String userId);
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final SupabaseClient _client;
  ActivityRemoteDataSourceImpl(this._client);

  @override
  Future<List<TransactionModel>> getTransactions({
    required String userId,
    int limit = 50,
    int offset = 0,
    String? typeFilter,
  }) async {
    try {
      final walletData = await _client
          .from('wallets')
          .select('id')
          .eq('user_id', userId)
          .single();
      final walletId = walletData['id'] as String;

      var query = _client
          .from('transactions')
          .select('''
            *,
            from_wallet:from_wallet_id(
              user_id,
              profiles!inner(first_name, last_name, lyra_tag)
            ),
            to_wallet:to_wallet_id(
              user_id,
              profiles!inner(first_name, last_name, lyra_tag)
            )
          ''')
          .or('from_wallet_id.eq.\$walletId,to_wallet_id.eq.\$walletId')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (typeFilter != null) {
        query = query.eq('type', typeFilter);
      }

      final results = await query;

      return results.map<TransactionModel>((row) {
        final fromWallet = row['from_wallet'] as Map<String, dynamic>?;
        final toWallet   = row['to_wallet']   as Map<String, dynamic>?;

        final fromProfiles = fromWallet?['profiles'] as Map<String, dynamic>?;
        final toProfiles   = toWallet?['profiles']   as Map<String, dynamic>?;

        final flat = {
          ...row,
          'from_user_name': fromProfiles != null
              ? '\${fromProfiles['first_name']} \${fromProfiles['last_name']}'
              : null,
          'from_lyra_tag': fromProfiles?['lyra_tag'],
          'to_user_name': toProfiles != null
              ? '\${toProfiles['first_name']} \${toProfiles['last_name']}'
              : null,
          'to_lyra_tag': toProfiles?['lyra_tag'],
        };
        flat.remove('from_wallet');
        flat.remove('to_wallet');

        return TransactionModel.fromJson(flat, userId);
      }).toList();
    } catch (e) {
      throw AppException('Failed to load transactions: \$e');
    }
  }

  @override
  Stream<TransactionModel> watchNewTransactions(String userId) async* {
    final walletData = await _client
        .from('wallets')
        .select('id')
        .eq('user_id', userId)
        .single();
    final walletId = walletData['id'] as String;

    final stream = _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(1);

    await for (final rows in stream) {
      for (final row in rows) {
        if (row['from_wallet_id'] == walletId ||
            row['to_wallet_id'] == walletId) {
          yield TransactionModel.fromJson(row, userId);
        }
      }
    }
  }
}
