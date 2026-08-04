import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_client_provider.dart';
import '../../data/datasources/products_remote_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/set_product_active_usecase.dart';

final productsRemoteDataSourceProvider = Provider<ProductsRemoteDataSource>(
  (ref) => ProductsRemoteDataSourceImpl(ref.watch(supabaseClientProvider)),
);

final productsRepositoryProvider = Provider<ProductsRepository>(
  (ref) => ProductsRepositoryImpl(ref.watch(productsRemoteDataSourceProvider)),
);

final getProductsUseCaseProvider = Provider<GetProductsUseCase>(
  (ref) => GetProductsUseCase(ref.watch(productsRepositoryProvider)),
);

final createProductUseCaseProvider = Provider<CreateProductUseCase>(
  (ref) => CreateProductUseCase(ref.watch(productsRepositoryProvider)),
);

final setProductActiveUseCaseProvider = Provider<SetProductActiveUseCase>(
  (ref) => SetProductActiveUseCase(ref.watch(productsRepositoryProvider)),
);
