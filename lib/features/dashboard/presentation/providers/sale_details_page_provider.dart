import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../reports/domain/entities/sale_details_page.dart';
import 'reports_providers.dart';

part 'sale_details_page_provider.g.dart';

class SaleDetailsRequest {
  final DateTime startDate;
  final DateTime endDate;
  final String? clientId;
  final String? sellerId;
  final String search;
  final String orderColumn;
  final bool ascending;
  final int page;
  final int pageSize;

  const SaleDetailsRequest({
    required this.startDate,
    required this.endDate,
    this.clientId,
    this.sellerId,
    this.search = '',
    this.orderColumn = 'sale_date',
    this.ascending = false,
    this.page = 0,
    this.pageSize = 8,
  });

  @override
  bool operator ==(Object other) {
    return other is SaleDetailsRequest &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.clientId == clientId &&
        other.sellerId == sellerId &&
        other.search == search &&
        other.orderColumn == orderColumn &&
        other.ascending == ascending &&
        other.page == page &&
        other.pageSize == pageSize;
  }

  @override
  int get hashCode => Object.hash(
    startDate,
    endDate,
    clientId,
    sellerId,
    search,
    orderColumn,
    ascending,
    page,
    pageSize,
  );
}

@riverpod
Future<SaleDetailsPage> saleDetailsPage(Ref ref, SaleDetailsRequest request) {
  final useCase = ref.watch(getSaleDetailsUseCaseProvider);

  return useCase(
    start: request.startDate,
    end: request.endDate,
    clientId: request.clientId,
    sellerId: request.sellerId,
    search: request.search,
    orderColumn: request.orderColumn,
    ascending: request.ascending,
    page: request.page,
    pageSize: request.pageSize,
  ).then((result) => result.fold((failure) => throw failure, (page) => page));
}
