import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/clients/presentation/providers/clients_search_provider.dart';
import '../../features/products/presentation/providers/products_controller_provider.dart';
import '../../features/sales/presentation/providers/sales_history_provider.dart';
import 'outbox_sync_provider.dart';

part 'app_lifecycle_sync_provider.g.dart';

@Riverpod(keepAlive: true)
class AppLifecycleSync extends _$AppLifecycleSync {
  AppLifecycleListener? _listener;
  bool _syncing = false;

  @override
  void build() {
    _listener = AppLifecycleListener(onResume: _onResume);
    ref.onDispose(_disposeListener);
  }

  void _onResume() {
    _sync();
  }

  Future<void> _sync() async {
    if (_syncing) return;
    _syncing = true;
    try {
      await ref.read(outboxSyncProvider.notifier).syncNow();
      if (!ref.mounted) return;
      ref.invalidate(salesHistoryProvider);
      ref.invalidate(clientsSearchProvider);
      ref.invalidate(productsControllerProvider);
    } finally {
      _syncing = false;
    }
  }

  void _disposeListener() {
    _listener?.dispose();
    _listener = null;
  }
}
