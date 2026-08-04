import 'package:arenero/features/products/domain/entities/product.dart';
import 'package:arenero/features/products/domain/services/product_duplicate_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeProductName', () {
    test('normaliza espacios y mayusculas', () {
      expect(normalizeProductName('  Arena   Fina  '), 'arena fina');
    });
  });

  group('isDuplicateProductName', () {
    const products = [
      Product(id: 'p1', name: 'Arena Fina', active: true),
      Product(id: 'p2', name: 'Gravilla', active: true),
    ];

    test('detecta un producto repetido por nombre normalizado', () {
      expect(
        isDuplicateProductName(products: products, name: ' arena fina '),
        isTrue,
      );
    });

    test('ignora el producto actual cuando se pasa ignoringProductId', () {
      expect(
        isDuplicateProductName(
          products: products,
          name: 'Arena Fina',
          ignoringProductId: 'p1',
        ),
        isFalse,
      );
    });
  });
}
