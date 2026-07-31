import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/seller.dart';

part 'sellers_providers.g.dart';

@riverpod
class SellersController extends _$SellersController {
  @override
  List<Seller> build() {
    return const [
      Seller(
        id: 'seller-001',
        email: 'maria.garcia@arenero.com',
        name: 'María García',
        active: true,
      ),
      Seller(
        id: 'seller-002',
        email: 'juan.perez@arenero.com',
        name: 'Juan Pérez',
        active: true,
      ),
      Seller(
        id: 'seller-003',
        email: 'carlos.lopez@arenero.com',
        name: 'Carlos López',
        active: true,
      ),
      Seller(
        id: 'seller-004',
        email: 'ana.martinez@arenero.com',
        name: 'Ana Martínez',
        active: false,
      ),
      Seller(
        id: 'seller-005',
        email: 'luis.hernandez@arenero.com',
        name: 'Luis Hernández',
        active: true,
      ),
      Seller(
        id: 'seller-006',
        email: 'paola.sanchez@arenero.com',
        name: 'Paola Sánchez',
        active: false,
      ),
    ];
  }

  void setActive(Set<String> ids, bool active) {
    if (ids.isEmpty) return;

    state = [
      for (final seller in state)
        if (ids.contains(seller.id)) seller.copyWith(active: active) else seller,
    ];
  }
}
