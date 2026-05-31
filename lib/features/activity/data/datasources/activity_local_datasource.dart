import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

abstract class ActivityLocalDataSource {
  Future<List<TransactionModel>> getCachedTransactions(String userId);
  Future<void> cacheTransactions(String userId, List<TransactionModel> txns);
  Future<void> prependTransaction(String userId, TransactionModel txn);
}

class ActivityLocalDataSourceImpl implements ActivityLocalDataSource {
  static const _boxName = 'activity_box';

  Future<Box> get _box async => await Hive.openBox(_boxName);

  @override
  Future<List<TransactionModel>> getCachedTransactions(String userId) async {
    final box  = await _box;
    final data = box.get('txns_\$userId');
    if (data == null) return [];
    final list = (data as List).cast<Map>();
    return list
        .map((m) => TransactionModel.fromJson(
              Map<String, dynamic>.from(m), userId))
        .toList();
  }

  @override
  Future<void> cacheTransactions(
      String userId, List<TransactionModel> txns) async {
    final box = await _box;
    final limited = txns.take(50).toList();
    await box.put('txns_\$userId', limited.map((t) => t.toJson()).toList());
  }

  @override
  Future<void> prependTransaction(
      String userId, TransactionModel txn) async {
    final existing = await getCachedTransactions(userId);
    final updated = [txn, ...existing.where((t) => t.id != txn.id)];
    await cacheTransactions(userId, updated);
  }
}
