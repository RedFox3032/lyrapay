import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/app_exception.dart';

class OfflineQueueEntry {
  final String referenceId;
  final String actionType;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  int attempts;

  OfflineQueueEntry({
    required this.referenceId,
    required this.actionType,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
  });

  Map<String, dynamic> toJson() => {
    'reference_id': referenceId,
    'action_type':  actionType,
    'payload':      payload,
    'created_at':   createdAt.toIso8601String(),
    'attempts':     attempts,
  };

  factory OfflineQueueEntry.fromJson(Map<String, dynamic> j) => OfflineQueueEntry(
    referenceId: j['reference_id'] as String,
    actionType:  j['action_type'] as String,
    payload:     Map<String, dynamic>.from(j['payload'] as Map),
    createdAt:   DateTime.parse(j['created_at'] as String),
    attempts:    j['attempts'] as int? ?? 0,
  );
}

class SyncService {
  static const _boxName = 'offline_queue';
  static const _maxAttempts = 5;

  final SupabaseClient _client;
  SyncService(this._client);

  Future<Box> get _box async => await Hive.openBox(_boxName);

  Future<void> enqueue(OfflineQueueEntry entry) async {
    final box = await _box;
    await box.put(entry.referenceId, entry.toJson());
  }

  Future<void> processQueue() async {
    final box  = await _box;
    final keys = box.keys.toList();
    if (keys.isEmpty) return;

    final session = _client.auth.currentSession;
    if (session == null) return;

    final actions = <Map<String, dynamic>>[];
    for (final key in keys) {
      final data = box.get(key);
      if (data != null) {
        final entry = OfflineQueueEntry.fromJson(
          Map<String, dynamic>.from(data as Map));
        if (entry.attempts < _maxAttempts) {
          actions.add(entry.toJson());
        }
      }
    }

    if (actions.isEmpty) return;

    try {
      final response = await _client.functions.invoke(
        'sync-offline-queue',
        body: {'actions': actions},
        headers: {'Authorization': 'Bearer \${session.accessToken}'},
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      for (final result in results) {
        final refId  = result['reference_id'] as String;
        final status = result['status'] as String;
        if (status == 'completed' || status == 'already_processed') {
          await box.delete(refId);
        } else {
          final existing = box.get(refId);
          if (existing != null) {
            final entry = OfflineQueueEntry.fromJson(
              Map<String, dynamic>.from(existing as Map));
            entry.attempts++;
            if (entry.attempts >= _maxAttempts) {
              await box.delete(refId);
            } else {
              await box.put(refId, entry.toJson());
            }
          }
        }
      }
    } catch (e) {
      // Will retry on next connectivity restore
    }
  }

  Future<int> get queueLength async {
    final box = await _box;
    return box.length;
  }

  Future<void> clearQueue() async {
    final box = await _box;
    await box.clear();
  }
}
