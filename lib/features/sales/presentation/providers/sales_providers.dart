import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/app_database_provider.dart';
import '../../../../core/providers/is_online_provider.dart';
import '../../../../core/providers/supabase_client_provider.dart';
import '../../../../core/providers/sync_local_datasource_provider.dart';
import '../../data/datasources/sales_local_datasource.dart';
import '../../data/datasources/sales_remote_datasource.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/usecases/get_cached_sale_detail_usecase.dart';
import '../../domain/usecases/get_cached_sales_history_usecase.dart';
import '../../domain/usecases/get_sale_detail_usecase.dart';
import '../../domain/usecases/get_sales_history_usecase.dart';
import '../../domain/usecases/get_sales_usecase.dart';
import '../../domain/usecases/register_sale_usecase.dart';
import '../../domain/usecases/void_sale_usecase.dart';

part 'sales_providers.g.dart';

@riverpod
SalesRemoteDataSource salesRemoteDataSource(Ref ref) {
  return SalesRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}

@riverpod
SalesLocalDataSource salesLocalDataSource(Ref ref) {
  return SalesLocalDataSourceImpl(ref.watch(appDatabaseProvider));
}

@riverpod
SalesRepository salesRepository(Ref ref) {
  return SalesRepositoryImpl(
    ref.watch(salesRemoteDataSourceProvider),
    ref.watch(salesLocalDataSourceProvider),
    syncDataSource: ref.watch(syncLocalDataSourceProvider),
    isOnline: () => ref.read(isOnlineProvider),
  );
}

@riverpod
RegisterSaleUseCase registerSaleUseCase(Ref ref) {
  return RegisterSaleUseCase(ref.watch(salesRepositoryProvider));
}

@riverpod
GetSalesUseCase getSalesUseCase(Ref ref) {
  return GetSalesUseCase(ref.watch(salesRepositoryProvider));
}

@riverpod
GetSalesHistoryUseCase getSalesHistoryUseCase(Ref ref) {
  return GetSalesHistoryUseCase(ref.watch(salesRepositoryProvider));
}

@riverpod
GetCachedSalesHistoryUseCase getCachedSalesHistoryUseCase(Ref ref) {
  return GetCachedSalesHistoryUseCase(ref.watch(salesRepositoryProvider));
}

@riverpod
GetSaleDetailUseCase getSaleDetailUseCase(Ref ref) {
  return GetSaleDetailUseCase(ref.watch(salesRepositoryProvider));
}

@riverpod
GetCachedSaleDetailUseCase getCachedSaleDetailUseCase(Ref ref) {
  return GetCachedSaleDetailUseCase(ref.watch(salesRepositoryProvider));
}

@riverpod
VoidSaleUseCase voidSaleUseCase(Ref ref) {
  return VoidSaleUseCase(ref.watch(salesRepositoryProvider));
}
