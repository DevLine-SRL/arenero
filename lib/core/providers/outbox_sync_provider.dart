import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/clients/presentation/providers/clients_search_provider.dart';
import '../../features/sales/presentation/providers/sales_history_provider.dart';
import 'connectivity_provider.dart';
import 'outbox_executor_provider.dart';
import 'sync_local_datasource_provider.dart';

part 'outbox_sync_provider.g.dart';

@Riverpod(keepAlive: true)
class OutboxSync extends _$OutboxSync {
  bool _draining = false;

  @override
  void build() {
    ref.listen(connectionStatusProvider, (previous, next) {
      _maybeDrain();
    });
    ref.listen(authSessionProvider, (previous, next) {
      _maybeDrain();
    });
  }

  void _maybeDrain() {
    if (ref.read(authSessionProvider).value == null) return;
    if (ref.read(connectionStatusProvider).value != ConnectionStatus.online) {
      return;
    }
    _drain();
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    try {
      final changed = await ref.read(outboxExecutorProvider).drain();
      if (changed && ref.mounted) {
        ref.invalidate(salesHistoryProvider);
        ref.invalidate(clientsSearchProvider);
      }
    } finally {
      _draining = false;
    }
  }

  Future<void> retryFailed() async {
    await ref.read(syncLocalDataSourceProvider).retryFailed();
    if (ref.read(authSessionProvider).value == null) return;
    await _drain();
  }

  Future<void> syncNow() async {
    if (ref.read(authSessionProvider).value == null) return;
    await _drain();
  }
}
