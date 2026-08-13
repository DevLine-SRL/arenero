import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/is_online_provider.dart';
import '../../domain/entities/sale.dart';
import 'sales_providers.dart';

part 'sale_detail_provider.g.dart';

@riverpod
class SaleDetail extends _$SaleDetail {
  bool _refreshInFlight = false;

  @override
  Future<Sale> build(String saleId) {
    ref.watch(getSaleDetailUseCaseProvider);
    ref.watch(getCachedSaleDetailUseCaseProvider);
    return _load();
  }

  Future<Sale> _load() async {
    final cachedResult = await ref.read(getCachedSaleDetailUseCaseProvider)(
      saleId,
    );
    final cached = cachedResult.fold((_) => null, (sale) => sale);
    if (cached != null) {
      _refreshInBackground();
      return cached;
    }

    final remote = await ref.read(getSaleDetailUseCaseProvider)(saleId);
    return remote.fold((failure) => throw failure, (sale) => sale);
  }

  Future<void> _refreshInBackground() async {
    if (_refreshInFlight) return;
    if (!ref.read(isOnlineProvider)) return;
    _refreshInFlight = true;
    try {
      final result = await ref.read(getSaleDetailUseCaseProvider)(saleId);
      if (!ref.mounted) return;
      result.fold((_) {}, (sale) => state = AsyncData(sale));
    } finally {
      _refreshInFlight = false;
    }
  }
}
