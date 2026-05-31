import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/wallet/data/datasources/wallet_remote_datasource.dart';
import '../../features/wallet/data/datasources/wallet_local_datasource.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/transfer/data/datasources/transfer_remote_datasource.dart';
import '../../features/activity/data/datasources/activity_remote_datasource.dart';
import '../../features/activity/data/datasources/activity_local_datasource.dart';
import '../../features/activity/data/repositories/activity_repository_impl.dart';
import '../../features/activity/domain/repositories/activity_repository.dart';
import '../../core/services/connectivity_service.dart';

// ── Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ── Auth
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(supabaseClientProvider),
  );
});

// ── Wallet
final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  return WalletRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
});

final walletLocalDataSourceProvider = Provider<WalletLocalDataSource>((ref) {
  return WalletLocalDataSourceImpl();
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(
    ref.watch(walletRemoteDataSourceProvider),
    ref.watch(walletLocalDataSourceProvider),
  );
});

// ── Transfer
final transferDataSourceProvider = Provider<TransferRemoteDataSource>((ref) {
  return TransferRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
});

// ── Activity
final activityRemoteDataSourceProvider = Provider<ActivityRemoteDataSource>((ref) {
  return ActivityRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
});

final activityLocalDataSourceProvider = Provider<ActivityLocalDataSource>((ref) {
  return ActivityLocalDataSourceImpl();
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl(
    ref.watch(activityRemoteDataSourceProvider),
    ref.watch(activityLocalDataSourceProvider),
  );
});

// ── Connectivity
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).onConnectivityChanged;
});
