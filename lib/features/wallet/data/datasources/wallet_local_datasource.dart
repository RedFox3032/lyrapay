import 'package:hive_flutter/hive_flutter.dart';
import '../models/wallet_model.dart';

abstract class WalletLocalDataSource {
  Future<WalletModel?> getCachedWallet(String userId);
  Future<void> cacheWallet(WalletModel wallet);
  Future<void> clearCache();
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  static const _boxName = 'wallet_box';

  Future<Box> get _box async => await Hive.openBox(_boxName);

  @override
  Future<WalletModel?> getCachedWallet(String userId) async {
    final box = await _box;
    final data = box.get('wallet_\$userId');
    if (data == null) return null;
    return WalletModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<void> cacheWallet(WalletModel wallet) async {
    final box = await _box;
    await box.put('wallet_\${wallet.userId}', wallet.toJson());
  }

  @override
  Future<void> clearCache() async {
    final box = await _box;
    await box.clear();
  }
}
