import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/sale.dart';
import 'sales_providers.dart';

part 'pending_sales_provider.g.dart';

@riverpod
Future<List<Sale>> pendingSales(Ref ref) async {
  final useCase = ref.watch(getSalesUseCaseProvider);
  final result = await useCase(status: SaleStatus.registered);
  final sales = result.fold((failure) => throw failure, (sales) => sales);

  return [
    for (final sale in sales)
      if (sale.paymentStatus != SalePaymentStatus.paidInFull &&
          sale.pendingAmount > 0)
        sale,
  ];
}
