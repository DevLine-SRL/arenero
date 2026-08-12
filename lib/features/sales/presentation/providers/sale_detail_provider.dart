import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/sale.dart';
import 'sales_providers.dart';

part 'sale_detail_provider.g.dart';

@riverpod
Future<Sale> saleDetail(Ref ref, String saleId) async {
  final useCase = ref.watch(getSaleDetailUseCaseProvider);
  final result = await useCase(saleId);
  return result.fold((failure) => throw failure, (sale) => sale);
}
