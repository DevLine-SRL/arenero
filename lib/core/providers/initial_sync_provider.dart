import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/clients/presentation/providers/clients_providers.dart';
import '../../features/products/presentation/providers/products_providers.dart';
import '../../features/sales/presentation/providers/sales_providers.dart';
import 'outbox_executor_provider.dart';

part 'initial_sync_provider.g.dart';

@Riverpod(keepAlive: true)
class InitialSync extends _$InitialSync {
  String? _preloadedForUser;
  bool _running = false;

  @override
  void build() {
    ref.listen(authSessionProvider, (previous, next) {
      final user = next.value;
      if (user == null) {
        _preloadedForUser = null;
        return;
      }
      if (_preloadedForUser == user.id) return;
      _preloadedForUser = user.id;
      _runInitialSync();
    });
  }

  Future<void> _runInitialSync() async {
    if (_running) return;
    _running = true;
    try {
      await ref.read(outboxExecutorProvider).drain();
      await Future.wait([
        _preloadClients(),
        _preloadProducts(),
        _preloadSalesHistory(),
      ]);
    } finally {
      _running = false;
    }
  }

  Future<void> _preloadClients() async {
    final result = await ref.read(searchClientsUseCaseProvider)(
      includeInactive: true,
    );
    result.fold((_) {}, (_) {});
  }

  Future<void> _preloadProducts() async {
    final result = await ref.read(getProductsUseCaseProvider)();
    result.fold((_) {}, (_) {});
  }

  Future<void> _preloadSalesHistory() async {
    final result = await ref.read(getSalesHistoryUseCaseProvider)();
    result.fold((_) {}, (_) {});
  }
}
