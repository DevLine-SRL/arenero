import '../entities/product.dart';

String normalizeProductName(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

bool isDuplicateProductName({
  required Iterable<Product> products,
  required String name,
  String? ignoringProductId,
}) {
  final normalizedName = normalizeProductName(name);
  if (normalizedName.isEmpty) return false;

  return products.any((product) {
    if (product.id == ignoringProductId) return false;
    return normalizeProductName(product.name) == normalizedName;
  });
}
