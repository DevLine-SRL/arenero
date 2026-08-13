import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/is_online_provider.dart';
import '../../domain/entities/seller.dart';
import 'sellers_providers.dart';

part 'sellers_controller_provider.g.dart';

@riverpod
class SellersController extends _$SellersController {
  bool _refreshInFlight = false;

  @override
  Future<List<Seller>> build() async {
    ref.watch(getSellersUseCaseProvider);
    ref.watch(getCachedSellersUseCaseProvider);

    final cachedResult = await ref.read(getCachedSellersUseCaseProvider)();
    final cached = cachedResult.fold((_) => null, (sellers) => sellers);
    if (cached != null) {
      _refreshInBackground();
      return cached;
    }

    final remote = await ref.read(getSellersUseCaseProvider)();
    return remote.fold((failure) => throw failure, (sellers) => sellers);
  }

  Future<void> _refreshInBackground() async {
    if (_refreshInFlight) return;
    if (!ref.read(isOnlineProvider)) return;
    _refreshInFlight = true;
    try {
      final result = await ref.read(getSellersUseCaseProvider)();
      if (!ref.mounted) return;
      result.fold((_) {}, (sellers) => state = AsyncData(sellers));
    } finally {
      _refreshInFlight = false;
    }
  }

  Future<void> setActive(Set<String> ids, bool active) async {
    if (ids.isEmpty) return;

    final idsCopy = Set<String>.of(ids);
    final previous = state.value;

    state = state.whenData(
      (sellers) => [
        for (final seller in sellers)
          if (idsCopy.contains(seller.id))
            seller.copyWith(active: active)
          else
            seller,
      ],
    );

    final useCase = ref.read(setSellersActiveUseCaseProvider);
    for (final id in idsCopy) {
      final result = await useCase(id: id, active: active);
      if (result.isLeft() && previous != null) {
        state = AsyncData(previous);
        return;
      }
    }
  }
}
