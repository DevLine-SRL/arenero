import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/supabase_client_provider.dart';
import '../../../reports/data/datasources/reports_remote_datasource.dart';
import '../../../reports/data/repositories/reports_repository_impl.dart';
import '../../../reports/domain/repositories/reports_repository.dart';
import '../../../reports/domain/usecases/get_period_summary_usecase.dart';
import '../../../reports/domain/usecases/get_report_by_client_usecase.dart';
import '../../../reports/domain/usecases/get_report_by_product_usecase.dart';
import '../../../reports/domain/usecases/get_report_by_seller_usecase.dart';
import '../../../reports/domain/usecases/get_sale_details_usecase.dart';
import '../../../reports/domain/usecases/search_clients_usecase.dart';
import '../../../reports/domain/usecases/search_sellers_usecase.dart';

part 'reports_providers.g.dart';

@riverpod
ReportsRemoteDataSource reportsRemoteDataSource(Ref ref) {
  return ReportsRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}

@riverpod
ReportsRepository reportsRepository(Ref ref) {
  return ReportsRepositoryImpl(ref.watch(reportsRemoteDataSourceProvider));
}

@riverpod
GetPeriodSummaryUseCase getPeriodSummaryUseCase(Ref ref) {
  return GetPeriodSummaryUseCase(ref.watch(reportsRepositoryProvider));
}

@riverpod
GetReportByClientUseCase getReportByClientUseCase(Ref ref) {
  return GetReportByClientUseCase(ref.watch(reportsRepositoryProvider));
}

@riverpod
GetReportBySellerUseCase getReportBySellerUseCase(Ref ref) {
  return GetReportBySellerUseCase(ref.watch(reportsRepositoryProvider));
}

@riverpod
GetReportByProductUseCase getReportByProductUseCase(Ref ref) {
  return GetReportByProductUseCase(ref.watch(reportsRepositoryProvider));
}

@riverpod
SearchClientsUseCase searchClientsUseCase(Ref ref) {
  return SearchClientsUseCase(ref.watch(reportsRepositoryProvider));
}

@riverpod
SearchSellersUseCase searchSellersUseCase(Ref ref) {
  return SearchSellersUseCase(ref.watch(reportsRepositoryProvider));
}

@riverpod
GetSaleDetailsUseCase getSaleDetailsUseCase(Ref ref) {
  return GetSaleDetailsUseCase(ref.watch(reportsRepositoryProvider));
}
