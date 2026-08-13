import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/app_database_provider.dart';
import '../../../../core/providers/is_online_provider.dart';
import '../../../../core/providers/supabase_client_provider.dart';
import '../../../../core/providers/sync_local_datasource_provider.dart';
import '../../data/datasources/clients_local_datasource.dart';
import '../../data/datasources/clients_remote_datasource.dart';
import '../../data/repositories/clients_repository_impl.dart';
import '../../domain/repositories/clients_repository.dart';
import '../../domain/usecases/check_ci_available_usecase.dart';
import '../../domain/usecases/create_client_usecase.dart';
import '../../domain/usecases/search_cached_clients_usecase.dart';
import '../../domain/usecases/search_clients_usecase.dart';

part 'clients_providers.g.dart';

@riverpod
ClientsRemoteDataSource clientsRemoteDataSource(Ref ref) {
  return ClientsRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}

@riverpod
ClientsLocalDataSource clientsLocalDataSource(Ref ref) {
  return ClientsLocalDataSourceImpl(ref.watch(appDatabaseProvider));
}

@riverpod
ClientsRepository clientsRepository(Ref ref) {
  return ClientsRepositoryImpl(
    ref.watch(clientsRemoteDataSourceProvider),
    ref.watch(clientsLocalDataSourceProvider),
    syncDataSource: ref.watch(syncLocalDataSourceProvider),
    isOnline: () => ref.read(isOnlineProvider),
  );
}

@riverpod
SearchClientsUseCase searchClientsUseCase(Ref ref) {
  return SearchClientsUseCase(ref.watch(clientsRepositoryProvider));
}

@riverpod
SearchCachedClientsUseCase searchCachedClientsUseCase(Ref ref) {
  return SearchCachedClientsUseCase(ref.watch(clientsRepositoryProvider));
}

@riverpod
CreateClientUseCase createClientUseCase(Ref ref) {
  return CreateClientUseCase(ref.watch(clientsRepositoryProvider));
}

@riverpod
CheckCiAvailableUseCase checkCiAvailableUseCase(Ref ref) {
  return CheckCiAvailableUseCase(ref.watch(clientsRepositoryProvider));
}
