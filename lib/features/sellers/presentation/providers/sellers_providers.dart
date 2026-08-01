import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/supabase_client_provider.dart';
import '../../data/datasources/sellers_remote_datasource.dart';
import '../../data/repositories/sellers_repository_impl.dart';
import '../../domain/repositories/sellers_repository.dart';
import '../../domain/usecases/get_sellers_usecase.dart';
import '../../domain/usecases/set_sellers_active_usecase.dart';

part 'sellers_providers.g.dart';

@riverpod
SellersRemoteDataSource sellersRemoteDataSource(Ref ref) {
  return SellersRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}

@riverpod
SellersRepository sellersRepository(Ref ref) {
  return SellersRepositoryImpl(ref.watch(sellersRemoteDataSourceProvider));
}

@riverpod
GetSellersUseCase getSellersUseCase(Ref ref) {
  return GetSellersUseCase(ref.watch(sellersRepositoryProvider));
}

@riverpod
SetSellersActiveUseCase setSellersActiveUseCase(Ref ref) {
  return SetSellersActiveUseCase(ref.watch(sellersRepositoryProvider));
}
