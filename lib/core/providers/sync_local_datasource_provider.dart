import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/datasources/sync_local_datasource.dart';
import 'app_database_provider.dart';

part 'sync_local_datasource_provider.g.dart';

@Riverpod(keepAlive: true)
SyncLocalDataSource syncLocalDataSource(Ref ref) {
  return SyncLocalDataSourceImpl(ref.watch(appDatabaseProvider));
}
