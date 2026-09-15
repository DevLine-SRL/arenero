import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/sale.dart';
import '../providers/sales_history_date_range_provider.dart';
import '../utils/sale_formatters.dart';
import 'cobros_search_query_provider.dart';
import 'cobros_sort_provider.dart';
import 'sales_providers.dart';

part 'pending_sales_provider.g.dart';

@riverpod
Future<List<Sale>> pendingSalesData(Ref ref) async {
  final range = ref.watch(salesHistoryDateRangeProvider);
  final useCase = ref.watch(getSalesUseCaseProvider);
  final result = await useCase(status: SaleStatus.registered);
  final sales = result.fold((failure) => throw failure, (sales) => sales);

  return [
    for (final sale in sales)
      if (sale.paymentStatus != SalePaymentStatus.paidInFull &&
          sale.pendingAmount > 0 &&
          range.includes(sale.saleDate))
        sale,
  ];
}

@riverpod
List<Sale> pendingSales(Ref ref) {
  final items = ref.watch(pendingSalesDataProvider).value ?? const <Sale>[];
  final query = ref.watch(cobrosSearchQueryProvider);
  final sort = ref.watch(cobrosSortProvider);

  final needle = normalizeSearchText(query.trim());
  List<Sale> result = items;

  if (needle.isNotEmpty) {
    result = items.where((sale) {
      final client = normalizeSearchText(sale.client.name);
      final ci = normalizeSearchText(sale.client.ci);
      return client.contains(needle) || ci.contains(needle);
    }).toList();
  }

  final option = sort;
  if (option != null) {
    result = [...result]
      ..sort((a, b) {
        final comparison = switch (option.field) {
          CobrosSortField.number => (a.number ?? 0).compareTo(b.number ?? 0),
          CobrosSortField.client => normalizeSearchText(
            a.client.name,
          ).compareTo(normalizeSearchText(b.client.name)),
          CobrosSortField.pendingAmount => a.pendingAmount.compareTo(
            b.pendingAmount,
          ),
          CobrosSortField.saleDate => a.saleDate.compareTo(b.saleDate),
        };
        return option.direction == CobrosSortDirection.ascending
            ? comparison
            : -comparison;
      });
  }

  return result;
}
