import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/app_database_provider.dart';
import '../../../../core/providers/is_online_provider.dart';
import '../../../../core/providers/supabase_client_provider.dart';
import '../../data/datasources/sellers_local_datasource.dart';
import '../../data/datasources/sellers_remote_datasource.dart';
import '../../data/repositories/sellers_repository_impl.dart';
import '../../domain/repositories/sellers_repository.dart';
import '../../domain/usecases/create_seller_usecase.dart';
import '../../domain/usecases/get_cached_sellers_usecase.dart';
import '../../domain/usecases/get_sellers_usecase.dart';
import '../../domain/usecases/set_sellers_active_usecase.dart';

part 'sellers_providers.g.dart';

@riverpod
SellersRemoteDataSource sellersRemoteDataSource(Ref ref) {
  return SellersRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}

@riverpod
SellersLocalDataSource sellersLocalDataSource(Ref ref) {
  return SellersLocalDataSourceImpl(ref.watch(appDatabaseProvider));
}

@riverpod
SellersRepository sellersRepository(Ref ref) {
  return SellersRepositoryImpl(
    ref.watch(sellersRemoteDataSourceProvider),
    ref.watch(sellersLocalDataSourceProvider),
    isOnline: () => ref.read(isOnlineProvider),
  );
}

@riverpod
GetSellersUseCase getSellersUseCase(Ref ref) {
  return GetSellersUseCase(ref.watch(sellersRepositoryProvider));
}

@riverpod
GetCachedSellersUseCase getCachedSellersUseCase(Ref ref) {
  return GetCachedSellersUseCase(ref.watch(sellersRepositoryProvider));
}

@riverpod
SetSellersActiveUseCase setSellersActiveUseCase(Ref ref) {
  return SetSellersActiveUseCase(ref.watch(sellersRepositoryProvider));
}

@riverpod
CreateSellerUseCase createSellerUseCase(Ref ref) {
  return CreateSellerUseCase(ref.watch(sellersRepositoryProvider));
}
