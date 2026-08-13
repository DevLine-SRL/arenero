import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import 'connectivity_provider.dart';
import 'outbox_executor_provider.dart';

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
      await ref.read(outboxExecutorProvider).drain();
    } finally {
      _draining = false;
    }
  }
}
