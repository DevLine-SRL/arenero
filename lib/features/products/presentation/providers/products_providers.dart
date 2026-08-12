import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/app_database_provider.dart';
import '../../../../core/providers/supabase_client_provider.dart';
import '../../data/datasources/products_local_datasource.dart';
import '../../data/datasources/products_remote_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/set_product_active_usecase.dart';
import '../../domain/usecases/update_product_name_usecase.dart';
import '../../domain/usecases/update_product_price_usecase.dart';

part 'products_providers.g.dart';

@riverpod
ProductsRemoteDataSource productsRemoteDataSource(Ref ref) {
  return ProductsRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}

@riverpod
ProductsLocalDataSource productsLocalDataSource(Ref ref) {
  return ProductsLocalDataSourceImpl(ref.watch(appDatabaseProvider));
}

@riverpod
ProductsRepository productsRepository(Ref ref) {
  return ProductsRepositoryImpl(
    ref.watch(productsRemoteDataSourceProvider),
    ref.watch(productsLocalDataSourceProvider),
  );
}

@riverpod
GetProductsUseCase getProductsUseCase(Ref ref) {
  return GetProductsUseCase(ref.watch(productsRepositoryProvider));
}

@riverpod
CreateProductUseCase createProductUseCase(Ref ref) {
  return CreateProductUseCase(ref.watch(productsRepositoryProvider));
}

@riverpod
SetProductActiveUseCase setProductActiveUseCase(Ref ref) {
  return SetProductActiveUseCase(ref.watch(productsRepositoryProvider));
}

@riverpod
UpdateProductNameUseCase updateProductNameUseCase(Ref ref) {
  return UpdateProductNameUseCase(ref.watch(productsRepositoryProvider));
}

@riverpod
UpdateProductPriceUseCase updateProductPriceUseCase(Ref ref) {
  return UpdateProductPriceUseCase(ref.watch(productsRepositoryProvider));
}
