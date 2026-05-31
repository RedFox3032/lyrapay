import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'activity_state.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../../shared/providers/app_providers.dart';

final activityControllerProvider =
    StateNotifierProvider<ActivityController, ActivityState>((ref) {
  final repo = ref.watch(activityRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  final userId = authState is AuthAuthenticated ? authState.user.id : null;
  return ActivityController(repo, userId);
});

class ActivityController extends StateNotifier<ActivityState> {
  final ActivityRepository _repository;
  final String? _userId;
  String? _currentFilter;

  ActivityController(this._repository, this._userId)
      : super(const ActivityLoading()) {
    if (_userId != null) _load();
  }

  Future<void> _load() async {
    if (_userId == null) return;
    state = const ActivityLoading();
    final result = await _repository.getTransactions(
      userId: _userId!,
      typeFilter: _currentFilter,
    );
    result.fold(
      (f) => state = ActivityError(f.message),
      (txns) => state = ActivityLoaded(txns, activeFilter: _currentFilter),
    );
  }

  Future<void> refresh() => _load();

  void setFilter(String? filter) {
    _currentFilter = filter;
    _load();
  }

  void prependTransaction(dynamic txn) {
    if (state is ActivityLoaded) {
      final current = (state as ActivityLoaded).transactions;
      state = ActivityLoaded(
        [txn, ...current],
        activeFilter: _currentFilter,
      );
    }
  }
}
