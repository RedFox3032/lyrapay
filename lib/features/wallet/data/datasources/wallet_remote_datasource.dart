import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_model.dart';
import '../../../../core/errors/app_exception.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet(String userId);
  Stream<WalletModel> watchWallet(String userId);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final SupabaseClient _client;
  WalletRemoteDataSourceImpl(this._client);

  @override
  Future<WalletModel> getWallet(String userId) async {
    try {
      final data = await _client
          .from('wallets')
          .select('*, profiles!inner(daily_limit)')
          .eq('user_id', userId)
          .single();

      final flat = {
        ...data,
        'daily_limit': data['profiles']['daily_limit'],
      };
      flat.remove('profiles');

      return WalletModel.fromJson(flat);
    } catch (e) {
      throw AppException('Failed to load wallet: \$e');
    }
  }

  @override
  Stream<WalletModel> watchWallet(String userId) {
    return _client
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) {
          if (rows.isEmpty) throw const AppException('Wallet not found');
          return WalletModel.fromJson(rows.first);
        });
  }
}
