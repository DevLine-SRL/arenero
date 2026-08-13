import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/clients/presentation/providers/clients_providers.dart';
import '../../features/sales/presentation/providers/sales_providers.dart';
import '../data/services/outbox_executor.dart';
import 'is_online_provider.dart';
import 'sync_local_datasource_provider.dart';

part 'outbox_executor_provider.g.dart';

@Riverpod(keepAlive: true)
OutboxExecutor outboxExecutor(Ref ref) {
  return OutboxExecutorImpl(
    syncDataSource: ref.watch(syncLocalDataSourceProvider),
    clientsRemoteDataSource: ref.watch(clientsRemoteDataSourceProvider),
    salesRemoteDataSource: ref.watch(salesRemoteDataSourceProvider),
    clientsLocalDataSource: ref.watch(clientsLocalDataSourceProvider),
    salesLocalDataSource: ref.watch(salesLocalDataSourceProvider),
    isOnline: () => ref.read(isOnlineProvider),
  );
}
