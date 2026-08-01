import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/seller.dart';
import 'sellers_providers.dart';

part 'sellers_controller_provider.g.dart';

@riverpod
class SellersController extends _$SellersController {
  @override
  Future<List<Seller>> build() async {
    final useCase = ref.watch(getSellersUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) => throw failure,
      (sellers) => sellers,
    );
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
